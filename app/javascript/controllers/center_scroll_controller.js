import { Controller } from '@hotwired/stimulus'

// Scrolls a horizontally-scrollable container so its marked "current" child
// is centered on load, instead of defaulting to scrollLeft: 0.
export default class extends Controller {
  static targets = ['current']

  connect () {
    if (!this.hasCurrentTarget) return

    const container = this.element
    const target = this.currentTarget
    container.scrollLeft = target.offsetLeft - (container.clientWidth / 2) + (target.offsetWidth / 2)
  }
}
