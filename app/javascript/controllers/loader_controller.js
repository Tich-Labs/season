import { Controller } from "@hotwired/stimulus"
export default class extends Controller {
  static values = {
    signedIn: Boolean,
    calendarUrl: String,
    welcomeUrl: String,
    appUrl: String
  }
  connect() {
    setTimeout(() => {
      window.location.href = this.welcomeUrlValue
    }, 2000)
  }
}
