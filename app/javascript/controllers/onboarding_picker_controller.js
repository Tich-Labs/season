import { Controller } from '@hotwired/stimulus'

// Cycle-length scroll picker for onboarding step 6.
// Reads scroll position on the snap-track, highlights the centred item,
// and keeps the hidden <input> in sync so the form always submits the
// day the user has scrolled to.
export default class extends Controller {
  static targets = ['track', 'input']

  #itemHeight = 42
  #debounceTimer = null

  connect () {
    // Scroll to the current value (default 28) without animation
    const initial = parseInt(this.inputTarget.value) || 28
    this.#scrollToValue(initial, false)
    this.#highlightCentred()

    this.trackTarget.addEventListener('scroll', () => this.#onScroll(), { passive: true })
    this.trackTarget.addEventListener('click', (e) => this.#onClick(e))
    this.trackTarget.addEventListener('keydown', (e) => this.#onKeydown(e))
  }

  disconnect () {
    clearTimeout(this.#debounceTimer)
  }

  #onScroll () {
    // Debounce: wait for scroll to settle before committing
    clearTimeout(this.#debounceTimer)
    this.#debounceTimer = setTimeout(() => {
      this.#highlightCentred()
      this.#commitCentred()
    }, 80)
  }

  #onClick (event) {
    const item = event.target.closest('[data-days]')
    if (!item) return
    const days = parseInt(item.dataset.days)
    this.#scrollToValue(days, true)
    // commit after animation
    clearTimeout(this.#debounceTimer)
    this.#debounceTimer = setTimeout(() => {
      this.#highlightCentred()
      this.#commitCentred()
    }, 300)
  }

  #onKeydown (event) {
    const current = parseInt(this.inputTarget.value) || 28
    if (event.key === 'ArrowDown') {
      event.preventDefault()
      this.#scrollToValue(Math.min(current + 1, 45), true)
    } else if (event.key === 'ArrowUp') {
      event.preventDefault()
      this.#scrollToValue(Math.max(current - 1, 20), true)
    }
  }

  #scrollToValue (days, smooth) {
    const items = this.trackTarget.querySelectorAll('[data-days]')
    const firstDay = parseInt(items[0]?.dataset.days || 20)
    const index = days - firstDay
    const targetScroll = index * this.#itemHeight
    this.trackTarget.scrollTo({ top: targetScroll, behavior: smooth ? 'smooth' : 'instant' })
  }

  #centredIndex () {
    // The scroll container has 84px padding at top/bottom so the centred
    // item sits at scrollTop + 84px from the visible top of the container.
    const scrollTop = this.trackTarget.scrollTop
    return Math.round(scrollTop / this.#itemHeight)
  }

  #highlightCentred () {
    const centred = this.#centredIndex()
    this.trackTarget.querySelectorAll('[data-days]').forEach((item, i) => {
      const isCentred = i === centred
      item.style.opacity = isCentred ? '1' : '0.45'
      item.style.fontWeight = isCentred ? '600' : '400'
      item.setAttribute('aria-selected', isCentred ? 'true' : 'false')
    })
  }

  #commitCentred () {
    const items = this.trackTarget.querySelectorAll('[data-days]')
    const centred = this.#centredIndex()
    const item = items[centred]
    if (!item) return
    const days = parseInt(item.dataset.days)
    if (!isNaN(days)) {
      this.inputTarget.value = days
    }
  }
}
