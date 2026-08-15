import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['backdrop', 'panel']

  connect () {
    this.closeWithKeyboard = this.closeWithKeyboard.bind(this)
  }

  toggle () {
    if (this.backdropTarget.classList.contains('hidden')) {
      this.open()
    } else {
      this.close()
    }
  }

  open () {
    this.backdropTarget.classList.remove('hidden')
    this.panelTarget.style.transform = 'translateX(0)'
    document.addEventListener('keydown', this.closeWithKeyboard)
  }

  close () {
    this.panelTarget.style.transform = 'translateX(100%)'
    setTimeout(() => {
      this.backdropTarget.classList.add('hidden')
    }, 250)
    document.removeEventListener('keydown', this.closeWithKeyboard)
  }

  closeWithKeyboard (e) {
    if (e.key === 'Escape') this.close()
  }
}
