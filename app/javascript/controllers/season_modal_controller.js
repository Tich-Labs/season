import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['modal', 'backdrop', 'closeBtn']

  connect () {
    this._escHandler = (e) => {
      if (e.key === 'Escape' && !this.modalTarget.classList.contains('hidden')) {
        this.close()
      }
    }
    document.addEventListener('keydown', this._escHandler)

    if (this.hasBackdropTarget) {
      this.backdropTarget.addEventListener('click', () => this.close())
    }
  }

  disconnect () {
    document.removeEventListener('keydown', this._escHandler)
  }

  open () {
    this.modalTarget.classList.remove('hidden')
    this.backdropTarget.classList.remove('hidden')
    setTimeout(() => this.closeBtnTarget?.focus(), 0)
  }

  close () {
    this.modalTarget.classList.add('hidden')
    this.backdropTarget.classList.add('hidden')
  }
}
