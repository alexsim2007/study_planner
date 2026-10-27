import "@hotwired/turbo-rails"

const applyTheme = () => {
  const theme = localStorage.getItem("theme") || "dark"
  document.documentElement.setAttribute("data-theme", theme)

  const icon = document.getElementById("theme-toggle-icon")
  const text = document.getElementById("theme-toggle-text")
  if (icon) icon.textContent = theme === "light" ? "☾" : "☀"
  if (text) text.textContent = theme === "light" ? "Тёмная тема" : "Светлая тема"
}

// Turbo navigation replaces the body without firing DOMContentLoaded again.
document.addEventListener("turbo:load", applyTheme)
document.addEventListener("turbo:before-render", applyTheme)
document.addEventListener("click", (event) => {
  if (!event.target.closest("#theme-toggle")) return
  const theme = document.documentElement.getAttribute("data-theme")
  localStorage.setItem("theme", theme === "light" ? "dark" : "light")
  applyTheme()
})
