import "@hotwired/turbo-rails"
import "controllers"

// --------------------
// フラッシュ自動消去
// --------------------
function autoDismissFlashes(root = document) {
  root.querySelectorAll(".flash").forEach((flashEl) => {
    if (flashEl.dataset.autoDismissed) return
    flashEl.dataset.autoDismissed = "true"

    setTimeout(() => {
      flashEl.style.transition = "opacity 300ms ease, transform 300ms ease"
      flashEl.style.opacity = "0"
      flashEl.style.transform = "translateY(-6px)"
      setTimeout(() => flashEl.remove(), 320)
    }, 3200)
  })
}

// Turboで画面遷移したとき
document.addEventListener("turbo:load", () => {
  // フラッシュ（初回描画）
  autoDismissFlashes()

  // data-alert
  document.querySelectorAll("[data-alert]").forEach((alertElement) => {
    // 重複バインド防止
    if (alertElement.dataset.alertBound) return
    alertElement.dataset.alertBound = "true"

    alertElement.addEventListener("click", () => {
      const message = alertElement.getAttribute("data-alert")
      if (message) alert(message)
    })
  })

  // Staff table switcher
  const tableSwitcherSelect = document.querySelector("[data-table-switcher]")
  const tableSwitcherButton = document.querySelector("[data-table-switcher-button]")

  const navigateToTable = () => {
    if (!tableSwitcherSelect) return
    const token = tableSwitcherSelect.value
    if (!token) return

    const isStaff = document.body?.dataset?.role === "staff"
    const qs = isStaff ? "?staff=1" : ""
    window.location.href = `/t/${token}/items${qs}`
  }

  if (tableSwitcherSelect && !tableSwitcherSelect.dataset.bound) {
    tableSwitcherSelect.dataset.bound = "true"
    tableSwitcherSelect.addEventListener("change", navigateToTable)
  }
  if (tableSwitcherButton && !tableSwitcherButton.dataset.bound) {
    tableSwitcherButton.dataset.bound = "true"
    tableSwitcherButton.addEventListener("click", navigateToTable)
  }

  // Customer category tabs
  const categoryTabButtons = document.querySelectorAll("[data-category-button]")
  const categoryPanels = document.querySelectorAll("[data-category-panel]")
  let closeCategoryDrawerFn = null

  // Customer category drawer (mobile)
  const categoryDrawerToggleButton = document.querySelector("[data-category-drawer-toggle]")
  const categoryDrawer = document.querySelector("[data-category-drawer]")
  const categoryDrawerBackdrop = document.querySelector("[data-category-drawer-backdrop]")

  if (categoryDrawerToggleButton && categoryDrawer && categoryDrawerBackdrop && !categoryDrawerToggleButton.dataset.bound) {
    categoryDrawerToggleButton.dataset.bound = "true"

    const openDrawer = () => {
      document.body.classList.add("is-category-drawer-open")
      categoryDrawerBackdrop.hidden = false
      categoryDrawer.setAttribute("aria-hidden", "false")
      categoryDrawerToggleButton.setAttribute("aria-expanded", "true")
    }

    const closeDrawer = () => {
      document.body.classList.remove("is-category-drawer-open")
      categoryDrawerBackdrop.hidden = true
      categoryDrawer.setAttribute("aria-hidden", "true")
      categoryDrawerToggleButton.setAttribute("aria-expanded", "false")
    }

    closeCategoryDrawerFn = closeDrawer

    categoryDrawerToggleButton.addEventListener("click", () => {
      if (document.body.classList.contains("is-category-drawer-open")) {
        closeDrawer()
      } else {
        openDrawer()
      }
    })

    categoryDrawerBackdrop.addEventListener("click", closeDrawer)

    document.addEventListener("keydown", (event) => {
      if (event.key === "Escape" && document.body.classList.contains("is-category-drawer-open")) {
        closeDrawer()
      }
    })

    if (window.matchMedia && window.matchMedia("(max-width: 720px)").matches) {
      closeDrawer()
    }
  }

  const fitCategoryText = (selector, baseFontSize, longFontSize, extraLongFontSize) => {
    document.querySelectorAll(selector).forEach((labelEl) => {
      const text = labelEl.textContent?.trim() || ""
      const textLength = Array.from(text).length
      let fontSize = baseFontSize
      if (textLength >= 12) fontSize = longFontSize
      if (textLength >= 16) fontSize = extraLongFontSize
      labelEl.style.fontSize = `${fontSize}px`
    })
  }

  fitCategoryText(".category-root-title", 15, 13, 12)
  fitCategoryText(".category-child-button", 14, 12, 11)

  if (categoryTabButtons.length > 0 && categoryPanels.length > 0) {
    const showCategory = (categoryId) => {
      categoryPanels.forEach((panel) => {
        panel.style.display = panel.dataset.categoryPanel === categoryId ? "" : "none"
      })
      categoryTabButtons.forEach((button) => {
        button.toggleAttribute("data-category-active", button.dataset.categoryButton === categoryId)
      })
    }

    categoryTabButtons.forEach((button, index) => {
      if (button.dataset.bound) return
      button.dataset.bound = "true"

      button.addEventListener("click", () => {
        showCategory(button.dataset.categoryButton)
        closeCategoryDrawerFn?.()
        window.scrollTo({ top: 0, behavior: "smooth" })
      })
      if (index === 0) showCategory(button.dataset.categoryButton)
    })
  }

  // Admin order history table filters
  const tableFilterAllCheckbox = document.querySelector("[data-table-filter-all]")
  const tableFilterItemCheckboxes = document.querySelectorAll("[data-table-filter-item]")

  if (tableFilterAllCheckbox && tableFilterItemCheckboxes.length > 0 && !tableFilterAllCheckbox.dataset.bound) {
    tableFilterAllCheckbox.dataset.bound = "true"
    tableFilterAllCheckbox.addEventListener("change", () => {
      tableFilterItemCheckboxes.forEach((checkbox) => {
        checkbox.checked = tableFilterAllCheckbox.checked
      })
    })

    tableFilterItemCheckboxes.forEach((checkbox) => {
      if (checkbox.dataset.bound) return
      checkbox.dataset.bound = "true"
      checkbox.addEventListener("change", () => {
        const allChecked = Array.from(tableFilterItemCheckboxes).every((item) => item.checked)
        tableFilterAllCheckbox.checked = allChecked
      })
    })
  }

  // Mobile nav drawer (admin/staff)
  const navToggleButton = document.querySelector("[data-nav-toggle]")
  const navDrawer = document.querySelector("[data-nav-drawer]")
  const navBackdrop = document.querySelector("[data-nav-backdrop]")
  const navClose = document.querySelector("[data-nav-close]")

  if (navToggleButton && navDrawer && navBackdrop && !navToggleButton.dataset.bound) {
    navToggleButton.dataset.bound = "true"

    const openDrawer = () => {
      navDrawer.classList.add("is-open")
      navBackdrop.hidden = false
      navDrawer.setAttribute("aria-hidden", "false")
      navToggleButton.setAttribute("aria-expanded", "true")
      document.body.style.overflow = "hidden"
    }

    const closeDrawer = () => {
      navDrawer.classList.remove("is-open")
      navBackdrop.hidden = true
      navDrawer.setAttribute("aria-hidden", "true")
      navToggleButton.setAttribute("aria-expanded", "false")
      document.body.style.overflow = ""
    }

    navToggleButton.addEventListener("click", () => {
      if (navDrawer.classList.contains("is-open")) {
        closeDrawer()
      } else {
        openDrawer()
      }
    })

    navBackdrop.addEventListener("click", closeDrawer)
    navClose?.addEventListener("click", closeDrawer)

    document.addEventListener("keydown", (event) => {
      if (event.key === "Escape" && navDrawer.classList.contains("is-open")) {
        closeDrawer()
      }
    })
  }

  // ---- Admin Staff password helper ----
  const passwordInput = document.getElementById("staff-password")
  const passwordConfirmInput = document.getElementById("staff-password-confirm")
  const rulesBox = document.querySelector("[data-password-rules]")
  const generateButton = document.querySelector("[data-generate-password]")
  const copyButton = document.querySelector("[data-copy-password]")
  const hintText = document.querySelector("[data-password-hint]")

  // ここは return しない。無いなら「この機能だけ」何もしない
  if (!passwordInput || !passwordConfirmInput) return

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
    if (!rulesBox) return
    rulesBox.style.display = ""
    const rules = checkRules(passwordInput.value, passwordConfirmInput.value)
    Object.entries(rules).forEach(([k, ok]) => {
      const ruleEl = rulesBox.querySelector(`[data-rule="${k}"]`)
      if (!ruleEl) return
      ruleEl.textContent = ok ? "✅" : "❌"
    })
  }

  if (!passwordInput.dataset.bound) {
    passwordInput.dataset.bound = "true"
    passwordInput.addEventListener("input", renderRules)
  }
  if (!passwordConfirmInput.dataset.bound) {
    passwordConfirmInput.dataset.bound = "true"
    passwordConfirmInput.addEventListener("input", renderRules)
  }
  renderRules()

  if (generateButton && !generateButton.dataset.bound) {
    generateButton.dataset.bound = "true"
    generateButton.addEventListener("click", () => {
      const v = generatePassword(14)
      passwordInput.value = v
      passwordConfirmInput.value = v
      renderRules()
      if (hintText) hintText.textContent = "生成しました"
    })
  }

  if (copyButton && !copyButton.dataset.bound) {
    copyButton.dataset.bound = "true"
    copyButton.addEventListener("click", async () => {
      if (!passwordInput.value) return
      try {
        await navigator.clipboard.writeText(passwordInput.value)
        if (hintText) hintText.textContent = "コピーしました"
      } catch {
        if (hintText) hintText.textContent = "コピーできませんでした"
      }
    })
  }
})

