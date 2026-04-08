import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["slider", "panel"]

  open() {
    this.sliderTarget.classList.remove("hidden")
    this.sliderTarget.classList.add("flex")
    requestAnimationFrame(() => {
      this.panelTarget.style.transform = "translateX(0%)"
    })
  }

  close() {
    this.panelTarget.style.transform = "translateX(-100%)"
    setTimeout(() => {
      this.sliderTarget.classList.remove("flex")
      this.sliderTarget.classList.add("hidden")
    }, 300)
  }

  connect() {
    if (this.hasPanelTarget) {
      this.panelTarget.style.transform = "translateX(-100%)"
    }
  }
}