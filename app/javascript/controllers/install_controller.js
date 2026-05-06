import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["banner", "button", "iosHint"]

  connect() {
    // Already running as installed PWA — nothing to show
    if (window.matchMedia("(display-mode: standalone)").matches || navigator.standalone) {
      return
    }

    // User already dismissed this session
    if (sessionStorage.getItem('pwaInstallDismissed')) return

    this._isIOS = /iPad|iPhone|iPod/.test(navigator.userAgent) && !window.MSStream

    if (this._isIOS) {
      this._showBanner()
      return
    }

    // Android / Chrome / Edge: wait for browser install event
    window.addEventListener("beforeinstallprompt", (e) => {
      e.preventDefault()
      this._deferredPrompt = e
      this._showBanner()
    })

    window.addEventListener("appinstalled", () => {
      this._deferredPrompt = null
      this._hideBanner()
    })
  }

  async install() {
    if (this._isIOS) {
      if (this.hasIosHintTarget) {
        this.iosHintTarget.classList.toggle('hidden')
      }
      return
    }

    if (this._deferredPrompt) {
      this._deferredPrompt.prompt()
      const { outcome } = await this._deferredPrompt.userChoice
      this._deferredPrompt = null
      if (outcome === 'accepted') this._hideBanner()
    }
  }

  dismiss() {
    sessionStorage.setItem('pwaInstallDismissed', '1')
    this._hideBanner()
  }

  _showBanner() {
    if (this.hasBannerTarget) this.bannerTarget.classList.remove('hidden')
  }

  _hideBanner() {
    if (this.hasBannerTarget) this.bannerTarget.classList.add('hidden')
  }
}
