import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static values = {
    delay: { type: Number, default: 50 }
  }

  connect () {
    this.timer = setTimeout(() => this.dismiss(), this.delayValue * 1000)
  }

  disconnect () {
    if (this.timer) clearTimeout(this.timer)
  }

  dismiss () {
    this.element.style.display = 'none'
    if (this.timer) clearTimeout(this.timer)
  }
}
