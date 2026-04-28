import { Controller } from "@hotwired/stimulus"

const MODAL_SELECTOR = "#feedback-modal-container"
const MENU_SELECTOR = "#burger-menu"

export default class extends Controller {
  static targets = ["wrapper", "backdrop"]

  connect() {
    this._checkModals = () => this.checkModals()
    this.checkModals()
    document.addEventListener("turbo:load", this._checkModals)
  }

  disconnect() {
    document.removeEventListener("turbo:load", this._checkModals)
  }

  checkModals() {
    this.element.hidden = this._anyOverlayOpen()
  }

  open() {
    if (this._anyOverlayOpen()) return
    this.wrapperTarget.classList.remove("hidden")
  }

  close() {
    this.wrapperTarget.classList.add("hidden")
  }

  clickBackdrop(event) {
    if (event.target === this.backdropTarget) this.close()
  }

  _anyOverlayOpen() {
    return (
      document.querySelector(MODAL_SELECTOR)?.style.display === "flex" ||
      document.querySelector(MENU_SELECTOR)?.classList.contains("flex")
    )
  }
}
