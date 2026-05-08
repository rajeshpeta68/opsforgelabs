#!/usr/bin/env bash
# One-shot bootstrap + deploy for opsforgelabs (Astro static site behind nginx).
#
# Goal: on a fresh EC2 (Amazon Linux 2023 / RHEL or Debian/Ubuntu) where you
# only have:
#   - this repo cloned somewhere (anywhere — e.g. /home/ec2-user/opsforgelabs)
#   - nginx already installed
#   - sudo access
# running `./scripts/deploy.sh` should leave the site up and running on port 80.
#
# What it does:
#   1. Installs Node.js 20.x (and git) if missing
#   2. npm ci + astro build  -> ./dist
#   3. Rsyncs ./dist -> /var/www/opsforgelabs  (standard web root, SELinux-friendly)
#   4. Writes /etc/nginx/conf.d/opsforgelabs.conf (only if absent)
#   5. Applies SELinux web-content label on RHEL-family if SELinux is enforcing
#   6. nginx -t && systemctl reload (or start) nginx
#
# Usage:
#   cd /path/to/opsforgelabs
#   ./scripts/deploy.sh                 # full bootstrap + deploy
#   ./scripts/deploy.sh --skip-install  # skip system package install (faster redeploys)
#
# Env overrides:
#   DOMAIN=opsforgelabs.in WWW_DOMAIN=www.opsforgelabs.in \
#   WEB_ROOT=/var/www/opsforgelabs ./scripts/deploy.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_DIR"

DOMAIN="${DOMAIN:-opsforgelabs.in}"
WWW_DOMAIN="${WWW_DOMAIN:-www.${DOMAIN}}"
WEB_ROOT="${WEB_ROOT:-/var/www/opsforgelabs}"
NGINX_CONF="/etc/nginx/conf.d/opsforgelabs.conf"
SKIP_INSTALL=0

for arg in "$@"; do
  case "$arg" in
    --skip-install) SKIP_INSTALL=1 ;;
    -h|--help) sed -n '2,30p' "$0"; exit 0 ;;
    *) echo "unknown arg: $arg" >&2; exit 2 ;;
  esac
done

log()  { printf '\033[1;36m[deploy]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[deploy]\033[0m %s\n' "$*"; }
err()  { printf '\033[1;31m[deploy]\033[0m %s\n' "$*" >&2; }
trap 'err "failed at line $LINENO"; exit 1' ERR

log "repo:     $REPO_DIR"
log "web root: $WEB_ROOT"
log "domain:   $DOMAIN ($WWW_DOMAIN)"

# ---------------------------------------------------------------------------
# 1. System packages: git, rsync, Node.js 20+
# ---------------------------------------------------------------------------
PKG_MGR=""
if   command -v dnf     >/dev/null 2>&1; then PKG_MGR=dnf
elif command -v apt-get >/dev/null 2>&1; then PKG_MGR=apt
else err "no supported package manager (dnf/apt) found"; exit 1
fi

if [[ "$SKIP_INSTALL" -eq 0 ]]; then
  log "ensuring git + rsync are installed"
  if [[ "$PKG_MGR" == "dnf" ]]; then
    sudo dnf install -y git rsync >/dev/null
  else
    sudo apt-get update -y >/dev/null
    sudo apt-get install -y git rsync curl >/dev/null
  fi

  need_node=1
  if command -v node >/dev/null 2>&1; then
    major="$(node -p 'process.versions.node.split(".")[0]')"
    [[ "$major" -ge 20 ]] && need_node=0
  fi
  if [[ "$need_node" -eq 1 ]]; then
    log "installing Node.js 20.x (NodeSource)"
    if [[ "$PKG_MGR" == "dnf" ]]; then
      curl -fsSL https://rpm.nodesource.com/setup_20.x | sudo bash -
      sudo dnf install -y nodejs
    else
      curl -fsSL https://deb.nodesource.com/setup_20.x | sudo bash -
      sudo apt-get install -y nodejs
    fi
  else
    log "node $(node -v) already installed — skipping"
  fi
