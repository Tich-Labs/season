import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['modal']

  open () {
    this.modalTarget.classList.remove('hidden')
  }

  close () {
    this.modalTarget.classList.add('hidden')
  }

  // Close on overlay click
  overlayClick (e) {
    if (e.target === this.modalTarget) this.close()
  }
}
