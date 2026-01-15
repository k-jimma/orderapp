import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["label", "input"]
  static values = { min: Number }

  connect() {
    this.minValue = this.minValue || 1
    this.syncFromInput()
  }

  inc() {
    const nextValue = this.value() + 1
    this.setValue(nextValue)
  }

  dec() {
    const nextValue = Math.max(this.minValue, this.value() - 1)
    this.setValue(nextValue)
  }

  value() {
    const parsedValue = parseInt(this.inputTarget.value, 10)
    return Number.isFinite(parsedValue) ? parsedValue : this.minValue
  }

  setValue(value) {
    this.inputTarget.value = String(value)
    this.labelTarget.textContent = String(value)
  }

  syncFromInput() {
    this.setValue(this.value())
  }
}
