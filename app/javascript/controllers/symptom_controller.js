import { Controller } from '@hotwired/stimulus'

const FILLED_COLOR = '#933a35'
const EMPTY_COLOR = '#EDE1D5'
const LEVEL_NAMES = ['', 'low', 'medium', 'high']
const DEBOUNCE_MS = 600

export default class extends Controller {
  static values = { url: String }

  #debounceTimer = null
  #activeMoods = []

  connect () {
    this.element.querySelectorAll('.symptom-slider').forEach(slider => {
      this.#applySliderVisual(slider, parseInt(slider.value))
    })
    this.#activeMoods = JSON.parse(this.element.dataset.activeMoods || '[]')
    this.#applyMoodVisuals()
  }

  toggleCheckbox (event) {
    const { field } = event.currentTarget.dataset
    const value = event.currentTarget.checked

    this.#post(this.urlValue, { symptom_log: { date: this.#date, [field]: value } })

    const row = event.currentTarget.closest('.intercourse-row')
    if (row) {
      const toggleBg = row.querySelector('.toggle-bg')
      const toggleKnob = row.querySelector('.toggle-knob')
      const checkmark = row.querySelector('.intercourse-check')
      if (toggleBg) toggleBg.style.background = value ? this.#phaseColor : '#EDE1D5'
      if (toggleKnob) {
        if (value) { toggleKnob.classList.add('translate-x-5') } else { toggleKnob.classList.remove('translate-x-5') }
      }
      if (checkmark) checkmark.style.display = value ? '' : 'none'
    }
  }

  save (event) {
    const { field, value } = event.currentTarget.dataset
    this.#post(this.urlValue, { symptom_log: { date: this.#date, [field]: value } })
      .then(() => this.#updateAriaPressed(event.currentTarget, value))
  }

  toggleMood (event) {
    const name = event.currentTarget.dataset.moodName
    const checkEl = document.getElementById('section-mood-check')
    const summary = document.getElementById('mood-summary-label')

    if (this.#activeMoods.includes(name)) {
      this.#activeMoods = this.#activeMoods.filter(m => m !== name)
    } else {
      this.#activeMoods.push(name)
    }

    this.#post(this.urlValue, { symptom_log: { date: this.#date, moods: this.#activeMoods } })
    this.#applyMoodVisuals()

    if (checkEl) { checkEl.style.display = this.#activeMoods.length > 0 ? '' : 'none' }
    if (summary) {
      summary.textContent = this.#activeMoods.length > 0
        ? `Mood (${this.#activeMoods.length})`
        : 'Mood'
    }
  }

  #applyMoodVisuals () {
    this.element.querySelectorAll('[data-mood-name]').forEach(btn => {
      const selected = this.#activeMoods.includes(btn.dataset.moodName)
      btn.style.opacity = selected ? '1' : '0.35'
      btn.style.transform = selected ? 'scale(1.08)' : 'scale(1)'
      btn.setAttribute('aria-pressed', selected.toString())
      btn.style.filter = selected ? '' : 'grayscale(0.6)'
    })
  }

  // Generic handler for physical + mental symptom sliders.
  // Reads the save URL from data-log-url on the input element.
  saveSymptomSlider (event) {
    const slider = event.currentTarget
    const value = parseInt(slider.value)

    this.#applySliderVisual(slider, value)
    this.#post(slider.dataset.logUrl, {
      date: this.#date,
      symptom_key: slider.dataset.symptomKey,
      value
    })
  }

  saveNotes (event) {
    this.#debouncedSave({ notes: event.currentTarget.value })
  }

  saveNumber (event) {
    const { field } = event.currentTarget.dataset
    const value = event.currentTarget.value
    if (value === '') {
      clearTimeout(this.#debounceTimer)
      return
    }
    this.#debouncedSave({ [field]: value })
  }

  // Receive value from scroll picker (temperature / weight)
  saveFromPicker (event) {
    const { field, value } = event.detail
    this.#debouncedSave({ [field]: value.toString() })
  }

  // Handle bleeding flow selection (Light, Medium, Heavy, Disaster)
  saveBleedingFlow (event) {
    const button = event.currentTarget
    const flow = button.dataset.flow
    const url = button.dataset.url

    // Update visual feedback
    this.element.querySelectorAll('[data-action*="saveBleedingFlow"]').forEach(btn => {
      btn.style.opacity = btn === button ? '1' : '0.6'
    })

    // Send to server
    this.#post(url, {
      date: this.#date,
      flow
    })
  }

  // ── private ──────────────────────────────────────────────────────────────

  get #phaseColor () {
    return this.element.dataset.phaseColor || '#933a35'
  }

  get #date () {
    return this.element.dataset.date
  }

  get #csrfToken () {
    return document.querySelector('meta[name="csrf-token"]').content
  }

  #debouncedSave (fields) {
    clearTimeout(this.#debounceTimer)
    this.#debounceTimer = setTimeout(() => {
      this.#post(this.urlValue, { symptom_log: { date: this.#date, ...fields } })
    }, DEBOUNCE_MS)
  }

  #post (url, body) {
    return fetch(url, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': this.#csrfToken,
        Accept: 'application/json'
      },
      body: JSON.stringify(body)
    })
  }

  #updateAriaPressed (target, value) {
    const group = target.closest('.dot-group')
    if (!group) return
    group.querySelectorAll('.dot').forEach((dot, i) => {
      dot.setAttribute('aria-pressed', (i === parseInt(value) - 1).toString())
    })
  }

  #applySliderVisual (slider, value) {
    const pct = (value / 3) * 100

    slider.style.background = value > 0
      ? `linear-gradient(to right, ${FILLED_COLOR} ${pct}%, ${EMPTY_COLOR} ${pct}%)`
      : EMPTY_COLOR

    const row = slider.closest('.symptom-row')
    if (!row) return

    row.querySelectorAll('[data-dot]').forEach(dot => {
      dot.style.background = parseInt(dot.dataset.dot) <= value ? FILLED_COLOR : EMPTY_COLOR
    })

    const label = row.querySelector('.slider-label')
    if (!label) return
    label.textContent = LEVEL_NAMES[value] || ''
    label.style.left = `${pct}%`
    label.style.display = value > 0 ? 'block' : 'none'
  }
}