// Turboのconfirmをカスタムモーダルに差し替え
function setupConfirmModal() {
  if (!window.Turbo) return

  const modal = document.getElementById("confirm-modal")
  const messageElement = document.getElementById("confirm-modal-message")
  const confirmOkButton = modal?.querySelector("[data-confirm-ok]")
  const cancelButtons = modal?.querySelectorAll("[data-confirm-cancel]") || []

  if (!modal || !messageElement || !confirmOkButton) {
    window.__confirmModalOpen = (text) => Promise.resolve(window.confirm(text))
    return
  }

  window.__confirmModalOpen = (text) =>
    new Promise((resolve) => {
      messageElement.textContent = text
      modal.hidden = false
      modal.setAttribute("aria-hidden", "false")

      const close = (result) => {
        modal.hidden = true
        modal.setAttribute("aria-hidden", "true")
        confirmOkButton.removeEventListener("click", onOk)
        cancelButtons.forEach((el) => el.removeEventListener("click", onCancel))
        resolve(result)
      }

      const onOk = () => close(true)
      const onCancel = () => close(false)

      confirmOkButton.addEventListener("click", onOk)
      cancelButtons.forEach((el) => el.addEventListener("click", onCancel))
    })

  window.Turbo.setConfirmMethod((text) => window.__confirmModalOpen(text))

  if (window.__confirmModalClickBound) return
  window.__confirmModalClickBound = true

  document.addEventListener(
    "click",
    (event) => {
      const confirmElement = event.target?.closest?.("[data-turbo-confirm],[data-confirm]")
      if (!confirmElement) return
      if (confirmElement.dataset.confirmed === "true") return

      event.preventDefault()
      const text =
        confirmElement.getAttribute("data-turbo-confirm") ||
        confirmElement.getAttribute("data-confirm") ||
        "確認しますか？"

      const form = confirmElement.closest("form") || (confirmElement.tagName === "FORM" ? confirmElement : null)
      const submitter = event.target?.closest?.("button, input[type=\"submit\"]")

      window.__confirmModalOpen(text).then((ok) => {
        if (!ok) return
        confirmElement.dataset.confirmed = "true"
        if (submitter) submitter.dataset.confirmed = "true"

        if (confirmElement.dataset.qrGenerate) {
          const targetId = confirmElement.getAttribute("data-qr-target")
          const url = confirmElement.getAttribute("data-qr-url")
          const img = targetId ? document.getElementById(targetId) : null
          if (img && url) {
            const cacheBust = `ts=${Date.now()}`
            const next = url.includes("?") ? `${url}&${cacheBust}` : `${url}?${cacheBust}`
            img.setAttribute("src", next)
          }
          delete confirmElement.dataset.confirmed
          if (submitter) delete submitter.dataset.confirmed
          return
        }

        const confirmElements = [confirmElement, submitter].filter(Boolean)
        const removed = confirmElements.map((el) => ({
          el,
          turbo: el.getAttribute("data-turbo-confirm"),
          confirm: el.getAttribute("data-confirm"),
        }))
        removed.forEach(({ el }) => {
          el.removeAttribute("data-turbo-confirm")
          el.removeAttribute("data-confirm")
        })

        if (form?.requestSubmit) {
          form.requestSubmit(submitter || undefined)
        } else if (form) {
          form.submit()
        } else {
          confirmElement.click()
        }

        removed.forEach(({ el, turbo, confirm }) => {
          if (turbo) el.setAttribute("data-turbo-confirm", turbo)
          if (confirm) el.setAttribute("data-confirm", confirm)
        })

        setTimeout(() => {
          delete confirmElement.dataset.confirmed
          if (submitter) delete submitter.dataset.confirmed
        }, 0)
      })
    },
    true
  )
}

document.addEventListener("turbo:load", () => {
  setupConfirmModal()
})

// Turbo Frame の中身が差し替わったとき（flashがturbo_streamで更新されるケース）
document.addEventListener("turbo:frame-load", (event) => {
  autoDismissFlashes(event.target)
})

// Turbo Stream で差し替えた直後にもフラッシュを自動消去
document.addEventListener("turbo:before-stream-render", (event) => {
  const originalRender = event.detail.render
  event.detail.render = (stream) => {
    originalRender(stream)
    autoDismissFlashes()
  }
})

// 画面遷移前にスクロール位置を保存
function saveScrollForNextLoad(targetId = null) {
  try {
    sessionStorage.setItem("restoreScrollY", String(window.scrollY || 0))
    if (targetId) sessionStorage.setItem("restoreScrollTarget", targetId)
  } catch {}
}

// Turbo遷移後にスクロール位置を復元
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
