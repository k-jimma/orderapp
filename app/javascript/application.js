import "@hotwired/turbo-rails"
import "controllers"

document.addEventListener("turbo:load", () => {
  // Auto-dismiss flash messages
  document.querySelectorAll(".flash").forEach((el) => {
    setTimeout(() => {
      el.style.transition = "opacity 300ms ease, transform 300ms ease"
      el.style.opacity = "0"
      el.style.transform = "translateY(-4px)"
      setTimeout(() => el.remove(), 320)
    }, 3200)
  })

  // data-alert
  document.querySelectorAll("[data-alert]").forEach((el) => {
    el.addEventListener("click", () => {
      const message = el.getAttribute("data-alert")
      if (message) alert(message)
    })
  })

  // Staff table switcher
  const switcher = document.querySelector("[data-table-switcher]")
  const switcherButton = document.querySelector("[data-table-switcher-button]")
  const goToTable = () => {
    if (!switcher) return
    const token = switcher.value
    if (!token) return

    const isStaff = document.body?.dataset?.role === "staff"
    const qs = isStaff ? "?staff=1" : ""
    window.location.href = `/t/${token}/items${qs}`
  }
  if (switcher) switcher.addEventListener("change", goToTable)
  if (switcherButton) switcherButton.addEventListener("click", goToTable)

  // Customer category tabs
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

  // ---- Admin Staff password helper (only when elements exist) ----
  const pw = document.getElementById("staff-password")
  const pwc = document.getElementById("staff-password-confirm")
  const box = document.querySelector("[data-password-rules]")
  const btnGen = document.querySelector("[data-generate-password]")
  const btnCopy = document.querySelector("[data-copy-password]")
  const hint = document.querySelector("[data-password-hint]")

  if (!pw || !pwc) return

  const generatePassword = (len = 14) => {
    const lower = "abcdefghijklmnopqrstuvwxyz"
    const upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    const digits = "0123456789"
    const symbols = "!@#$%^&*_-+"
    const all = lower + upper + digits + symbols
    const pick = (s) => s[Math.floor(Math.random() * s.length)]

    const arr = [pick(lower), pick(upper), pick(digits), pick(symbols)]
    while (arr.length < len) arr.push(pick(all))

    for (let i = arr.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1))
      ;[arr[i], arr[j]] = [arr[j], arr[i]]
    }
    return arr.join("")
  }

  const checkRules = (value, confirmValue) => ({
    len: value.length >= 12,
    lower: /[a-z]/.test(value),
    upper: /[A-Z]/.test(value),
    digit: /[0-9]/.test(value),
    symbol: /[!@#$%^&*_\-+]/.test(value),
    match: value.length > 0 && value === confirmValue,
  })

  const renderRules = () => {
    if (!box) return
    box.style.display = ""
    const rules = checkRules(pw.value, pwc.value)
    Object.entries(rules).forEach(([k, ok]) => {
      const el = box.querySelector(`[data-rule="${k}"]`)
      if (!el) return
      el.textContent = ok ? "✅" : "❌"
    })
  }

  pw.addEventListener("input", renderRules)
  pwc.addEventListener("input", renderRules)
  renderRules()

  if (btnGen) {
    btnGen.addEventListener("click", () => {
      const v = generatePassword(14)
      pw.value = v
      pwc.value = v
      renderRules()
      if (hint) hint.textContent = "生成しました"
    })
  }

  if (btnCopy) {
    btnCopy.addEventListener("click", async () => {
      if (!pw.value) return
      try {
        await navigator.clipboard.writeText(pw.value)
        if (hint) hint.textContent = "コピーしました"
      } catch {
        if (hint) hint.textContent = "コピーできませんでした"
      }
    })
  }
})
