import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['startInput', 'endInput', 'submit', 'clear', 'day', 'band', 'heading']
  static values = { startHeading: String, endHeading: String }

  connect () {
    this.startDate = this.startInputTarget.value || null
    this.endDate = this.endInputTarget.value || null
    this.#renderHighlights()
    this.#renderHeading()
  }

  select (event) {
    const date = event.currentTarget.dataset.date

    if (date === this.startDate) {
      // Tapping the start again always clears the whole selection: with no
      // end yet that's just un-tapping it; with a range already set, a
      // dangling end without a start makes no sense either way.
      this.startDate = null
      this.endDate = null
    } else if (date === this.endDate) {
      // Tapping the end again removes just the end — keep the start.
      this.endDate = null
    } else if (!this.startDate) {
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

    this.submitTarget.classList.toggle('hidden', !this.startDate)
    if (this.hasClearTarget) this.clearTarget.classList.toggle('hidden', !this.startDate)
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
    if (this.hasClearTarget) this.clearTarget.classList.add('hidden')
  }

  #renderHighlights () {
    this.dayTargets.forEach((btn, index) => {
      const date = btn.dataset.date
      const band = this.bandTargets[index]
      if (!band) return

      // Explicit color rather than '' on both branches — the band starts
      // with a *shorthand* `background: ...` in its ERB-rendered inline
      // style (the idle tan #EDE1D5). Setting the .style.backgroundColor
      // longhand once (to paint a selection) and then clearing it back to ''
      // does not restore that original shorthand value — CSSOM has no memory
      // of it once a longhand override has touched the same declaration
      // block — it just deletes the declaration outright, leaving no
      // background at all. Always assign the real target value instead of
      // relying on a fallback that isn't actually there.
      const inRange = this.startDate && date >= this.startDate && date <= (this.endDate || this.startDate)
      band.style.backgroundColor = inRange ? '#933a35' : '#EDE1D5'
      // Cycle day, not date-of-month — day 1 is whichever date got tapped as
      // the start, same convention as calendar/_day_cell's cycle-day-on-band.
      // A period starting on the 3rd should show "1" in the band on the 3rd,
      // not "3" (that's what the plain date-of-month number below already
      // shows, untouched). The date number itself is static (faded red,
      // no circle, set in the ERB) — selection is signalled by the band
      // alone, so there's nothing else to paint here.
      band.textContent = inRange ? this.#cycleDayFor(date) : ''
    })
  }

  #renderHeading () {
    if (!this.hasHeadingTarget) return
    const showEndPrompt = this.startDate && !this.endDate
    this.headingTarget.textContent = showEndPrompt ? this.endHeadingValue : this.startHeadingValue
  }

  // "YYYY-MM-DD" strings parse as UTC midnight (per the ISO 8601 date-only
  // spec), so subtracting them is a plain day count unaffected by the
  // browser's local timezone — no off-by-one risk from DST or offset.
  #cycleDayFor (date) {
    const start = new Date(this.startDate)
    const current = new Date(date)
    return Math.round((current - start) / 86400000) + 1
  }
}
