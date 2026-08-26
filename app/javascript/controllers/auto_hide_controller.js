import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['element']
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
    const el = this.hasElementTarget ? this.elementTarget : this.element
    el.style.transition = 'opacity 500ms ease-out'
    el.style.opacity = '0'
    setTimeout(() => { el.style.display = 'none' }, 500)
    if (this.timer) clearTimeout(this.timer)
  }
}
