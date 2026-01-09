import "@hotwired/turbo-rails"
import "controllers"

// --------------------
// Flash auto-dismiss
// --------------------
function autoDismissFlashes(root = document) {
  root.querySelectorAll(".flash").forEach((el) => {
    if (el.dataset.autoDismissed) return
    el.dataset.autoDismissed = "true"

    setTimeout(() => {
      el.style.transition = "opacity 300ms ease, transform 300ms ease"
      el.style.opacity = "0"
      el.style.transform = "translateY(-6px)"
      setTimeout(() => el.remove(), 320)
    }, 3200)
  })
}

// Turboで画面遷移したとき
document.addEventListener("turbo:load", () => {
  // フラッシュ（初回描画）
  autoDismissFlashes()

  // data-alert
  document.querySelectorAll("[data-alert]").forEach((el) => {
    // 重複バインド防止
    if (el.dataset.alertBound) return
    el.dataset.alertBound = "true"

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

  if (switcher && !switcher.dataset.bound) {
    switcher.dataset.bound = "true"
    switcher.addEventListener("change", goToTable)
  }
  if (switcherButton && !switcherButton.dataset.bound) {
    switcherButton.dataset.bound = "true"
    switcherButton.addEventListener("click", goToTable)
  }

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
      if (btn.dataset.bound) return
      btn.dataset.bound = "true"

      btn.addEventListener("click", () => showCategory(btn.dataset.categoryButton))
      if (index === 0) showCategory(btn.dataset.categoryButton)
    })
  }

  // ---- Admin Staff password helper ----
  const pw = document.getElementById("staff-password")
  const pwc = document.getElementById("staff-password-confirm")
  const box = document.querySelector("[data-password-rules]")
  const btnGen = document.querySelector("[data-generate-password]")
  const btnCopy = document.querySelector("[data-copy-password]")
  const hint = document.querySelector("[data-password-hint]")

  // ここは return しない。無いなら「この機能だけ」何もしない
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

  if (!pw.dataset.bound) {
    pw.dataset.bound = "true"
    pw.addEventListener("input", renderRules)
  }
  if (!pwc.dataset.bound) {
    pwc.dataset.bound = "true"
    pwc.addEventListener("input", renderRules)
  }
  renderRules()

  if (btnGen && !btnGen.dataset.bound) {
    btnGen.dataset.bound = "true"
    btnGen.addEventListener("click", () => {
      const v = generatePassword(14)
      pw.value = v
      pwc.value = v
      renderRules()
      if (hint) hint.textContent = "生成しました"
    })
  }

  if (btnCopy && !btnCopy.dataset.bound) {
    btnCopy.dataset.bound = "true"
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

// Turbo Frame の中身が差し替わったとき（flashがturbo_streamで更新されるケース）
document.addEventListener("turbo:frame-load", (event) => {
  autoDismissFlashes(event.target)
})

function saveScrollForNextLoad(targetId = null) {
  try {
    sessionStorage.setItem("restoreScrollY", String(window.scrollY || 0))
    if (targetId) sessionStorage.setItem("restoreScrollTarget", targetId)
  } catch {}
}

function restoreScrollIfNeeded() {
  try {
    const y = sessionStorage.getItem("restoreScrollY")
    const target = sessionStorage.getItem("restoreScrollTarget")

    if (y) {
      sessionStorage.removeItem("restoreScrollY")
      // まずはスクロール位置を戻す
      window.scrollTo(0, parseInt(y, 10) || 0)
    }

    if (target) {
      sessionStorage.removeItem("restoreScrollTarget")
      const el = document.getElementById(target)
      if (el) {
        // 微調整：該当カードが見える位置に来るようにする
        el.scrollIntoView({ block: "center" })
      }
    }
  } catch {}
}

// クリック直前に保存（カート画面のボタンだけ）
document.addEventListener(
  "click",
  (e) => {
    const el = e.target?.closest?.("[data-preserve-scroll]")
    if (!el) return
    const targetId = el.getAttribute("data-preserve-scroll-target")
    saveScrollForNextLoad(targetId)
  },
  true
)

// Turbo遷移後に復元
document.addEventListener("turbo:load", () => {
  restoreScrollIfNeeded()
})

// Turbo Frame更新後にも復元（念のため）
document.addEventListener("turbo:frame-load", () => {
  restoreScrollIfNeeded()
})
