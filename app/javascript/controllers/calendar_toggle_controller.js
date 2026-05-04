import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.syncButtonsWithForm()
  }

  toggle(event) {
    event.preventDefault()
    const button = event.currentTarget
    const fieldName = button.dataset.field
    
    // Toggle active state on button
    button.classList.toggle("active")
    
    // Update hidden input value
    const input = this.element.querySelector(`input[name="${fieldName}"]`)
    if (input) {
      input.value = button.classList.contains("active") ? "1" : "0"
    }
    
    // Auto-submit the form
    this.submitForm()
  }

  submitForm() {
    const statusEl = this.element.querySelector('[data-notification="auto-save"]')
    if (statusEl) {
      statusEl.style.display = 'block'
    }
    
    // Use Turbo to submit the form with automatic page update
    this.element.requestSubmit()
  }

  syncButtonsWithForm() {
    // Sync all toggles based on hidden input values
    this.element.querySelectorAll("[data-field]").forEach(button => {
      const fieldName = button.dataset.field
      const input = this.element.querySelector(`input[name="${fieldName}"]`)
      if (input && input.value === "1") {
        button.classList.add("active")
      } else {
        button.classList.remove("active")
      }
    })
  }
}


