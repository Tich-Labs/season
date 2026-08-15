import { Controller } from '@hotwired/stimulus'

const FILLED_COLOR = '#933a35'
const EMPTY_COLOR = '#EDE1D5'

const DEBOUNCE_MS = 600

export default class extends Controller {
  static values = { url: String }

  #debounceTimer = null
  #activeMoods = []
  #activeCravings = []
  #activeIntercourse = []

  connect () {
    this.element.querySelectorAll('.symptom-slider').forEach(slider => {
      this.#applySliderVisual(slider, parseInt(slider.value))
    })
    this.#activeMoods = JSON.parse(this.element.dataset.activeMoods || '[]')
    this.#applyMoodVisuals()
    this.#activeCravings = JSON.parse(this.element.dataset.activeCravings || '[]')
    this.#applyCravingVisuals()
    this.#activeIntercourse = JSON.parse(this.element.dataset.activeIntercourse || '[]')
    this.#applyIntercourseVisuals()
    this.#initAccordion()
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

  toggleCravings (event) {
    const btn = event.currentTarget
    const craving = btn.dataset.craving
    const checkEl = document.getElementById('section-cravings-check')

    if (this.#activeCravings.includes(craving)) {
      this.#activeCravings = this.#activeCravings.filter(c => c !== craving)
    } else {
      this.#activeCravings.push(craving)
    }

    this.#debouncedSave({ cravings: this.#activeCravings.join(',') })
    this.#applyCravingVisuals()

    if (checkEl) { checkEl.style.display = this.#activeCravings.length > 0 ? '' : 'none' }
  }

  #applyCravingVisuals () {
    this.element.querySelectorAll('[data-craving]').forEach(btn => {
      const selected = this.#activeCravings.includes(btn.dataset.craving)
      btn.style.opacity = selected ? '1' : '0.35'
      btn.style.transform = selected ? 'scale(1.08)' : 'scale(1)'
      btn.setAttribute('aria-pressed', selected.toString())
      btn.style.filter = selected ? '' : 'grayscale(0.6)'
    })
  }

  toggleIntercourse (event) {
    const btn = event.currentTarget
    const tag = btn.dataset.intercourse
    const checkEl = document.getElementById('section-intercourse-check')

    if (this.#activeIntercourse.includes(tag)) {
      this.#activeIntercourse = this.#activeIntercourse.filter(t => t !== tag)
    } else {
      this.#activeIntercourse.push(tag)
    }

    this.#debouncedSave({ intercourse_tags: this.#activeIntercourse.join(',') })
    this.#applyIntercourseVisuals()

    if (checkEl) { checkEl.style.display = this.#activeIntercourse.length > 0 ? '' : 'none' }
  }

  #applyIntercourseVisuals () {
    this.element.querySelectorAll('[data-intercourse]').forEach(btn => {
      const selected = this.#activeIntercourse.includes(btn.dataset.intercourse)
      btn.style.opacity = selected ? '1' : '0.35'
      btn.style.transform = selected ? 'scale(1.08)' : 'scale(1)'
      btn.setAttribute('aria-pressed', selected.toString())
      btn.style.filter = selected ? '' : 'grayscale(0.6)'
    })
  }

  toggleDischarge (event) {
    const btn = event.currentTarget
    const key = btn.dataset.discharge
    const checkEl = document.getElementById('section-discharge-check')

    // Single-select, but tapping the already-selected tile clears it back to
    // blank — some days genuinely have nothing to log, and there was no way
    // to say that once you'd tapped something by mistake (or changed your
    // mind) short of picking a different, also-wrong tile.
    const wasSelected = btn.getAttribute('aria-pressed') === 'true'
    const newKey = wasSelected ? '' : key

    this.element.querySelectorAll('[data-discharge]').forEach(b => {
      const isSel = !wasSelected && b.dataset.discharge === key
      b.style.opacity = isSel ? '1' : '0.35'
      b.style.transform = isSel ? 'scale(1.08)' : 'scale(1)'
      b.style.filter = isSel ? '' : 'grayscale(0.6)'
      b.setAttribute('aria-pressed', isSel.toString())
      // Toggle label opacity
      const label = b.querySelector('span:last-child')
      if (label) label.style.opacity = isSel ? '1' : '0.5'
    })

    this.#debouncedSave({ discharge: newKey })

    if (checkEl) { checkEl.style.display = newKey ? '' : 'none' }
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

  // Receive value from scroll picker (sleep / temperature / weight)
  saveFromPicker (event) {
    const { field, value } = event.detail
    // Unlike mood/discharge/intercourse/cravings, this checkmark has no
    // JS-driven visibility elsewhere — it was only ever set once from the
    // server at page load, so scrolling back to the picker's "-" placeholder
    // correctly cleared the saved value (confirmed server-side) but left the
    // checkmark lit as if something was still tracked. `value` is '' for the
    // placeholder, a number otherwise.
    const checkEl = document.getElementById(`section-${field}-check`)
    if (checkEl) checkEl.style.display = value === '' ? 'none' : ''
    this.#debouncedSave({ [field]: value.toString() })
  }

  // Handle bleeding flow selection (Light, Medium, Heavy, Disaster)
  saveBleedingFlow (event) {
    const button = event.currentTarget
    const flow = button.dataset.flow
    const url = button.dataset.url

    // Update visual feedback — standard opacity/grayscale pattern
    this.element.querySelectorAll('[data-action*="saveBleedingFlow"]').forEach(btn => {
      const isSel = btn === button
      btn.style.opacity = isSel ? '1' : '0.35'
      btn.style.transform = isSel ? 'scale(1.08)' : 'scale(1)'
      btn.style.filter = isSel ? '' : 'grayscale(0.6)'
    })

    // Send to server
    this.#post(url, {
      date: this.#date,
      flow
    })
  }

