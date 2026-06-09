import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['display', 'edit', 'hourSelect', 'minuteSelect', 'ampmSelect', 'field']
  static values = {
    hour: { type: Number, default: 12 },
    minute: { type: Number, default: 0 },
    ampm: { type: String, default: 'AM' }
  }

  connect () {
    this.#commit()
    this.#syncFromField()
    this.element.addEventListener('form-persistence:restored', () => {
      this.#syncFromField()
    })
  }

  open () {
    if (!this.editTarget.classList.contains('hidden')) return

    this.displayTarget.classList.add('hidden')
    this.editTarget.classList.remove('hidden')
    this.editTarget.classList.add('inline-flex')

    this.hourSelectTarget.value = this.hourValue
    this.minuteSelectTarget.value = this.minuteValue
    this.ampmSelectTarget.value = this.ampmValue
  }

  close () {
    this.editTarget.classList.add('hidden')
    this.editTarget.classList.remove('inline-flex')
    this.displayTarget.classList.remove('hidden')
    this.#updateDisplay()
    this.#commit()
  }

  update () {
    this.hourValue = parseInt(this.hourSelectTarget.value)
    this.minuteValue = parseInt(this.minuteSelectTarget.value)
    this.#commit()
  }

  updateAmPm () {
    this.ampmValue = this.ampmSelectTarget.value
    this.#commit()
  }

  #updateDisplay () {
    const m = String(this.minuteValue).padStart(2, '0')
    this.displayTarget.textContent = `${this.hourValue}:${m} ${this.ampmValue}`
  }

  #commit () {
    const h = this.hourValue
    const m = this.minuteValue
    const isPM = this.ampmValue === 'PM'

    let h24 = h
    if (isPM && h !== 12) h24 = h + 12
    if (!isPM && h === 12) h24 = 0

    const timeStr = `${String(h24).padStart(2, '0')}:${String(m).padStart(2, '0')}`
    this.fieldTarget.value = timeStr
  }

  #syncFromField () {
    const val = this.fieldTarget.value
    if (!val) return
    const [h24, m] = val.split(':').map(Number)
    if (isNaN(h24) || isNaN(m)) return
    const ampm = h24 >= 12 ? 'PM' : 'AM'
    const h12 = h24 % 12 || 12
    this.hourValue = h12
    this.minuteValue = Math.round(m / 5) * 5
    this.ampmValue = ampm
    this.#updateDisplay()
  }
}
