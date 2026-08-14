/* global sessionStorage */
import { Controller } from '@hotwired/stimulus'

const DISMISSED_KEY = 'noCycleDataModalDismissed'

// Figma node 12048-15617 — full-screen "no data yet" state on first calendar
// load for a user with no cycle data. Same dismiss-for-this-session pattern
// as install_controller.js's PWA banner.
export default class extends Controller {
  connect () {
    if (sessionStorage.getItem(DISMISSED_KEY)) {
      this.element.remove()
    }
  }

  close () {
    sessionStorage.setItem(DISMISSED_KEY, '1')
    this.element.remove()
  }
}
