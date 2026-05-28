import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['appointments', 'forecast', 'label', 'leftBar', 'rightBar']
  static values = { colour: String }

  connect () {
    this.showAppointments()
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
}
