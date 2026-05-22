import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['input', 'dots']

  connect () {
    this.inputTarget.focus()
  }

  input () {
    const val = this.inputTarget.value.replace(/\D/g, '').slice(0, 6)
    this.inputTarget.value = val
    this._updateDots(val.length)
    if (val.length >= 4) {
      this.element.requestSubmit()
    }
  }

  backspace (event) {
    if (event.key === 'Backspace') {
      const val = this.inputTarget.value.slice(0, -1)
      this.inputTarget.value = val
      this._updateDots(val.length)
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
    document.body.appendChild(form)
    form.submit()
  }

  _updateDots (length) {
    this.dotsTarget.querySelectorAll('div').forEach((dot, i) => {
      if (i < length) {
        dot.classList.add('bg-brand-primary')
        dot.classList.remove('border-2')
      } else {
        dot.classList.remove('bg-brand-primary')
        dot.classList.add('border-2')
      }
    })
  }
}
