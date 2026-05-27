/* global requestAnimationFrame */
import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['display', 'track']
  static values = {
    min: Number,
    max: Number,
    step: Number,
    value: { type: Number, default: 0 },
    unit: String,
    field: String
  }

  connect () {
    this._build()
    requestAnimationFrame(() => {
      this._scrollToCurrent()
      this._updateDisplay()
    })
  }

  _build () {
    const track = this.trackTarget
    const count = Math.round((this.maxValue - this.minValue) / this.stepValue) + 1
    const frag = document.createDocumentFragment()

    for (let i = 0; i < count; i++) {
      const val = +(this.minValue + i * this.stepValue).toFixed(1)
      const item = document.createElement('div')
      item.className = 'vp-item'
      item.dataset.value = val
      item.textContent = Number.isInteger(val) ? val : val.toFixed(1)
      frag.appendChild(item)
    }
    track.appendChild(frag)
  }

  _scrollToCurrent () {
    const val = this.valueValue || this.minValue
    const idx = Math.round((val - this.minValue) / this.stepValue)
    const item = this.trackTarget.children[idx]
    if (item) {
      item.scrollIntoView({ block: 'center', behavior: 'instant' })
    }
  }

  scroll () {
    if (this._rafId) return
    this._rafId = requestAnimationFrame(() => {
      this._rafId = null
      this._updateDisplay()
      clearTimeout(this._saveTimer)
      this._saveTimer = setTimeout(() => this.#commit(), 500)
    })
  }

  _updateDisplay () {
    const item = this.#closestItem()
    if (item) {
      this.displayTarget.textContent = `${item.dataset.value}${this.unitValue}`
    }
  }

  #commit () {
    const item = this.#closestItem()
    if (!item) return
    item.scrollIntoView({ block: 'center', behavior: 'smooth' })
    const val = parseFloat(item.dataset.value)
    this.dispatch('change', { detail: { field: this.fieldValue, value: val } })
  }

  #closestItem () {
    const track = this.trackTarget
    const rect = track.getBoundingClientRect()
    const centerY = rect.top + rect.height / 2
    let closest = null
    let minDist = Infinity

    for (const item of track.children) {
      const ir = item.getBoundingClientRect()
      const dist = Math.abs(ir.top + ir.height / 2 - centerY)
      if (dist < minDist) {
        minDist = dist
        closest = item
      }
    }
    return closest
  }
}
