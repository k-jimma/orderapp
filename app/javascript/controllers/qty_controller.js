import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["label", "input"]
  static values = { min: Number }

  connect() {
    this.minValue = this.minValue || 1
    this.syncFromInput()
  }

  inc() {
    const v = this.value() + 1
    this.setValue(v)
  }

  dec() {
    const v = Math.max(this.minValue, this.value() - 1)
    this.setValue(v)
  }

  value() {
    const n = parseInt(this.inputTarget.value, 10)
    return Number.isFinite(n) ? n : this.minValue
  }

  setValue(v) {
    this.inputTarget.value = String(v)
    this.labelTarget.textContent = String(v)
  }

  syncFromInput() {
    this.setValue(this.value())
  }
}