  // "?" badge on a discharge grid icon — opens that item's info modal
  // (#discharge-info-<key>, see symptoms/index.html.erb). The badge sits
  // inside the tile's own selection <button>, so this must stop the click
  // from also bubbling up into toggleDischarge above.
  openDischargeInfo (event) {
    if (event.type === 'keydown' && event.key !== 'Enter' && event.key !== ' ') return
    event.preventDefault()
    event.stopPropagation()
    const key = event.currentTarget.dataset.dischargeInfo
    document.getElementById(`discharge-info-${key}`)?.classList.remove('hidden')
  }

  closeDischargeInfo (event) {
    const modal = event.currentTarget.closest('[data-discharge-info-modal]')
    if (!modal) return
    modal.classList.add('hidden')
    // Reset to collapsed for next time it's opened.
    modal.querySelector('[data-role="detail"]')?.classList.add('hidden')
    const readMore = modal.querySelector('[data-role="short"]')?.nextElementSibling
    if (readMore) readMore.style.display = ''
  }

  // "…read more" inside a discharge info modal — one-way expand, no need
  // to re-collapse within the same open/close cycle.
  toggleDischargeInfoDetail (event) {
    const modal = event.currentTarget.closest('[data-discharge-info-modal]')
    modal?.querySelector('[data-role="detail"]')?.classList.remove('hidden')
    event.currentTarget.style.display = 'none'
  }

  // "Choose" inside the modal — re-uses toggleDischarge's own selection +
  // save logic via a real click, rather than duplicating it here.
  chooseFromDischargeInfo (event) {
    const key = event.currentTarget.dataset.chooseDischarge
    this.element.querySelector(`[data-action="click->symptom#toggleDischarge"][data-discharge="${key}"]`)?.click()
    event.currentTarget.closest('[data-discharge-info-modal]')?.classList.add('hidden')
  }

  // Tapping the looping finger video inside a discharge info modal opens the
  // enlarged viewer (#discharge-video-<key>). A fresh <video> element lives
  // there, so playback restarts from the beginning each time.
  openDischargeVideo (event) {
    event.preventDefault()
    event.stopPropagation()
    const key = event.currentTarget.dataset.dischargeVideo
    const modal = document.getElementById(`discharge-video-${key}`)
    modal?.classList.remove('hidden')
    // The `autoplay` attribute alone doesn't reliably (re)start playback here
    // — this <video> sits inside a `.hidden` (display:none) container from
    // page load, and browsers generally only honour `autoplay` for an
    // element that's already laid out and visible, not one that's merely
    // unhidden later. Play explicitly instead of hoping the attribute
    // catches it. `.play()` returns a promise that rejects if the browser
    // blocks it — harmless here (muted autoplay is broadly allowed) and not
    // worth surfacing as an error.
    modal?.querySelector('video')?.play().catch(() => {})
  }

  closeDischargeVideo (event) {
    const modal = event.currentTarget.closest('[data-discharge-video-modal]')
    if (!modal) return
    modal.querySelector('video')?.pause()
    modal.classList.add('hidden')
  }

  // Same enlarge-on-tap pattern as the video above, for categories that only
  // have a static finger photo (no video yet).
  openDischargePhoto (event) {
    event.preventDefault()
    event.stopPropagation()
    const key = event.currentTarget.dataset.dischargePhoto
    document.getElementById(`discharge-photo-${key}`)?.classList.remove('hidden')
  }

  closeDischargePhoto (event) {
    event.currentTarget.closest('[data-discharge-photo-modal]')?.classList.add('hidden')
  }

  // Same enlarge-on-tap pattern again, for the first (slip) photo circle —
  // the one always present, as opposed to the finger photo/video pair above
  // which only exists once added per category.
  openDischargeSlip (event) {
    event.preventDefault()
    event.stopPropagation()
    const key = event.currentTarget.dataset.dischargeSlip
    document.getElementById(`discharge-slip-${key}`)?.classList.remove('hidden')
  }

  closeDischargeSlip (event) {
    event.currentTarget.closest('[data-discharge-slip-modal]')?.classList.add('hidden')
  }

  // ── private ──────────────────────────────────────────────────────────────

  // Exclusive accordion — opening one of the 10 <details> sections closes any
  // other that was already open, so the page doesn't grow into a long scroll
  // as the user works through Mood/Physical/Mental/etc. Not the native HTML
  // `name="..."` grouping (Safari only got that in 17.2 — iOS 16 WKWebView,
  // this app's minimum target, predates it), so wired up by hand instead.
  #initAccordion () {
    const sections = this.element.querySelectorAll('details')
    sections.forEach(details => {
      details.addEventListener('toggle', () => {
        if (!details.open) return
        sections.forEach(other => {
          if (other !== details) other.open = false
        })
      })
    })
  }

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

    const row = slider.closest('.sp-row')
    if (!row) return

    row.querySelectorAll('[data-level]').forEach(el => {
      el.style.color = parseInt(el.dataset.level) === value ? FILLED_COLOR : '#999'
    })
  }
}
