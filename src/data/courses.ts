/**
 * Single source of truth for course listings.
 * Edit this file to update the home Academy strip and /courses (Training page) — no HTML edits.
 *
 * - `featuredOnHome`: include in the home page curriculum strip (typically core tracks only).
 * - `homeTitle` / `homeTeaser`: optional overrides when the marketing line on home differs from /courses.
 */
export interface Course {
  slug: string;
  /** Primary title (courses page, SEO). */
  title: string;
  /** Main description on /courses. */
  summary: string;
  /** If set, home section uses this title instead of `title` (e.g. shorter branding). */
  homeTitle?: string;
  /** If set, home uses this one-liner under the title; otherwise `summary`. */
  homeTeaser?: string;
  /** Show in home "Core learning tracks". */
  featuredOnHome: boolean;
}

export const courses: Course[] = [
  {
    slug: "devops-foundations",
    title: "DevOps Foundations",
    summary:
      "Learn Linux, Git, CI/CD, Docker, networking, and automation basics.",
    homeTeaser: "Linux, Git, networking, scripting, CI/CD.",
    featuredOnHome: true,
  },
  {
    slug: "kubernetes-cloud",
    title: "Kubernetes & Cloud Engineering",
    summary:
      "Hands-on Kubernetes administration, deployments, Helm, scaling, and troubleshooting.",
    homeTitle: "Kubernetes & Cloud",
    homeTeaser: "Containers, Kubernetes, Helm, Terraform, cloud platforms.",
    featuredOnHome: true,
  },
  {
    slug: "ai-devops",
    title: "AI for DevOps Engineers",
    summary:
      "AI-assisted automation, log analysis, AIOps, and AI-powered infrastructure workflows.",
    homeTeaser: "AI automation, AIOps, AI-assisted troubleshooting.",
    featuredOnHome: true,
  },
  {
    slug: "production-labs",
    title: "Production Troubleshooting Labs",
    summary:
      "Real incident simulations, debugging, monitoring, alerting, and recovery workflows.",
    homeTitle: "Production Engineering",
    homeTeaser: "Monitoring, incident response, reliability engineering.",
    featuredOnHome: true,
  },
  {
    slug: "interview-prep",
    title: "Interview Preparation Program",
    summary:
      "Mock interviews, troubleshooting rounds, resume guidance, and practical assessments.",
    featuredOnHome: false,
  },
];

export function coursesForHome(): Course[] {
  return courses.filter((c) => c.featuredOnHome);
}
