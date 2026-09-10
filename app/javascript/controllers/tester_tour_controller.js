import { Controller } from '@hotwired/stimulus'

// Drives the first-run beta-tester welcome tour
// (app/views/tester_tour/show.html.erb) — simple linear paging through
// static slides, no per-slide validation. The last slide's button posts
// to /welcome_tour/complete (marks tester_tour_seen_at) and redirects.
export default class extends Controller {
  static targets = ['slide', 'dot', 'nextBtn', 'root']
  static values = { completeUrl: String }

  connect () {
    this.index = 0
    this._updateBackground()
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
    this._updateBackground()
  }

  // The intro slide fills the screen with the brand-field colour; every
  // walkthrough slide sits on white beneath the (always beige) header.
  _updateBackground () {
    const root = this.hasRootTarget ? this.rootTarget : this.element
    root.classList.toggle('bg-brand-field', this.index === 0)
    root.classList.toggle('bg-white', this.index !== 0)
  }

  // Figma: 12px-tall dots in phase-ovulation green; the active one is a
  // 52px pill, the rest are 12px and dimmed to 30%.
  _updateDots () {
    this.dotTargets.forEach((dot, i) => {
      const active = i === this.index
      dot.classList.toggle('w-[52px]', active)
      dot.classList.toggle('w-3', !active)
      dot.classList.toggle('opacity-30', !active)
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
