import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.supportsVibration = "vibrate" in navigator
    this.supportsTouch = "ontouchstart" in window
  }

  light(event) {
    this._vibrate(10)
  }

  medium(event) {
    this._vibrate(20)
  }

  heavy(event) {
    this._vibrate([30, 20, 30])
  }

  selection(event) {
    this._vibrate(5)
  }

  success(event) {
    this._vibrate([15, 10, 15])
  }

  error(event) {
    this._vibrate([30, 30, 30])
  }

  _vibrate(pattern) {
    if (!this.supportsVibration) return
    try {
      navigator.vibrate(pattern)
    } catch (e) {
      /* silently ignore */
    }
  }
}
