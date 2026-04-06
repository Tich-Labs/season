import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["days", "hours", "minutes", "seconds"]
  static values = { targetDate: String }

  connect() {
    this.tick()
    this.interval = window.setInterval(() => this.tick(), 1000)
  }

  disconnect() {
    window.clearInterval(this.interval)
  }

  tick() {
    const targetTime = new Date(this.targetDateValue).getTime()
    const remainingMilliseconds = Math.max(targetTime - Date.now(), 0)

    const totalSeconds = Math.floor(remainingMilliseconds / 1000)
    const days = Math.floor(totalSeconds / 86400)
    const hours = Math.floor((totalSeconds % 86400) / 3600)
    const minutes = Math.floor((totalSeconds % 3600) / 60)
    const seconds = totalSeconds % 60

    this.daysTarget.textContent = this.formatUnit(days)
    this.hoursTarget.textContent = this.formatUnit(hours)
    this.minutesTarget.textContent = this.formatUnit(minutes)
    this.secondsTarget.textContent = this.formatUnit(seconds)
  }

  formatUnit(value) {
    return value.toString().padStart(2, "0")
  }
}