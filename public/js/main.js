/**
 * OpsForge Labs — site interactions
 */
(function () {
  const navToggle = document.querySelector(".nav-toggle");
  const navList = document.querySelector(".nav-list");

  if (navToggle && navList) {
    navToggle.addEventListener("click", function () {
      const open = navList.classList.toggle("is-open");
      navToggle.setAttribute("aria-expanded", open ? "true" : "false");
      navToggle.setAttribute("aria-label", open ? "Close menu" : "Open menu");
    });

    navList.querySelectorAll("a").forEach(function (link) {
      link.addEventListener("click", function () {
        navList.classList.remove("is-open");
        navToggle.setAttribute("aria-expanded", "false");
      });
    });
  }

  /* Lead form: opens mail client with prefilled body (no backend required for V1) */
  const leadForm = document.getElementById("lead-form");
  if (leadForm) {
    leadForm.addEventListener("submit", function (e) {
      e.preventDefault();
      const fd = new FormData(leadForm);
      const name = (fd.get("name") || "").toString().trim();
      const email = (fd.get("email") || "").toString().trim();
      const interest = (fd.get("interest") || "").toString();
      const message = (fd.get("message") || "").toString().trim();

      const subject = encodeURIComponent("OpsForge Labs — Lead / Demo request");
      const body = encodeURIComponent(
        ["Name: " + name, "Email: " + email, "Interest: " + interest, "", message].join("\n")
      );
      window.location.href = "mailto:rajesh@opsforgelabs.in?subject=" + subject + "&body=" + body;
    });
  }
})();
