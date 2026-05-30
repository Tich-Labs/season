import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['input', 'submit', 'clear', 'day', 'skip']

  connect () {
    this.#render()
  }

  select (event) {
    const btn = event.currentTarget
    this.inputTarget.value = btn.dataset.date
    this.#render()
  }

  clear (event) {
    event.preventDefault()
    this.inputTarget.value = ''
    this.#render()
  }

  #render () {
    const value = this.inputTarget.value
    const hasSelection = value !== ''

    this.dayTargets.forEach(btn => {
      const label = btn.querySelector('.cal-day-label')
      if (!label) return
      const selected = btn.dataset.date === value
      const isToday = btn.dataset.today === 'true'
      const inMonth = btn.dataset.inMonth === 'true'

      label.classList.remove('bg-brand-primary', 'text-white', 'font-semibold', 'rounded-sm', 'text-brand-primary', 'text-[#C8A49A]')
      if (selected) {
        label.classList.add('bg-brand-primary', 'text-white', 'font-semibold', 'rounded-sm')
      } else if (isToday) {
        label.classList.add('bg-brand-primary', 'text-white', 'font-semibold', 'rounded-sm')
      } else {
        label.classList.add(inMonth ? 'text-brand-primary' : 'text-[#C8A49A]')
      }
    })

    this.submitTarget.classList.toggle('hidden', !hasSelection)

    if (this.hasClearTarget) {
      this.clearTarget.classList.toggle('hidden', !hasSelection)
    }
    if (this.hasSkipTarget) {
      this.skipTarget.classList.toggle('hidden', hasSelection)
    }
  }
}
