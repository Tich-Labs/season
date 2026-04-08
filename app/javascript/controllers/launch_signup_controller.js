import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "email", "success", "error", "errorMessage"]

  submit(event) {
    event.preventDefault()
    
    const form = this.formTarget
    const formData = new FormData(form)
    
    fetch(form.action, {
      method: 'POST',
      body: formData,
      headers: {
        'Accept': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      }
    })
    .then(response => response.json())
    .then(data => {
      if (data.error) {
        this.showError(data.error)
      } else {
        this.showSuccess(data.message || "You're on the list!")
        this.emailTarget.value = ''
      }
    })
    .catch(err => {
      this.showError("Something went wrong. Please try again.")
    })
  }

  showSuccess(message) {
    this.successTarget.style.display = 'block'
    this.errorTarget.style.display = 'none'
    this.successTarget.querySelector('p').textContent = '✓ ' + message
  }

  showError(message) {
    this.errorTarget.style.display = 'block'
    this.successTarget.style.display = 'none'
    this.errorMessageTarget.textContent = message
  }
}