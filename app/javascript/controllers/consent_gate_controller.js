import { Controller } from '@hotwired/stimulus'

// Enables the "Accept and get started" button only once the required health
// consent box is ticked. The server re-checks this, so this is purely to stop
// the button being clickable while the form is invalid.
export default class extends Controller {
  static targets = ['required', 'submit']

  connect () {
    this.sync()
    this.element.addEventListener('change', this.sync)
  }

  disconnect () {
    this.element.removeEventListener('change', this.sync)
  }

  sync = () => {
    const granted = this.requiredTargets.some(box => box.checked)
    this.submitTarget.disabled = !granted
  }
}
