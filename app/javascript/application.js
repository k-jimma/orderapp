// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

// Auto-dismiss flash messages
document.addEventListener("turbo:load", () => {
  const flashes = document.querySelectorAll(".flash")
  flashes.forEach((el) => {
    setTimeout(() => {
      el.style.transition = "opacity 300ms ease, transform 300ms ease"
      el.style.opacity = "0"
      el.style.transform = "translateY(-4px)"
      setTimeout(() => el.remove(), 320)
    }, 3200)
  })

  document.querySelectorAll("[data-alert]").forEach((el) => {
    el.addEventListener("click", () => {
      const message = el.getAttribute("data-alert")
      if (message) alert(message)
    })
  })

  const switcher = document.querySelector("[data-table-switcher]")
  const switcherButton = document.querySelector("[data-table-switcher-button]")
  const goToTable = () => {
    if (!switcher) return
    const token = switcher.value
    if (!token) return
    window.location.href = `/t/${token}/items`
  }
  if (switcher) {
    switcher.addEventListener("change", goToTable)
  }
  if (switcherButton) {
    switcherButton.addEventListener("click", goToTable)
  }

  const categoryButtons = document.querySelectorAll("[data-category-button]")
  const categoryPanels = document.querySelectorAll("[data-category-panel]")
  if (categoryButtons.length > 0 && categoryPanels.length > 0) {
    const showCategory = (categoryId) => {
      categoryPanels.forEach((panel) => {
        panel.style.display = panel.dataset.categoryPanel === categoryId ? "" : "none"
      })
      categoryButtons.forEach((btn) => {
        btn.toggleAttribute("data-category-active", btn.dataset.categoryButton === categoryId)
      })
    }

    categoryButtons.forEach((btn, index) => {
      btn.addEventListener("click", () => showCategory(btn.dataset.categoryButton))
      if (index === 0) showCategory(btn.dataset.categoryButton)
    })
  }
})
