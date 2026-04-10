import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["slide", "dot", "prevBtn", "nextBtn"]
  static values = { current: { type: Number, default: 0 }, autoplay: { type: Boolean, default: true } }

  connect() {
    this.show(0)
    if (this.autoplayValue) {
      this._timer = setInterval(() => this.next(), 4000)
    }
  }

  disconnect() {
    clearInterval(this._timer)
  }

  next() {
    this.show((this.currentValue + 1) % this.slideTargets.length)
  }

  prev() {
    const len = this.slideTargets.length
    this.show((this.currentValue - 1 + len) % len)
  }

  goTo(event) {
    const idx = Number(event.currentTarget.dataset.featureSlidesIndex)
    clearInterval(this._timer)
    this._timer = null
    this.show(idx)
  }

  show(idx) {
    this.currentValue = idx
    this.slideTargets.forEach((slide, i) => {
      slide.classList.toggle("hidden", i !== idx)
    })
    this.dotTargets.forEach((dot, i) => {
      if (i === idx) {
        dot.classList.remove("opacity-30", "w-3")
        dot.classList.add("w-[52px]")
      } else {
        dot.classList.remove("w-[52px]")
        dot.classList.add("opacity-30", "w-3")
      }
    })
  }

  // Pause auto-advance on manual interaction
  _pauseAutoplay() {
    clearInterval(this._timer)
    this._timer = null
  }

  // Touch / swipe support
  touchStart(event) {
    this._touchStartX = event.changedTouches[0].screenX
  }

  touchEnd(event) {
    if (this._touchStartX == null) return
    const dx = event.changedTouches[0].screenX - this._touchStartX
    if (Math.abs(dx) > 40) {
      this._pauseAutoplay()
      dx < 0 ? this.next() : this.prev()
    }
    this._touchStartX = null
  }
}
