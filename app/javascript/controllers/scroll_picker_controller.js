/* global requestAnimationFrame cancelAnimationFrame */
import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['track', 'input', 'display']
  static values = {
    min: Number,
    max: Number,
    step: { type: Number, default: 1 },
    unit: String,
    field: String,
    placeholder: String
  }

  #itemHeight = 42
  #rafId = null
  #saveTimer = null

  connect () {
    this.#build()
    if (this.inputTarget.value) {
      this.#scrollTo(parseFloat(this.inputTarget.value), false)
      this.#updateDisplay()
    } else if (this.placeholder) {
      this.#showPlaceholder()
    }
    this.#highlight()
  }

  get placeholder () {
    return this.element.dataset.scrollPickerPlaceholder || this.placeholderValue
  }

  disconnect () {
    cancelAnimationFrame(this.#rafId)
    clearTimeout(this.#saveTimer)
  }

  #build () {
    const count = Math.round((this.maxValue - this.minValue) / this.stepValue) + 1
    const frag = document.createDocumentFragment()
    for (let i = 0; i < count; i++) {
      const val = +(this.minValue + i * this.stepValue).toFixed(1)
      const el = document.createElement('div')
      el.className = 'sp-item'
      el.dataset.value = val
      el.textContent = Number.isInteger(val) ? val.toString() : val.toFixed(1)
      el.setAttribute('role', 'option')
      frag.appendChild(el)
    }
    this.trackTarget.appendChild(frag)
  }

  scroll () {
    if (this.#rafId) return
    this.#rafId = requestAnimationFrame(() => {
      this.#rafId = null
      this.#highlight()
      clearTimeout(this.#saveTimer)
      this.#saveTimer = setTimeout(() => this.#commit(), 80)
    })
  }

  click (e) {
    const item = e.target.closest('[data-value]')
    if (!item) return
    this.#scrollTo(parseFloat(item.dataset.value), true)
    clearTimeout(this.#saveTimer)
    this.#saveTimer = setTimeout(() => this.#commit(), 300)
  }

  keydown (e) {
    const current = parseFloat(this.inputTarget.value)
    if (isNaN(current)) return
    let next
    if (e.key === 'ArrowDown') {
      e.preventDefault()
      next = Math.min(current + this.stepValue, this.maxValue)
    } else if (e.key === 'ArrowUp') {
      e.preventDefault()
      next = Math.max(current - this.stepValue, this.minValue)
    } else return
    this.#scrollTo(next, true)
  }

  #scrollTo (val, smooth) {
    const idx = Math.round((val - this.minValue) / this.stepValue)
    const targetScroll = idx * this.#itemHeight
    this.trackTarget.scrollTo({ top: targetScroll, behavior: smooth ? 'smooth' : 'instant' })
  }

  #centredIndex () {
    return Math.round(this.trackTarget.scrollTop / this.#itemHeight)
  }

  #highlight () {
    const centred = this.#centredIndex()
    this.trackTarget.querySelectorAll(':scope > [data-value]').forEach((item, i) => {
      const isCentred = i === centred
      item.style.opacity = isCentred ? '1' : '0.45'
      item.style.fontWeight = isCentred ? '600' : '400'
      item.setAttribute('aria-selected', isCentred.toString())
    })
  }

  // The scroll track's own highlighted/centered item already shows the
  // picked value, and the unit has its own static label beside the picker —
  // so once a real value exists, the overlay (used only for the "--"
  // placeholder in #showPlaceholder) needs to get out of the way entirely,
  // not just lose its text, since its background would otherwise mask the
  // track item sitting underneath it.
  #updateDisplay () {
    if (this.hasDisplayTarget) {
      this.displayTarget.style.display = 'none'
    }
  }

  #commit () {
    const items = this.trackTarget.querySelectorAll(':scope > [data-value]')
    const centred = this.#centredIndex()
    const item = items[centred]
    if (!item) return
    const val = parseFloat(item.dataset.value)
    if (isNaN(val)) return
    this.inputTarget.value = val
    this.#updateDisplay()
    if (this.fieldValue) {
      this.dispatch('change', { detail: { field: this.fieldValue, value: val } })
    }
  }

  #showPlaceholder () {
    if (this.hasDisplayTarget) {
      this.displayTarget.style.display = ''
      this.displayTarget.textContent = this.placeholder
    }
  }
}
