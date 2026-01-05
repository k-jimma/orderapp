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
})
