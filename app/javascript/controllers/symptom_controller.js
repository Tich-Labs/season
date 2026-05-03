import { Controller } from "@hotwired/stimulus"

const FILLED_COLOR = "#933a35"
const EMPTY_COLOR  = "#EDE1D5"
const LEVEL_NAMES  = ["", "low", "medium", "high"]
const DEBOUNCE_MS  = 600

export default class extends Controller {
  static values = { url: String }

  #debounceTimer = null

  connect() {
    this.element.querySelectorAll(".symptom-slider").forEach(slider => {
      this.#applySliderVisual(slider, parseInt(slider.value))
    })
  }

  save(event) {
    const { field, value } = event.currentTarget.dataset
    this.#post(this.urlValue, { symptom_log: { date: this.#date, [field]: value } })
      .then(() => this.#updateAriaPressed(event.currentTarget, value))
  }

  // Generic handler for physical + mental symptom sliders.
  // Reads the save URL from data-log-url on the input element.
  saveSymptomSlider(event) {
    const slider = event.currentTarget
    const value  = parseInt(slider.value)

    this.#applySliderVisual(slider, value)
    this.#post(slider.dataset.logUrl, {
      date: this.#date,
      symptom_key: slider.dataset.symptomKey,
      value
    })
  }

  saveNotes(event) {
    this.#debouncedSave({ notes: event.currentTarget.value })
  }

  saveNumber(event) {
    const { field } = event.currentTarget.dataset
    const value = event.currentTarget.value
    if (value === "") {
      clearTimeout(this.#debounceTimer)
      return
    }
    this.#debouncedSave({ [field]: value })
  }

  // ── private ──────────────────────────────────────────────────────────────

  get #date() {
    return this.element.dataset.date
  }

  get #csrfToken() {
    return document.querySelector('meta[name="csrf-token"]').content
  }

  #debouncedSave(fields) {
    clearTimeout(this.#debounceTimer)
    this.#debounceTimer = setTimeout(() => {
      this.#post(this.urlValue, { symptom_log: { date: this.#date, ...fields } })
    }, DEBOUNCE_MS)
  }

  #post(url, body) {
    return fetch(url, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": this.#csrfToken,
        "Accept": "application/json"
      },
      body: JSON.stringify(body)
    })
  }

  #updateAriaPressed(target, value) {
    const group = target.closest(".dot-group")
    if (!group) return
    group.querySelectorAll(".dot").forEach((dot, i) => {
      dot.setAttribute("aria-pressed", (i === parseInt(value) - 1).toString())
    })
  }

  #applySliderVisual(slider, value) {
    const pct = (value / 3) * 100

    slider.style.background = value > 0
      ? `linear-gradient(to right, ${FILLED_COLOR} ${pct}%, ${EMPTY_COLOR} ${pct}%)`
      : EMPTY_COLOR

    const row = slider.closest(".symptom-row")
    if (!row) return

    row.querySelectorAll("[data-dot]").forEach(dot => {
      dot.style.background = parseInt(dot.dataset.dot) <= value ? FILLED_COLOR : EMPTY_COLOR
    })

    const label = row.querySelector(".slider-label")
    if (!label) return
    label.textContent   = LEVEL_NAMES[value] || ""
    label.style.left    = `${pct}%`
    label.style.display = value > 0 ? "block" : "none"
  }
}
