import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static values = {
    signedIn: Boolean,
    pinPending: Boolean,
    calendarUrl: String,
    welcomeUrl: String
  }

  connect () {
    // PIN unlock renders inline as a modal over /calendar now (see pin/_unlock_modal),
    // so there's no separate unlock destination to route to and no reason to sit
    // through the splash delay first — go straight there.
    if (this.pinPendingValue) {
      window.location.href = this.calendarUrlValue
      return
    }

    setTimeout(() => {
      if (this.signedInValue) {
        window.location.href = this.calendarUrlValue
      } else {
        window.location.href = this.welcomeUrlValue
      }
    }, 2000)
  }
}
