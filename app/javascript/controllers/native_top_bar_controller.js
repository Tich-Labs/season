/* global requestAnimationFrame */
import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['dropdown', 'backdrop']

  connect () {
    this.open = false
  }

  toggle () {
    this.open ? this.close() : this._open()
  }

  _open () {
    this.open = true
    this.dropdownTarget.style.display = 'block'
    this.backdropTarget.style.display = 'block'
    requestAnimationFrame(() => {
      this.dropdownTarget.style.transform = 'translateX(0)'
      this.backdropTarget.style.opacity = '1'
    })
  }

  close () {
    this.open = false
    this.dropdownTarget.style.transform = 'translateX(100%)'
    this.backdropTarget.style.opacity = '0'
    setTimeout(() => {
      this.dropdownTarget.style.display = 'none'
      this.backdropTarget.style.display = 'none'
    }, 250)
  }

  backdropClick (event) {
    if (event.target === this.backdropTarget) this.close()
  }
}
