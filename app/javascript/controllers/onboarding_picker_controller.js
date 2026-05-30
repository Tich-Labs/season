/* global requestAnimationFrame */
import { Controller } from '@hotwired/stimulus'

const ITEM_HEIGHT = 42

export default class extends Controller {
  static targets = ['input', 'track']

  connect () {
    this.items = Array.from(this.trackTarget.querySelectorAll('.cycle-day-item'))
    requestAnimationFrame(() => this.#scrollToDefault())
    this.trackTarget.addEventListener('scroll', this.#onScroll.bind(this), { passive: true })
  }

  disconnect () {
    this.trackTarget.removeEventListener('scroll', this.#onScroll.bind(this))
  }

  #scrollToDefault () {
    if (this._defaultScrolled) return
    this._defaultScrolled = true
    const defaultValue = parseInt(this.inputTarget.value || '28')
    const idx = this.items.findIndex(el => parseInt(el.dataset.days) === defaultValue)
    if (idx >= 0) {
      this.trackTarget.scrollTop = idx * ITEM_HEIGHT
    }
    this.#applyHighlight()
  }

  #onScroll () {
    if (this._rafId) return
    this._rafId = requestAnimationFrame(() => {
      this._rafId = null
      this.#applyHighlight()
    })
  }

  #applyHighlight () {
    const idx = Math.round(this.trackTarget.scrollTop / ITEM_HEIGHT)
    const clamped = Math.max(0, Math.min(idx, this.items.length - 1))

    this.items.forEach((el, i) => {
      const active = i === clamped
      el.style.opacity = active ? '1' : '0.45'
      el.style.fontSize = active ? '22px' : '16px'
      el.setAttribute('aria-selected', active ? 'true' : 'false')
      if (active) {
        this.inputTarget.value = el.dataset.days
        this.trackTarget.setAttribute('aria-activedescendant', el.id)
      }
    })
  }
}
