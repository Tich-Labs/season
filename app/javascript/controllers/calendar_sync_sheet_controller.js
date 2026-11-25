import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['sheet']

  open () {
    this.sheetTarget.style.display = 'flex'
  }

  close () {
    this.sheetTarget.style.display = 'none'
  }

  clickOutside (event) {
    if (event.target === this.sheetTarget) this.close()
  }
}
