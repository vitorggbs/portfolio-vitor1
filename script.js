window.addEventListener("load", function () {
  setTimeout(function () {
    document.getElementById("loader").classList.add("done");
  }, 3500);
});

const animatedElements = document.querySelectorAll(
  ".section-kicker, .about h2, .paper-card, .skills h2, .skill-board, " +
    ".project-heading, .project-vertical, .contact-star, .contact p, .contact h2, .contact a",
);

animatedElements.forEach(function (element) {
  element.classList.add("reveal");
});

const observer = new IntersectionObserver(
  function (entries) {
    entries.forEach(function (entry) {
      if (entry.isIntersecting) {
        entry.target.classList.add("visible");
        observer.unobserve(entry.target);
      }
    });
  },
  { threshold: 0.15 },
);

animatedElements.forEach(function (element) {
  observer.observe(element);
});

document.querySelectorAll(".navbar-collapse a").forEach(function (link) {
  link.addEventListener("click", function () {
    const menu = document.getElementById("menu");
    const collapse = bootstrap.Collapse.getInstance(menu);
    if (collapse) collapse.hide();
  });
});

