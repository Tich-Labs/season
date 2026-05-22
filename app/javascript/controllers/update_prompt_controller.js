import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['banner']

  connect () {
    if (!('serviceWorker' in navigator)) return
    this._listenForUpdates()
  }

  async _listenForUpdates () {
    try {
      const registration = await navigator.serviceWorker.getRegistration()
      if (!registration) return

      if (registration.waiting) {
        this._showBanner()
        return
      }

      registration.addEventListener('updatefound', () => {
        const newWorker = registration.installing
        if (!newWorker) return
        newWorker.addEventListener('statechange', () => {
          if (newWorker.state === 'installed' && navigator.serviceWorker.controller) {
            this._showBanner()
          }
        })
      })
    } catch (_) {}
  }

  updateApp () {
    navigator.serviceWorker.getRegistration().then(registration => {
      if (registration && registration.waiting) {
        navigator.serviceWorker.addEventListener('controllerchange', () => {
          window.location.reload()
        })
        registration.waiting.postMessage({ type: 'SKIP_WAITING' })
      } else {
        window.location.reload()
      }
    })
  }

  _showBanner () {
    if (this.hasBannerTarget) this.bannerTarget.classList.remove('hidden')
  }
}
