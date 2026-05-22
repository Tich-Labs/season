import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  connect () {
    if (this.isTurboNative()) {
      document.documentElement.classList.add('turbo-native')
      this.disablePWAControllers()
    }
  }

  isTurboNative () {
    return navigator.userAgent.includes('Turbo Native') ||
           document.documentElement.dataset.hotwireNative === 'true'
  }

  disablePWAControllers () {
    document.querySelectorAll("[data-controller~='install']").forEach(el => el.remove())
    document.querySelectorAll("[data-controller~='update-prompt']").forEach(el => el.remove())
  }
}
