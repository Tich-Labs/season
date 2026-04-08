import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    if ('serviceWorker' in navigator) {
      this.checkForUpdate()
    }
  }

  async checkForUpdate() {
    try {
      const registration = await navigator.serviceWorker.getRegistration()
      
      if (registration) {
        registration.addEventListener('updatefound', () => {
          const newWorker = registration.installing
          
          newWorker.addEventListener('statechange', () => {
            if (newWorker.state === 'installed' && navigator.serviceWorker.controller) {
              this.showUpdatePrompt()
            }
          })
        })

        // Check if there's already a waiting worker
        if (registration.waiting) {
          this.showUpdatePrompt()
        }
      }
    } catch (error) {
      console.error('SW check failed:', error)
    }
  }

  showUpdatePrompt() {
    if (confirm('A new version of Season is available. Update now for the latest features?')) {
      this.updateApp()
    }
  }

  updateApp() {
    navigator.serviceWorker.getRegistration().then((registration) => {
      if (registration && registration.waiting) {
        registration.waiting.postMessage({ type: 'SKIP_WAITING' })
      }
      window.location.reload()
    })
  }
}