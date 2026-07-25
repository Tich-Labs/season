import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['pinForm', 'emailForm', 'dots', 'dot', 'input', 'error', 'greeting']

  connect () {
    this.email = localStorage.getItem('season_last_email')
    if (!this.email) {
      this.#showEmailForm()
      return
    }

    fetch(`/session/user_status?email=${encodeURIComponent(this.email)}`)
      .then(r => r.json())
      .then(data => {
        if (data.has_pin) {
          this.#showPinForm(data.email)
        } else {
          this.#showEmailForm()
        }
      })
      .catch(() => this.#showEmailForm())
  }

  focusInput () {
    if (this.hasInputTarget) this.inputTarget.focus()
  }

  input (event) {
    const val = this.inputTarget.value.replace(/\D/g, '').slice(0, 6)
    this.inputTarget.value = val
    this.#syncDots()
    if (val.length === 4 || val.length === 6) {
      this.#submitPin(val)
    }
  }

  backspace (event) {
    if (event.key === 'Backspace') {
      const val = this.inputTarget.value.slice(0, -1)
      this.inputTarget.value = val
      this.#syncDots()
    }
  }

  switchToEmail (event) {
    event.preventDefault()
    localStorage.removeItem('season_last_email')
    this.#showEmailForm()
  }

  #showPinForm (email) {
    if (this.hasEmailFormTarget) this.emailFormTarget.classList.add('hidden')
    if (this.hasPinFormTarget) this.pinFormTarget.classList.remove('hidden')
    if (this.hasGreetingTarget) {
      this.greetingTarget.textContent = `Welcome back, ${email.split('@')[0]}`
    }
    this.inputTarget.focus()
  }

  #showEmailForm () {
    if (this.hasPinFormTarget) this.pinFormTarget.classList.add('hidden')
    if (this.hasEmailFormTarget) this.emailFormTarget.classList.remove('hidden')
  }

  async #submitPin (pin) {
    const csrf = document.querySelector('meta[name=csrf-token]')?.content || ''

    try {
      const resp = await fetch('/session/pin_login', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-CSRF-Token': csrf
        },
        body: JSON.stringify({ pin, email: this.email })
      })

      const data = await resp.json()

      if (resp.ok && data.success) {
        window.location.href = data.redirect
      } else {
        const errorEl = this.errorTarget
        errorEl.textContent = data.error || 'Incorrect code'
        errorEl.classList.remove('hidden')
        this.inputTarget.value = ''
        this.#syncDots()
        this.inputTarget.focus()
      }
    } catch (e) {
      const errorEl = this.errorTarget
      errorEl.textContent = 'Connection error. Please try again.'
      errorEl.classList.remove('hidden')
    }
  }

  #syncDots () {
    const val = this.inputTarget.value
    const len = val.length
    this.dotTargets.forEach((dot, i) => {
      dot.classList.toggle('bg-brand-primary', i < len)
    })
  }
}
