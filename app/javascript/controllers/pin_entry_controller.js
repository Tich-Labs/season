import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static values = {
    modal: Boolean,
    revealed: Boolean,
    showLabel: { type: String, default: 'Show PIN' },
    hideLabel: { type: String, default: 'Hide PIN' }
  }

  static targets = ['input', 'dots', 'dot', 'digits', 'error', 'modal', 'revealButton', 'eyeOpen', 'eyeClosed']

  connect () {
    this.inputTarget.addEventListener('input', () => this.#syncDots())
    this.#syncDots()
    this.inputTarget.focus()
  }

  focusInput () {
    this.inputTarget.focus()
  }

  toggleReveal () {
    this.revealedValue = !this.revealedValue
    this.#syncDots()
  }

  input (event) {
    const val = this.inputTarget.value.replace(/\D/g, '').slice(0, 6)
    this.inputTarget.value = val
    this.#syncDots()
    if (val.length === 4 || val.length === 6) {
      if (this.modalValue) {
        this.#submitViaFetch(val)
      } else {
        this.element.requestSubmit()
      }
    }
  }

  backspace (event) {
    if (event.key === 'Backspace') {
      const val = this.inputTarget.value.slice(0, -1)
      this.inputTarget.value = val
      this.#syncDots()
    }
  }

  logout () {
    const form = document.createElement('form')
    form.method = 'post'
    form.action = '/session'
    const input = document.createElement('input')
    input.type = 'hidden'
    input.name = '_method'
    input.value = 'delete'
    form.appendChild(input)
    const csrf = document.querySelector('meta[name=csrf-token]')
    if (csrf) {
      const csrfInput = document.createElement('input')
      csrfInput.type = 'hidden'
      csrfInput.name = 'authenticity_token'
      csrfInput.value = csrf.content
      form.appendChild(csrfInput)
    }
    document.body.appendChild(form)
    form.submit()
  }

  async #submitViaFetch (pin) {
    const csrf = document.querySelector('meta[name=csrf-token]')?.content || ''

    try {
      const resp = await fetch('/unlock', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Accept: 'application/json',
          'X-CSRF-Token': csrf
        },
        body: JSON.stringify({ pin })
      })

      if (resp.ok) {
        const modal = this.modalTarget
        modal.style.display = 'none'
        modal.remove()
      } else {
        const data = await resp.json()
        const errorEl = this.errorTarget
        errorEl.textContent = data.error || 'Incorrect code'
        errorEl.classList.remove('hidden')
        this.inputTarget.value = ''
        this.#syncDots()
        this.inputTarget.focus()
      }
    } catch (e) {
      const errorEl = this.errorTarget
      errorEl.textContent = 'Connection error'
      errorEl.classList.remove('hidden')
    }
  }

  #syncDots () {
    const val = this.inputTarget.value
    const len = val.length

    this.dotTargets.forEach((dot, i) => {
      dot.classList.toggle('bg-brand-primary', i < len)
    })

    if (this.hasDigitsTarget) {
      this.digitsTarget.textContent = val
    }

    if (this.hasDotsTarget && this.hasDigitsTarget) {
      this.dotsTarget.classList.toggle('hidden', this.revealedValue)
      this.digitsTarget.classList.toggle('hidden', !this.revealedValue)
    }

    if (this.hasEyeOpenTarget && this.hasEyeClosedTarget) {
      this.eyeOpenTarget.classList.toggle('hidden', this.revealedValue)
      this.eyeClosedTarget.classList.toggle('hidden', !this.revealedValue)
    }

    if (this.hasRevealButtonTarget) {
      const label = this.revealedValue ? this.hideLabelValue : this.showLabelValue
      this.revealButtonTarget.setAttribute('aria-pressed', String(this.revealedValue))
      this.revealButtonTarget.setAttribute('aria-label', label)
    }
  }
}
