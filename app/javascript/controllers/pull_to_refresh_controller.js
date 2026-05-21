import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["indicator"]

  connect() {
    this.touchStartY = 0
    this.pulling = false
    this.spinner = null

    this.element.addEventListener("touchstart", this._onTouchStart.bind(this), { passive: true })
    this.element.addEventListener("touchmove", this._onTouchMove.bind(this), { passive: false })
    this.element.addEventListener("touchend", this._onTouchEnd.bind(this), { passive: true })
  }

  _onTouchStart(e) {
    if (window.scrollY > 0) return
    this.touchStartY = e.touches[0].clientY
    this.pulling = false
  }

  _onTouchMove(e) {
    if (window.scrollY > 0) return
    const diff = e.touches[0].clientY - this.touchStartY
    if (diff <= 0) return

    this.pulling = true
    const pull = Math.min(diff * 0.4, 80)
    this.element.style.transform = `translateY(${pull}px)`
    this.element.style.transition = "transform 0s"

    if (pull > 60 && !this._indicatorVisible()) {
      this._showIndicator("Release to refresh")
    } else if (pull <= 60 && this._indicatorVisible()) {
      this._showIndicator("Pull down to refresh")
    }
  }

  _onTouchEnd(e) {
    if (!this.pulling) return
    this.pulling = false

    const diff = e.changedTouches[0].clientY - this.touchStartY
    this.element.style.transition = "transform 0.3s ease"

    if (diff > 60) {
      this._showSpinner()
      this.element.style.transform = "translateY(60px)"
      this._refresh()
    } else {
      this.element.style.transform = "translateY(0)"
      this._hideIndicator()
    }
  }

  _refresh() {
    setTimeout(() => {
      Turbo.visit(window.location.href, { action: "replace" })
    }, 500)
  }

  _showIndicator(text) {
    if (!this.hasIndicatorTarget) return
    this.indicatorTarget.textContent = text
    this.indicatorTarget.style.display = "flex"
  }

  _hideIndicator() {
    if (!this.hasIndicatorTarget) return
    this.indicatorTarget.style.display = "none"
  }

  _indicatorVisible() {
    return this.hasIndicatorTarget && this.indicatorTarget.style.display !== "none"
  }

  _showSpinner() {
    if (this.spinner) return
    this.spinner = document.createElement("div")
    this.spinner.innerHTML = `<div style="width:24px;height:24px;border:3px solid #EDE1D5;border-top-color:#933a35;border-radius:50%;animation:ptr-spin 0.6s linear infinite;margin:0 auto;"></div>`
    document.body.prepend(this.spinner)
  }
}
