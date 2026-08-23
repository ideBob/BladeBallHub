const CONFIG = {
  githubUrl: "https://github.com/ideBob/BladeBallHub",
  downloadUrl: "https://github.com/ideBob/BladeBallHub/blob/main/src/BladeBallHub.lua",
  docsUrl: "https://github.com/ideBob/BladeBallHub/blob/main/docs/Features.md",
};

const THEMES = ["Lavender", "Purple", "Violet", "White", "Black"];
const STORAGE_KEY = "bladeballhub-theme";
const DEFAULT_THEME = "Black";

function isTheme(value) {
  return THEMES.includes(value);
}

function applyTheme(theme) {
  if (!isTheme(theme)) return;
  document.documentElement.dataset.theme = theme;
  try {
    localStorage.setItem(STORAGE_KEY, theme);
  } catch (_) {
    /* private mode */
  }

  document.querySelectorAll("[data-theme-label]").forEach((el) => {
    el.textContent = "Theme: " + theme;
  });

  document.querySelectorAll(".theme-card").forEach((card) => {
    const selected = card.dataset.theme === theme;
    card.classList.toggle("is-selected", selected);
    card.setAttribute("aria-pressed", selected ? "true" : "false");
  });
}

function initTheme() {
  let theme = DEFAULT_THEME;
  try {
    const stored = localStorage.getItem(STORAGE_KEY);
    if (isTheme(stored)) theme = stored;
  } catch (_) {
    /* ignore */
  }
  applyTheme(theme);
}

function initLinks() {
  document.querySelectorAll("[data-link]").forEach((el) => {
    const key = el.getAttribute("data-link");
    const href =
      key === "github" ? CONFIG.githubUrl :
      key === "download" ? CONFIG.downloadUrl :
      key === "docs" ? CONFIG.docsUrl :
      null;
    if (href) el.setAttribute("href", href);
  });
}

function initNav() {
  const toggle = document.getElementById("menu-toggle");
  const menu = document.getElementById("mobile-nav");
  if (!toggle || !menu) return;

  toggle.addEventListener("click", () => {
    const open = menu.hasAttribute("hidden") === false;
    if (open) {
      menu.setAttribute("hidden", "");
      toggle.setAttribute("aria-expanded", "false");
    } else {
      menu.removeAttribute("hidden");
      toggle.setAttribute("aria-expanded", "true");
    }
  });

  menu.querySelectorAll("a").forEach((link) => {
    link.addEventListener("click", () => {
      menu.setAttribute("hidden", "");
      toggle.setAttribute("aria-expanded", "false");
    });
  });
}

function initMockup() {
  document.querySelectorAll("[data-mockup]").forEach((root) => {
    const buttons = root.querySelectorAll("[data-tab]");
    const panels = root.querySelectorAll("[data-panel]");
    buttons.forEach((btn) => {
      btn.addEventListener("click", () => {
        const id = btn.dataset.tab;
        buttons.forEach((b) => {
          b.classList.toggle("is-active", b === btn);
          b.setAttribute("aria-selected", b === btn ? "true" : "false");
        });
        panels.forEach((panel) => {
          panel.hidden = panel.dataset.panel !== id;
        });
      });
    });
  });
}

function initThemePicker() {
  document.querySelectorAll(".theme-card").forEach((card) => {
    card.addEventListener("click", () => applyTheme(card.dataset.theme));
  });
}

initTheme();
initLinks();
initNav();
initMockup();
initThemePicker();
