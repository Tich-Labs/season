import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["wrapper", "backdrop"]

  open() {
    this.wrapperTarget.classList.remove("hidden")
  }

  close() {
    this.wrapperTarget.classList.add("hidden")
  }

  // Close only when clicking the dark backdrop, not the card
  clickBackdrop(event) {
    if (event.target === this.backdropTarget) this.close()
  }
}
