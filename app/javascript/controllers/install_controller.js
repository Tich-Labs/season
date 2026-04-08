import { Controller } from "@hotwired/stimulus"

// PWA install prompt controller.
// - Android/Chrome: captures beforeinstallprompt and triggers native dialog.
// - iOS Safari: shows an inline instruction sheet (no API available).
// - Standalone (already installed): hides the button entirely.

export default class extends Controller {
  static targets = ["button", "iosHint"]

  connect() {
    // Already running as installed PWA — hide the button
    if (window.matchMedia("(display-mode: standalone)").matches || navigator.standalone) {
      if (this.hasButtonTarget) this.buttonTarget.style.display = "none"
      return
    }

    this._isIOS = /iPad|iPhone|iPod/.test(navigator.userAgent) && !window.MSStream

    if (this._isIOS) {
      // iOS doesn't fire beforeinstallprompt — show manual hint button
      if (this.hasButtonTarget) {
        this.buttonTarget.textContent = "Add to Home Screen"
      }
      return
    }

    // Android / Chrome / Edge: wait for browser install prompt
    window.addEventListener("beforeinstallprompt", (e) => {
      e.preventDefault()
      this._deferredPrompt = e
      if (this.hasButtonTarget) {
        this.buttonTarget.textContent = "Add to Home Screen"
      }
    })

    window.addEventListener("appinstalled", () => {
      this._deferredPrompt = null
      if (this.hasButtonTarget) this.buttonTarget.style.display = "none"
    })
  }

  async install() {
    if (this._isIOS) {
      // Toggle the iOS manual instructions
      if (this.hasIosHintTarget) {
        const hint = this.iosHintTarget
        hint.style.display = hint.style.display === "none" ? "block" : "none"
      }
      return
    }

    if (this._deferredPrompt) {
      this._deferredPrompt.prompt()
      const { outcome } = await this._deferredPrompt.userChoice
      this._deferredPrompt = null
      if (outcome === "accepted" && this.hasButtonTarget) {
        this.buttonTarget.style.display = "none"
      }
    }
  }
}
