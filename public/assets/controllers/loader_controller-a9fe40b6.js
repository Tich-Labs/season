import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    signedIn: Boolean,
    calendarUrl: String,
    welcomeUrl: String
  }

  connect() {
    setTimeout(() => {
      if (this.signedInValue) {
        window.location.href = this.calendarUrlValue
      } else {
        window.location.href = this.welcomeUrlValue
      }
    }, 2000)
  }
}