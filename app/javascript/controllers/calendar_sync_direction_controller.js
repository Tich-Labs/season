/* global fetch */
import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['option', 'connectLink']
  static values = { saveUrl: String }

  connect () {
    this.#apply(this.element.dataset.selected || 'one_way')
  }

  async select (event) {
    const direction = event.currentTarget.dataset.direction
    const previous = this.element.dataset.selected || 'one_way'
    this.#apply(direction)

    if (!this.hasSaveUrlValue) return

    if (await this.#persist(direction)) {
      this.element.dataset.selected = direction
    } else {
      this.#apply(previous)
    }
  }

  // Apple Calendar has no OAuth — on iOS the native EventKit bridge shows the
  // Calendar permission prompt and reads/writes Apple Calendar directly (no
  // email/password). Hand the chosen direction off to that bridge.
  connectApple () {
    const direction = this.element.dataset.selected || 'one_way'
    window.dispatchEvent(new CustomEvent('season:calendar-connect', { detail: { provider: 'apple', direction } }))
  }

  #apply (selected) {
    this.optionTargets.forEach(option => {
      const active = option.dataset.direction === selected
      option.setAttribute('aria-pressed', active.toString())
      option.classList.toggle('bg-brand-error', active)
      option.classList.toggle('border-brand-primary', active)
      option.classList.toggle('bg-white', !active)
      option.classList.toggle('border-brand-divider', !active)

      const dot = option.querySelector('[data-dot]')
      dot.classList.toggle('border-brand-primary', active)
      dot.classList.toggle('border-brand-secondary', !active)
      option.querySelector('[data-dot-inner]').classList.toggle('hidden', !active)
    })

    this.connectLinkTargets.forEach(link => {
      const url = new URL(link.href)
      url.searchParams.set('direction', selected)
      link.href = url.toString()
    })
  }

  async #persist (direction) {
    try {
      const response = await fetch(this.saveUrlValue, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')?.content
        },
        body: JSON.stringify({ direction })
      })
      return response.ok
    } catch (_error) {
      return false
    }
  }
}
