/* global requestAnimationFrame cancelAnimationFrame */
import { Controller } from '@hotwired/stimulus'

// Wheel-style value picker. Index 0 in the track is always a "-" item
// (labelled with the placeholder text, e.g. "--", "DD") that means
// "nothing chosen". Real values start at index 1. This makes "no
// selection" an actual list position instead of something the min-value
// item's resting position could be mistaken for — previously, an
// untouched picker sat scrolled-to-top with the min value centred, so
// any incidental scroll event (layout shift, opening the <details>
// panel, etc.) would commit that min value as if the user had picked
// it. Landing back on the dash now explicitly clears the field.
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
    // The old placeholder overlay (`display` target) masked the track
    // to fake a "--" state; that's now just the dash item itself, so
    // the overlay is never shown.
    if (this.hasDisplayTarget) this.displayTarget.style.display = 'none'

    if (this.inputTarget.value) {
      this.#scrollTo(parseFloat(this.inputTarget.value), false)
    }
    this.#highlight()
  }

  disconnect () {
    cancelAnimationFrame(this.#rafId)
    clearTimeout(this.#saveTimer)
  }

  #build () {
    const frag = document.createDocumentFragment()

    const dash = document.createElement('div')
    dash.className = 'sp-item'
    dash.dataset.placeholder = 'true'
    dash.textContent = this.placeholderValue || '-'
    dash.setAttribute('role', 'option')
    frag.appendChild(dash)

    const count = Math.round((this.maxValue - this.minValue) / this.stepValue) + 1
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
    const item = e.target.closest('.sp-item')
    if (!item) return
    if (item.dataset.placeholder) {
      this.#scrollToIndex(0, true)
    } else {
      this.#scrollTo(parseFloat(item.dataset.value), true)
    }
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

  #scrollToIndex (idx, smooth) {
    this.trackTarget.scrollTo({ top: idx * this.#itemHeight, behavior: smooth ? 'smooth' : 'instant' })
  }

  // +1 because index 0 is reserved for the dash item.
  #scrollTo (val, smooth) {
    const idx = Math.round((val - this.minValue) / this.stepValue) + 1
    this.#scrollToIndex(idx, smooth)
  }

  #centredIndex () {
    return Math.round(this.trackTarget.scrollTop / this.#itemHeight)
  }

  #highlight () {
    const centred = this.#centredIndex()
    this.trackTarget.querySelectorAll(':scope > .sp-item').forEach((item, i) => {
      const isCentred = i === centred
      item.style.opacity = isCentred ? '1' : '0.45'
      item.style.fontWeight = isCentred ? '600' : '400'
      item.setAttribute('aria-selected', isCentred.toString())
    })
  }

  #commit () {
    const items = this.trackTarget.querySelectorAll(':scope > .sp-item')
    const item = items[this.#centredIndex()]
    if (!item) return

    if (item.dataset.placeholder) {
      if (this.inputTarget.value === '') return // already empty, nothing to do
      this.inputTarget.value = ''
      if (this.fieldValue) {
        this.dispatch('change', { detail: { field: this.fieldValue, value: '' } })
      }
      return
    }

    const val = parseFloat(item.dataset.value)
    if (isNaN(val)) return
    this.inputTarget.value = val
    if (this.fieldValue) {
      this.dispatch('change', { detail: { field: this.fieldValue, value: val } })
    }
  }
}
