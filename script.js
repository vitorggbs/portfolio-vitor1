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

const contactForm = document.getElementById("contactForm");

contactForm.addEventListener("submit", async function (event) {
  event.preventDefault();

  const sendButton = document.getElementById("sendButton");
  const formStatus = document.getElementById("formStatus");
  const formData = new FormData(contactForm);
  const data = Object.fromEntries(formData.entries());

  sendButton.disabled = true;
  sendButton.firstChild.textContent = "ENVIANDO... ";
  formStatus.textContent = "";
  formStatus.className = "form-status";

  try {
    const response = await fetch("/contato", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(data),
    });

    const result = await response.json();

    if (!response.ok) throw new Error(result.erro);

    formStatus.textContent = result.mensagem;
    formStatus.classList.add("success");
    contactForm.reset();
  } catch (error) {
    formStatus.textContent = error.message || "Não foi possível enviar agora.";
    formStatus.classList.add("error");
  } finally {
    sendButton.disabled = false;
    sendButton.firstChild.textContent = "ENVIAR CONTATO ";
  }
});
