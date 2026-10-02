document.addEventListener("DOMContentLoaded", () => {
    const openButton = document.getElementById("open-task-modal")
    const closeButton = document.getElementById("close-task-modal")
    const cancelButton = document.getElementById("cancel-task-modal")
    const overlay = document.getElementById("modal-overlay")
    const modal = document.getElementById("task-modal")
    const form = document.getElementById("task-form")

    if (!openButton || !modal) {
        return
    }

    const openModal = () => {
        modal.classList.add("is-open")
        modal.setAttribute("aria-hidden", "false")
    }

    const closeModal = () => {
        modal.classList.remove("is-open")
        modal.setAttribute("aria-hidden", "true")
    }

    openButton.addEventListener("click", openModal)
    closeButton.addEventListener("click", closeModal)
    cancelButton.addEventListener("click", closeModal)
    overlay.addEventListener("click", closeModal)

    form.addEventListener("submit", (event) => {
        event.preventDefault()
        closeModal()
    })

    document.addEventListener("keydown", (event) => {
        if (event.key === "Escape" && modal.classList.contains("is-open")) {
            closeModal()
        }
    })
})

document.addEventListener("DOMContentLoaded", () => {
    const themeButton = document.getElementById("theme-toggle")
    const themeIcon = document.getElementById("theme-toggle-icon")
    const themeText = document.getElementById("theme-toggle-text")

    const savedTheme = localStorage.getItem("theme") || "dark"

    document.documentElement.setAttribute("data-theme", savedTheme)

    const updateButton = () => {
        const currentTheme =
            document.documentElement.getAttribute("data-theme")

        if (currentTheme === "light") {
            themeIcon.textContent = "☾"
            themeText.textContent = "Тёмная тема"
        } else {
            themeIcon.textContent = "☀"
            themeText.textContent = "Светлая тема"
        }
    }

    updateButton()

    if (!themeButton) {
        return
    }

    themeButton.addEventListener("click", () => {
        const currentTheme =
            document.documentElement.getAttribute("data-theme")

        const newTheme =
            currentTheme === "light" ? "dark" : "light"

        document.documentElement.setAttribute(
            "data-theme",
            newTheme
        )

        localStorage.setItem("theme", newTheme)

        updateButton()
    })
})