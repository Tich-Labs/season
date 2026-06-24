import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  connect () {
    if (this.isNative()) {
      document.documentElement.classList.add('ruby-native')
      this.disablePWAControllers()
    }
  }

  isNative () {
    return navigator.userAgent.includes('Ruby Native') ||
           document.documentElement.dataset.rubyNative === 'true'
  }

  disablePWAControllers () {
    document.querySelectorAll("[data-controller~='install']").forEach(el => el.remove())
    document.querySelectorAll("[data-controller~='update-prompt']").forEach(el => el.remove())
  }
}
