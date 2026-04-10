import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["track", "dot"]
  static values = { current: { type: Number, default: 0 }, autoplay: { type: Boolean, default: true } }

  connect() {
    this._show(0, false)
    if (this.autoplayValue) {
      this._timer = setInterval(() => this.next(), 4000)
    }
  }

  disconnect() {
    clearInterval(this._timer)
  }

  next() {
    this._show((this.currentValue + 1) % this.dotTargets.length)
  }

  prev() {
    const len = this.dotTargets.length
    this._show((this.currentValue - 1 + len) % len)
  }

  goTo(event) {
    const idx = Number(event.currentTarget.dataset.featureSlidesIndex)
    this._pauseAutoplay()
    this._show(idx)
  }

  touchStart(event) {
    this._touchX = event.changedTouches[0].screenX
  }

  touchEnd(event) {
    if (this._touchX == null) return
    const dx = event.changedTouches[0].screenX - this._touchX
    if (Math.abs(dx) > 40) {
      this._pauseAutoplay()
      dx < 0 ? this.next() : this.prev()
    }
    this._touchX = null
  }

  _show(idx, animate = true) {
    this.currentValue = idx
    this.trackTarget.style.transition = animate ? "transform 0.35s ease" : "none"
    this.trackTarget.style.transform = `translateX(-${idx * 100}%)`
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

  _pauseAutoplay() {
    clearInterval(this._timer)
    this._timer = null
  }
}
