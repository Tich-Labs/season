import { Controller } from '@hotwired/stimulus'

const LEVELS = ['', 'Low', 'Medium', 'High']

// Pre-submit review modal for /superpowers -- mirrors submit_modal_controller.js
// (used by /symptoms) but simpler: superpowers is a single flat list of
// 0-3 sliders, not symptoms' moods/physical/mental/discharge/etc. mix.
export default class extends Controller {
  static targets = ['modal', 'count', 'list']

  open () {
    this.#populate()
    this.modalTarget.classList.remove('hidden')
  }

  close () {
    this.modalTarget.classList.add('hidden')
  }

  overlayClick (event) {
    if (event.target === this.modalTarget) this.close()
  }

  // ── private ──────────────────────────────────────────────────────────

  #populate () {
    const root = document.querySelector('[data-controller~="superpower"]')
    if (!root) return

    const rated = []
    root.querySelectorAll('.symptom-slider[data-field]').forEach(slider => {
      const value = parseInt(slider.value)
      if (value > 0) {
        rated.push({ label: slider.dataset.field, level: LEVELS[value] })
      }
    })

    if (this.hasListTarget) {
      this.listTarget.innerHTML = rated.length > 0
        ? rated.map(r => `<p class="text-brand-muted font-medium text-sm tracking-003 font-sans mb-0.5">${r.label} → ${r.level}</p>`).join('')
        : ''
    }

    if (this.hasCountTarget) {
      this.countTarget.textContent = rated.length > 0 ? `${rated.length} superpowers rated` : ''
    }
  }
}
