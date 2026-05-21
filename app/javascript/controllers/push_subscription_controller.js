import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["status"]

  connect() {
    this._updateStatus()
  }

  async subscribe() {
    if (!("Notification" in window)) return
    const permission = await Notification.requestPermission()
    if (permission !== "granted") return

    const registration = await navigator.serviceWorker.ready
    const subscription = await registration.pushManager.subscribe({
      userVisibleOnly: true,
      applicationServerKey: this._urlBase64ToUint8Array(this.element.dataset.vapidKey)
    })

    await this._sendSubscription(subscription)
    this._updateStatus()
  }

  async unsubscribe() {
    const registration = await navigator.serviceWorker.ready
    const subscription = await registration.pushManager.getSubscription()
    if (subscription) {
      await subscription.unsubscribe()
    }
    await this._sendUnsubscribe()
    this._updateStatus()
  }

  async _sendSubscription(subscription) {
    await fetch("/push/subscribe", {
      method: "POST",
      headers: { "Content-Type": "application/json", "X-CSRF-Token": this._csrf() },
      body: JSON.stringify({
        subscription: subscription.toJSON(),
        device_type: /iPad|iPhone|iPod/.test(navigator.userAgent) && !window.MSStream ? "ios" : "browser"
      })
    })
  }

  async _sendUnsubscribe() {
    await fetch("/push/unsubscribe", { method: "DELETE", headers: { "X-CSRF-Token": this._csrf() } })
  }

  _updateStatus() {
    if (!this.hasStatusTarget) return
    if (!("Notification" in window)) {
      this.statusTarget.textContent = "Not supported"
      return
    }
    if (Notification.permission === "granted") {
      navigator.serviceWorker.ready.then((reg) => {
        reg.pushManager.getSubscription().then((sub) => {
          this.statusTarget.textContent = sub ? "Enabled" : "Off"
        })
      })
    } else {
      this.statusTarget.textContent = Notification.permission === "denied" ? "Blocked" : "Off"
    }
  }

  _csrf() {
    return document.querySelector("meta[name=csrf-token]")?.content
  }

  _urlBase64ToUint8Array(base64String) {
    const padding = "=".repeat((4 - (base64String.length % 4)) % 4)
    const base64 = (base64String + padding).replace(/-/g, "+").replace(/_/g, "/")
    const rawData = window.atob(base64)
    return Uint8Array.from([...rawData].map((char) => char.charCodeAt(0)))
  }
}
