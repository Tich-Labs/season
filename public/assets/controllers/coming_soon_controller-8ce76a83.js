import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["toast"]

  show() {
    if (!this.hasToastTarget) return
    this.toastTarget.style.display = "block"
    clearTimeout(this._timer)
    this._timer = setTimeout(() => {
      this.toastTarget.style.display = "none"
    }, 3000)
  }

  disconnect() {
    clearTimeout(this._timer)
  }
}
