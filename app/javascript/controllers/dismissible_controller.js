import { Controller } from '@hotwired/stimulus'

// Auto-dismissing banner (Daily Analysis card on /tracking). Shows once per
// natural /tracking load and fades out on its own (~10s) or when the user
// taps the × button.
export default class extends Controller {
  static targets = ['card']

  connect () {
    this.autoCloseTimer = setTimeout(() => this.close(), 10000)
  }

  disconnect () {
    clearTimeout(this.autoCloseTimer)
  }

  close () {
    this.cardTarget.style.display = 'none'
  }
}
