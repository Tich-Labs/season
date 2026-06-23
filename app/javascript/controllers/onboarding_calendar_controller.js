import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "submit", "clear", "day"]

  select(event) {
    const date = event.currentTarget.dataset.date
    this.inputTarget.value = date

    this.dayTargets.forEach(btn => this.#clearHighlight(btn))
    this.#applyHighlight(event.currentTarget)

    this.submitTarget.classList.remove("hidden")
    this.clearTarget.classList.remove("hidden")
  }

  clear(event) {
    event.preventDefault()
    this.inputTarget.value = ""
    this.dayTargets.forEach(btn => this.#clearHighlight(btn))
    this.submitTarget.classList.add("hidden")
    this.clearTarget.classList.add("hidden")
  }

  #applyHighlight(btn) {
    const label = btn.querySelector(".cal-day-label")
    if (!label) return
    label.style.backgroundColor = "#933a35"
    label.style.color = "#FFFFFF"
    label.style.borderRadius = "3px"
    label.style.fontWeight = "600"
  }

  #clearHighlight(btn) {
    const label = btn.querySelector(".cal-day-label")
    if (!label) return
    label.style.backgroundColor = ""
    label.style.color = ""
    label.style.borderRadius = ""
    label.style.fontWeight = ""
  }
}
