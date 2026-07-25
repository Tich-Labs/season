import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['modal', 'title', 'body', 'food']

  open (event) {
    const btn = event.currentTarget
    this.titleTarget.textContent = btn.dataset.forecastModalTitle
    this.bodyTarget.textContent = btn.dataset.forecastModalBody

    // Food items for nutrition card
    if (btn.dataset.forecastModalFood) {
      const items = JSON.parse(btn.dataset.forecastModalFood)
      this.foodTarget.innerHTML = items.map(item =>
        `<div>
          <p class="text-brand-primary font-semibold text-base font-sans m-0 mb-1">${item.name}</p>
          <p class="text-brand-primary text-sm leading-snug font-sans m-0">${item.description}</p>
        </div>`
      ).join('')
    } else {
      this.foodTarget.innerHTML = ''
    }

    this.modalTarget.classList.remove('hidden')
  }

  close () {
    this.modalTarget.classList.add('hidden')
  }

  overlayClick (e) {
    if (e.target === this.modalTarget) this.close()
  }
}
