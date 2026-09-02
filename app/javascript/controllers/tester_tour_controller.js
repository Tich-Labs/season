import { Controller } from '@hotwired/stimulus'

// Drives the first-run beta-tester welcome tour
// (app/views/tester_tour/show.html.erb) — simple linear paging through
// static slides, no per-slide validation. The last slide's button posts
// to /welcome_tour/complete (marks tester_tour_seen_at) and redirects.
export default class extends Controller {
  static targets = ['slide', 'dot', 'nextBtn']
  static values = { completeUrl: String }

  connect () {
    this.index = 0
  }

  advance () {
    const isLast = this.index === this.slideTargets.length - 1
    if (isLast) {
      this._complete()
      return
    }

    this.slideTargets[this.index].hidden = true
    this.index += 1
    this.slideTargets[this.index].hidden = false
    this._updateDots()
    this._updateButtonLabel()
  }

  _updateDots () {
    this.dotTargets.forEach((dot, i) => {
      dot.classList.toggle('bg-phase-follicular', i === this.index)
      dot.classList.toggle('bg-brand-field', i !== this.index)
    })
  }

  _updateButtonLabel () {
    const isLast = this.index === this.slideTargets.length - 1
    this.nextBtnTarget.textContent = isLast
      ? (this.nextBtnTarget.dataset.finishLabel || 'Get started')
      : (this.nextBtnTarget.dataset.nextLabel || 'Next')
  }

  async _complete () {
    const token = document.querySelector('meta[name="csrf-token"]')?.content
    this.nextBtnTarget.disabled = true

    try {
      await fetch(this.completeUrlValue, {
        method: 'POST',
        headers: { 'X-CSRF-Token': token }
      })
    } catch (e) {
      // fall through — still navigate the user forward
    }

    window.location.href = '/calendar'
  }
}
