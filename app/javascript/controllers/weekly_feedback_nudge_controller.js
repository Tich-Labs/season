import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  open () {
    document.dispatchEvent(
      new CustomEvent('weekly-feedback:open')
    )
  }

  dismiss (event) {
    this.element.style.display = 'none'
  }
}
