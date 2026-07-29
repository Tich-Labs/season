import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['startInput', 'endInput', 'submit', 'clear', 'day', 'band', 'number', 'heading']
  static values = { startHeading: String, endHeading: String }

  connect () {
    this.startDate = this.startInputTarget.value || null
    this.endDate = this.endInputTarget.value || null
    this.#renderHighlights()
    this.#renderHeading()
  }

  select (event) {
    const date = event.currentTarget.dataset.date

    if (!this.startDate) {
      this.startDate = date
    } else if (!this.endDate) {
      if (date >= this.startDate) {
        this.endDate = date
      } else {
        this.startDate = date
      }
    } else {
      this.startDate = date
      this.endDate = null
    }

    this.startInputTarget.value = this.startDate || ''
    this.endInputTarget.value = this.endDate || ''

    this.#renderHighlights()
    this.#renderHeading()

    this.submitTarget.classList.remove('hidden')
    this.clearTarget.classList.remove('hidden')
  }

  clear (event) {
    event.preventDefault()
    this.startDate = null
    this.endDate = null
    this.startInputTarget.value = ''
    this.endInputTarget.value = ''

    this.#renderHighlights()
    this.#renderHeading()

    this.submitTarget.classList.add('hidden')
    this.clearTarget.classList.add('hidden')
  }

  #renderHighlights () {
    this.dayTargets.forEach((btn, index) => {
      const date = btn.dataset.date
      const band = this.bandTargets[index]
      const number = this.numberTargets[index]
      const isToday = btn.dataset.today === 'true'
      if (!band) return

      const inRange = this.startDate && date >= this.startDate && date <= (this.endDate || this.startDate)
      band.style.backgroundColor = inRange ? '#933a35' : ''

      if (!number) return
      if (inRange) {
        number.style.backgroundColor = '#933a35'
        number.style.color = '#ffffff'
      } else {
        // Clear inline overrides so the static "today" pill classes (if any) show through again.
        number.style.backgroundColor = ''
        number.style.color = ''
      }
      // Keep today's bold weight even when it's also selected.
      number.classList.toggle('font-semibold', inRange || isToday)
    })
  }

  #renderHeading () {
    if (!this.hasHeadingTarget) return
    const showEndPrompt = this.startDate && !this.endDate
    this.headingTarget.textContent = showEndPrompt ? this.endHeadingValue : this.startHeadingValue
  }
}