fi

command -v node    >/dev/null 2>&1 || { err "node not installed"; exit 1; }
command -v npm     >/dev/null 2>&1 || { err "npm not installed"; exit 1; }
command -v rsync   >/dev/null 2>&1 || { err "rsync not installed"; exit 1; }
command -v nginx   >/dev/null 2>&1 || { err "nginx not installed"; exit 1; }
log "node $(node -v)  npm $(npm -v)"

# ---------------------------------------------------------------------------
# 2. Build the site
# ---------------------------------------------------------------------------
log "installing project dependencies (npm ci)"
npm ci --no-audit --no-fund

log "building site (astro build)"
npx astro build

[[ -d "$REPO_DIR/dist" ]] || { err "build did not produce dist/"; exit 1; }

# ---------------------------------------------------------------------------
# 3. Sync build output to the web root
# ---------------------------------------------------------------------------
log "syncing dist/ -> $WEB_ROOT"
sudo mkdir -p "$WEB_ROOT"
sudo rsync -a --delete "$REPO_DIR/dist/" "$WEB_ROOT/"

# ---------------------------------------------------------------------------
# 4. Write nginx config if it doesn't exist yet
# ---------------------------------------------------------------------------
if [[ ! -f "$NGINX_CONF" ]]; then
  log "writing $NGINX_CONF"
  sudo tee "$NGINX_CONF" >/dev/null <<EOF
server {
    listen 80;
    listen [::]:80;
    server_name ${DOMAIN} ${WWW_DOMAIN};

    root ${WEB_ROOT};
    index index.html;

    location / {
        try_files \$uri \$uri/ =404;
    }

    location ~* \.(css|js|woff2?|ico|svg|png|jpg|jpeg|webp|gif)\$ {
        try_files \$uri =404;
        expires 7d;
        add_header Cache-Control "public, max-age=604800";
    }

    location ~ /\. {
        deny all;
    }
}
EOF
else
  log "nginx config already present at $NGINX_CONF — leaving it"
fi

# ---------------------------------------------------------------------------
# 5. SELinux: label the web root so nginx can read it (RHEL-family)
# ---------------------------------------------------------------------------
if command -v getenforce >/dev/null 2>&1 && [[ "$(getenforce)" == "Enforcing" ]]; then
  log "SELinux is enforcing — applying httpd_sys_content_t label to $WEB_ROOT"
  if ! command -v semanage >/dev/null 2>&1; then
    sudo dnf install -y policycoreutils-python-utils >/dev/null || true
  fi
  if command -v semanage >/dev/null 2>&1; then
    sudo semanage fcontext -a -t httpd_sys_content_t "${WEB_ROOT}(/.*)?" 2>/dev/null \
      || sudo semanage fcontext -m -t httpd_sys_content_t "${WEB_ROOT}(/.*)?"
    sudo restorecon -Rv "$WEB_ROOT" >/dev/null
  else
    warn "semanage not available; if nginx returns 403, install policycoreutils-python-utils"
  fi
fi

# ---------------------------------------------------------------------------
# 6. Validate + (re)load nginx
# ---------------------------------------------------------------------------
log "validating nginx config"
sudo nginx -t

log "enabling + (re)loading nginx"
sudo systemctl enable nginx >/dev/null 2>&1 || true
if sudo systemctl is-active --quiet nginx; then
  sudo systemctl reload nginx
else
  sudo systemctl start nginx
fi

PUBLIC_IP="$(curl -fsS --max-time 2 http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null || true)"
log "done. site is live."
[[ -n "$PUBLIC_IP" ]] && log "  http://${PUBLIC_IP}/"
log "  http://${DOMAIN}/   (once DNS points at this server)"
log ""
log "next: enable HTTPS with Let's Encrypt:"
log "  sudo dnf install -y certbot python3-certbot-nginx   # or apt"
log "  sudo certbot --nginx -d ${DOMAIN} -d ${WWW_DOMAIN} --redirect"
