import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['card']

  close () {
    this.cardTarget.style.display = 'none'
  }
}
