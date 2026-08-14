import { Controller } from '@hotwired/stimulus'

// Onboarding step 5's "No Problem" reassurance card (Figma node 12048-15617
// area). Two ways in:
//  - auto-shown on load when the user already said their cycle is irregular
//    (step 4 "No" -> @no_regular_cycle) -- here "Okay, next" just dismisses
//    it, since the user still needs to answer the cycle-length question.
//  - opened by clicking "Not sure" on the cycle-length picker itself -- here
//    the user has already told us they want to skip, so "Okay, next" also
//    submits the skip.
export default class extends Controller {
  static targets = ['modal', 'skipForm']
  static values = { autoShow: Boolean }

  #pendingSkip = false

  connect () {
    this._onKeydown = (event) => {
      if (event.key === 'Escape') this.hide()
    }
    this.element.addEventListener('keydown', this._onKeydown)

    if (this.autoShowValue) this.show()
  }

  disconnect () {
    this.element.removeEventListener('keydown', this._onKeydown)
  }

  open (event) {
    event.preventDefault()
    this.#pendingSkip = true
    this.show()
  }

  confirm () {
    if (this.#pendingSkip && this.hasSkipFormTarget) {
      this.skipFormTarget.requestSubmit()
      return
    }
    this.hide()
  }

  show () {
    if (!this.hasModalTarget) return
    this.modalTarget.classList.remove('hidden')
    this.modalTarget.querySelector('button')?.focus()
  }

  hide () {
    if (this.hasModalTarget) this.modalTarget.classList.add('hidden')
  }
}
