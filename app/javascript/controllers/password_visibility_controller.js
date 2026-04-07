import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "eyeOpen", "eyeClosed"]

  toggle() {
    const isPassword = this.inputTarget.type === "password"
    this.inputTarget.type = isPassword ? "text" : "password"
    if (this.hasEyeOpenTarget)  this.eyeOpenTarget.classList.toggle("hidden", !isPassword)
    if (this.hasEyeClosedTarget) this.eyeClosedTarget.classList.toggle("hidden", isPassword)
  }
}
