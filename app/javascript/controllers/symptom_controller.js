import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { url: String }

  save(event) {
    const field = event.currentTarget.dataset.field
    const value = event.currentTarget.dataset.value
    const date = this.element.dataset.date

    fetch(this.urlValue, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
        'Accept': 'application/json'
      },
      body: JSON.stringify({
        symptom_log: {
          date: date,
          [field]: value
        }
      })
    })
    .then(() => {
      event.currentTarget.closest('.dot-group').querySelectorAll('.dot').forEach((dot, i) => {
        dot.style.opacity = i <= parseInt(value) - 1 ? '1' : '0.3'
      })
    })
  }
}