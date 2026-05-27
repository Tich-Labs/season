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
      const tick = document.createElement('div')
      tick.className = 'picker-tick'
      tick.dataset.value = val

      if (val % 1 === 0) {
        tick.classList.add('picker-tick--major')
        tick.textContent = val
      } else if (val % 0.5 === 0) {
        tick.classList.add('picker-tick--mid')
      }
      frag.appendChild(tick)
    }
    track.appendChild(frag)
  }

  _scrollToCurrent () {
    const val = this.valueValue || this.minValue
    const idx = Math.round((val - this.minValue) / this.stepValue)
    const tick = this.trackTarget.children[idx]
    if (tick) {
      tick.scrollIntoView({ inline: 'center', block: 'nearest', behavior: 'instant' })
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
    const tick = this.#closestTick()
    if (tick) {
      this.displayTarget.textContent = `${tick.dataset.value}${this.unitValue}`
    }
  }

  #commit () {
    const tick = this.#closestTick()
    if (!tick) return
    tick.scrollIntoView({ inline: 'center', block: 'nearest', behavior: 'smooth' })
    const val = parseFloat(tick.dataset.value)
    this.dispatch('change', { detail: { field: this.fieldValue, value: val } })
  }

  #closestTick () {
    const track = this.trackTarget
    const rect = track.getBoundingClientRect()
    const centerX = rect.left + rect.width / 2
    let closest = null
    let minDist = Infinity

    for (const tick of track.children) {
      const tr = tick.getBoundingClientRect()
      const dist = Math.abs(tr.left + tr.width / 2 - centerX)
      if (dist < minDist) {
        minDist = dist
        closest = tick
      }
    }
    return closest
  }
}
