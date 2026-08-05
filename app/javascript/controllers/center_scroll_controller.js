import { Controller } from '@hotwired/stimulus'

// Scrolls a horizontally-scrollable container so its marked "current" child
// is centered on load, instead of defaulting to scrollLeft: 0.
export default class extends Controller {
  static targets = ['current']

  connect () {
    if (!this.hasCurrentTarget) return

    const container = this.element
    const target = this.currentTarget

    // getBoundingClientRect avoids relying on offsetLeft's offsetParent chain,
    // which can land outside `container` and throw the centering off.
    const containerRect = container.getBoundingClientRect()
    const targetRect = target.getBoundingClientRect()
    const targetOffset = (targetRect.left - containerRect.left) + container.scrollLeft

    container.scrollLeft = targetOffset - (container.clientWidth / 2) + (target.offsetWidth / 2)
  }
}
