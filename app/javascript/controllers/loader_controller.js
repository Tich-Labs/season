import { Controller } from "@hotwired/stimulus"
export default class extends Controller {
  static values = {
    signedIn: Boolean,
    calendarUrl: String,
    welcomeUrl: String
  }
  connect() {
    setTimeout(() => {
      window.location.href = this.signedInValue
        ? this.calendarUrlValue
        : this.welcomeUrlValue
    }, 2000)
  }
}
