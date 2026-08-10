/* global Notification */import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['status', 'toggle']

  connect () {
    this._updateStatus()
    this._syncToggle()
  }

  // Single entry point for the visible switch — routes to subscribe/unsubscribe
  // based on which way it's being flipped, instead of always subscribing
  // (which used to fire on every click, including turning it off).
  async toggle () {
    const willEnable = this.hasToggleTarget && !this.toggleTarget.classList.contains('active')
    if (willEnable) {
      await this.subscribe()
    } else {
      await this.unsubscribe()
    }
    this._syncToggle()
  }

  async subscribe () {
    if (!('Notification' in window)) return
    const permission = await Notification.requestPermission()
    if (permission !== 'granted') return

    const registration = await navigator.serviceWorker.ready
    const subscription = await registration.pushManager.subscribe({
      userVisibleOnly: true,
      applicationServerKey: this._urlBase64ToUint8Array(this.element.dataset.vapidKey)
    })

    await this._sendSubscription(subscription)
    this._updateStatus()
  }

  async unsubscribe () {
    const registration = await navigator.serviceWorker.ready
    const subscription = await registration.pushManager.getSubscription()
    if (subscription) {
      await subscription.unsubscribe()
    }
    await this._sendUnsubscribe()
    this._updateStatus()
  }

  async _sendSubscription (subscription) {
    await fetch('/push/subscribe', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'X-CSRF-Token': this._csrf() },
      body: JSON.stringify({
        subscription: subscription.toJSON(),
        device_type: /iPad|iPhone|iPod/.test(navigator.userAgent) && !window.MSStream ? 'ios' : 'browser'
      })
    })
  }

  async _sendUnsubscribe () {
    await fetch('/push/unsubscribe', { method: 'DELETE', headers: { 'X-CSRF-Token': this._csrf() } })
  }

  _updateStatus () {
    if (!this.hasStatusTarget) return
    if (!('Notification' in window)) {
      this.statusTarget.textContent = 'Not supported'
      return
    }
    if (Notification.permission === 'granted') {
      navigator.serviceWorker.ready.then((reg) => {
        reg.pushManager.getSubscription().then((sub) => {
          this.statusTarget.textContent = sub ? 'Enabled' : 'Off'
        })
      })
    } else {
      this.statusTarget.textContent = Notification.permission === 'denied' ? 'Blocked' : 'Off'
    }
  }

  // Reflects real subscription state on the switch — not just whatever was
  // last clicked — so e.g. a denied permission prompt correctly snaps the
  // toggle back off instead of showing on.
  _syncToggle () {
    if (!this.hasToggleTarget) return
    if (!('Notification' in window) || Notification.permission !== 'granted') {
      this.toggleTarget.classList.remove('active')
      this.toggleTarget.setAttribute('aria-checked', 'false')
      return
    }
    navigator.serviceWorker.ready.then((reg) => {
      reg.pushManager.getSubscription().then((sub) => {
        this.toggleTarget.classList.toggle('active', !!sub)
        this.toggleTarget.setAttribute('aria-checked', String(!!sub))
      })
    })
  }

  _csrf () {
    return document.querySelector('meta[name=csrf-token]')?.content
  }

  _urlBase64ToUint8Array (base64String) {
    const padding = '='.repeat((4 - (base64String.length % 4)) % 4)
    const base64 = (base64String + padding).replace(/-/g, '+').replace(/_/g, '/')
    const rawData = window.atob(base64)
    return Uint8Array.from([...rawData].map((char) => char.charCodeAt(0)))
  }
}
