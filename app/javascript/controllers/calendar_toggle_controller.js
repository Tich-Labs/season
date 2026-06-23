import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  toggle(event) {
    const btn = event.currentTarget
    const field = btn.dataset.field
    const isActive = btn.classList.toggle("active")

    const input = this.element.querySelector(`input[name="${field}"]`)
    if (input) input.value = isActive ? "1" : "0"

    this.element.requestSubmit()
  }

  submitForm() {
    this.element.requestSubmit()
  }
}
