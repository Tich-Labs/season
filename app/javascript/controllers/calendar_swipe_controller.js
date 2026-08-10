/* global Turbo */
import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static values = {
    prevUrl: String,
    nextUrl: String
  }

  connect () {
    if (!('ontouchstart' in window) && navigator.maxTouchPoints <= 0) return

    this.tracking = false
    this.moved = false
    this.startX = 0
    this.startY = 0

    this.element.addEventListener('touchstart', this._onTouchStart.bind(this), { passive: true })
    this.element.addEventListener('touchmove', this._onTouchMove.bind(this), { passive: false })
    this.element.addEventListener('touchend', this._onTouchEnd.bind(this), { passive: true })
  }

  _onTouchStart (e) {
    if (e.touches.length !== 1) return
    this.tracking = true
    this.moved = false
    this.startX = e.touches[0].clientX
    this.startY = e.touches[0].clientY
  }

  _onTouchMove (e) {
    if (!this.tracking) return
    const dx = e.touches[0].clientX - this.startX
    const dy = e.touches[0].clientY - this.startY

    if (Math.abs(dx) < 12 && Math.abs(dy) < 12) return
    if (Math.abs(dy) > Math.abs(dx)) {
      this.tracking = false
      return
    }
    if (Math.abs(dx) > 20) {
      this.moved = true
      e.preventDefault()
    }
  }

  _onTouchEnd (e) {
    if (!this.tracking || !this.moved) {
      this.tracking = false
      this.moved = false
      return
    }
    const dx = e.changedTouches[0].clientX - this.startX
    this.tracking = false
    this.moved = false
    if (Math.abs(dx) < 50) return

    Turbo.visit(dx < 0 ? this.nextUrlValue : this.prevUrlValue, { action: 'replace' })
  }
}
