/**
 * BladeBallHub website — theme engine, nav, interactive demo
 */
const CONFIG = {
  githubUrl: "https://github.com/ideBob/BladeBallHub",
  repository: "ideBob/BladeBallHub",
  downloadUrl: "https://github.com/ideBob/BladeBallHub/blob/main/src/BladeBallHub.lua",
  docsUrl: "https://github.com/ideBob/BladeBallHub/blob/main/docs/Features.md",
};

const THEMES = ["lavender", "purple", "violet", "white", "black"];
const STORAGE_KEY = "bladeballhub-theme";
const DEFAULT_THEME = "black";

function isTheme(value) {
  return typeof value === "string" && THEMES.includes(value.toLowerCase());
}

function applyTheme(theme) {
  const t = String(theme).toLowerCase();
  if (!isTheme(t)) return;

  document.documentElement.dataset.theme = t;

  try {
    localStorage.setItem(STORAGE_KEY, t);
  } catch (_) {
    /* private mode */
  }

  document.querySelectorAll(".theme-card").forEach((card) => {
    const selected = card.dataset.theme === t;
    card.classList.toggle("is-selected", selected);
    card.setAttribute("aria-pressed", selected ? "true" : "false");
  });

  document.querySelectorAll("[data-demo-theme]").forEach((sel) => {
    if (sel.value !== t) sel.value = t;
  });
}

function initTheme() {
  let theme = DEFAULT_THEME;
  try {
    const stored = localStorage.getItem(STORAGE_KEY);
    if (isTheme(stored)) theme = stored.toLowerCase();
  } catch (_) {
    /* ignore */
  }
  applyTheme(theme);
}

function initLinks() {
  document.querySelectorAll("[data-link]").forEach((el) => {
    const key = el.getAttribute("data-link");
    const href =
      key === "github"
        ? CONFIG.githubUrl
        : key === "download"
          ? CONFIG.downloadUrl
          : key === "docs"
            ? CONFIG.docsUrl
            : null;
    if (href) {
      el.setAttribute("href", href);
      if (key === "github" || key === "download" || key === "docs") {
        el.setAttribute("target", "_blank");
        el.setAttribute("rel", "noopener noreferrer");
      }
    }
  });
}

function initNav() {
  const nav = document.getElementById("nav");
  const toggle = document.getElementById("menu-toggle");
  const menu = document.getElementById("mobile-nav");

  if (nav) {
    const onScroll = () => {
      nav.classList.toggle("is-scrolled", window.scrollY > 12);
    };
    onScroll();
    window.addEventListener("scroll", onScroll, { passive: true });
  }

  if (!toggle || !menu) return;

  toggle.addEventListener("click", () => {
    const open = !menu.hasAttribute("hidden");
    if (open) {
      menu.setAttribute("hidden", "");
      toggle.setAttribute("aria-expanded", "false");
      toggle.setAttribute("aria-label", "Open menu");
    } else {
      menu.removeAttribute("hidden");
      toggle.setAttribute("aria-expanded", "true");
      toggle.setAttribute("aria-label", "Close menu");
    }
  });

  menu.querySelectorAll("a").forEach((link) => {
    link.addEventListener("click", () => {
      menu.setAttribute("hidden", "");
      toggle.setAttribute("aria-expanded", "false");
      toggle.setAttribute("aria-label", "Open menu");
    });
  });
}

function initDemoRoots() {
  document.querySelectorAll("[data-demo-root]").forEach((root) => {
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

    root.querySelectorAll("[data-toggle]").forEach((row) => {
      const sw = row.querySelector(".switch");
      if (!sw) return;
      sw.addEventListener("click", () => {
        const on = sw.classList.toggle("on");
        sw.setAttribute("aria-checked", on ? "true" : "false");
      });
    });

    root.querySelectorAll("[data-slider]").forEach((input) => {
      const valEl = input.closest(".slider-row")?.querySelector("[data-slider-val]");
      const scale = parseFloat(input.dataset.scale || "1");
      const update = () => {
        if (!valEl) return;
        const raw = Number(input.value);
        const display = scale !== 1 ? (raw * scale).toFixed(2) : String(raw);
        valEl.textContent = display;
      };
      input.addEventListener("input", update);
      update();
    });

    root.querySelectorAll("[data-demo-theme]").forEach((sel) => {
      sel.addEventListener("change", () => applyTheme(sel.value));
    });
  });
}

function initThemePicker() {
  document.querySelectorAll(".theme-card").forEach((card) => {
    card.addEventListener("click", () => applyTheme(card.dataset.theme));
  });
}

function initActiveNav() {
  const sections = ["features", "themes", "updates", "github", "get-started"];
  const links = document.querySelectorAll(".nav-links a");
  if (!links.length || !("IntersectionObserver" in window)) return;

  const map = new Map();
  sections.forEach((id) => {
    const el = document.getElementById(id);
    if (el) map.set(el, id);
  });

  const observer = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        if (!entry.isIntersecting) return;
        const id = map.get(entry.target);
        if (!id) return;
        links.forEach((a) => {
          const href = a.getAttribute("href") || "";
          a.classList.toggle("is-active", href === "#" + id);
        });
      });
    },
    { rootMargin: "-40% 0px -50% 0px", threshold: 0 }
  );

  map.forEach((_, el) => observer.observe(el));
}

initTheme();
initLinks();
initNav();
initDemoRoots();
initThemePicker();
initActiveNav();
