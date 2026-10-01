import { Controller } from '@hotwired/stimulus'

// Drives the registration step: name, email, device choice and the combined
// 18+/terms/privacy checkbox. The submit button stays disabled until all four
// are satisfied, and the hint text tells the user what is still missing.
export default class extends Controller {
  static targets = ['name', 'email', 'device', 'platform', 'terms', 'submit', 'hint']

  connect () {
    this.element.addEventListener('input', this.sync)
    this.element.addEventListener('change', this.sync)
    this.sync()
  }

  disconnect () {
    this.element.removeEventListener('input', this.sync)
    this.element.removeEventListener('change', this.sync)
  }

  selectDevice (event) {
    const button = event.currentTarget
    this.deviceTargets.forEach((btn) => {
      btn.setAttribute('aria-pressed', String(btn === button))
    })
    if (this.hasPlatformTarget) {
      this.platformTarget.value = button.dataset.value
    }
    this.sync()
  }

  get platform () {
    const pressed = this.deviceTargets.find((btn) => btn.getAttribute('aria-pressed') === 'true')
    return pressed?.dataset.value || ''
  }

  get valid () {
    const name = this.hasNameTarget ? this.nameTarget.value.trim() : ''
    const email = this.hasEmailTarget ? this.emailTarget.value.trim() : ''
    const emailOk = /\S+@\S+\.\S+/.test(email)
    const platformOk = this.platform !== ''
    const termsOk = this.hasTermsTarget ? this.termsTarget.checked === true : false
    return name !== '' && emailOk && platformOk && termsOk
  }

  sync = () => {
    if (this.hasSubmitTarget) this.submitTarget.disabled = !this.valid
    if (this.hasHintTarget) this.hintTarget.textContent = this.valid ? '' : this.hintMessage
  }

  get hintMessage () {
    return this.hintTarget?.dataset.hint || ''
  }
}
