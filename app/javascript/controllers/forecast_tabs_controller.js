import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['appointments', 'forecast', 'label', 'leftBar', 'rightBar']
  static values = { colour: String, default: { type: String, default: 'appointments' } }

  connect () {
    this.defaultValue === 'forecast' ? this.showForecast() : this.showAppointments()
    this._startX = 0
    this._registerSwipeHandlers()
  }

  disconnect () {
    this._removeSwipeHandlers()
  }

  showAppointments () {
    this.appointmentsTarget.classList.remove('hidden')
    this.forecastTarget.classList.add('hidden')
    this.labelTarget.textContent = 'And this is your day:'
    this.leftBarTarget.style.background = this.colourValue
    this.rightBarTarget.style.background = this.colourValue + '33'
  }

  showForecast () {
    this.appointmentsTarget.classList.add('hidden')
    this.forecastTarget.classList.remove('hidden')
    this.labelTarget.textContent = 'Here are your tips for today:'
    this.rightBarTarget.style.background = this.colourValue
    this.leftBarTarget.style.background = this.colourValue + '33'
  }

  _registerSwipeHandlers () {
    this._onTouchStart = (e) => { this._startX = e.touches[0].clientX }
    this._onTouchEnd = (e) => {
      const deltaX = e.changedTouches[0].clientX - this._startX
      if (Math.abs(deltaX) < 50) return
      const onAppointments = !this.appointmentsTarget.classList.contains('hidden')
      const onForecast = !this.forecastTarget.classList.contains('hidden')
      if (deltaX < -50 && onAppointments) this.showForecast()
      if (deltaX > 50 && onForecast) this.showAppointments()
    }
    this.element.addEventListener('touchstart', this._onTouchStart, { passive: true })
    this.element.addEventListener('touchend', this._onTouchEnd, { passive: true })
  }

  _removeSwipeHandlers () {
    if (this._onTouchStart) this.element.removeEventListener('touchstart', this._onTouchStart)
    if (this._onTouchEnd) this.element.removeEventListener('touchend', this._onTouchEnd)
  }
}
