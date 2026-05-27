import { Controller } from '@hotwired/stimulus'

const FILLED_COLOR = '#933a35'
const EMPTY_COLOR = '#EDE1D5'
const LEVEL_NAMES = ['', 'low', 'medium', 'high']
const DEBOUNCE_MS = 500

export default class extends Controller {
  static values = { url: String }

  #debounceTimer = null

  connect () {
    this.element.querySelectorAll('.symptom-slider').forEach(slider => {
      this.#applySliderVisual(slider, parseInt(slider.value))
    })
  }

  save (event) {
    const slider = event.currentTarget
    const value = parseInt(slider.value)
    const field = slider.dataset.field

    this.#applySliderVisual(slider, value)
    this.#debouncedSave(field, value)
  }

  #debouncedSave (field, value) {
    clearTimeout(this.#debounceTimer)
    this.#debounceTimer = setTimeout(() => {
      this.#post({ ratings: { [field]: value } })
    }, DEBOUNCE_MS)
  }

  #post (body) {
    const csrf = document.querySelector('meta[name="csrf-token"]').content
    return fetch(this.urlValue, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrf,
        Accept: 'application/json'
      },
      body: JSON.stringify(body)
    })
  }

  #applySliderVisual (slider, value) {
    const pct = (value / 3) * 100
    slider.style.background = value > 0
      ? `linear-gradient(to right, ${FILLED_COLOR} ${pct}%, ${EMPTY_COLOR} ${pct}%)`
      : EMPTY_COLOR

    const row = slider.closest('.sp-row')
    if (!row) return

    row.querySelectorAll('[data-dot]').forEach(dot => {
      dot.style.background = parseInt(dot.dataset.dot) <= value ? FILLED_COLOR : EMPTY_COLOR
    })

    const label = row.querySelector('.sp-label')
    if (!label) return
    label.textContent = LEVEL_NAMES[value] || ''
    label.style.left = `${pct}%`
    label.style.display = value > 0 ? 'block' : 'none'
  }
}
