/* global requestAnimationFrame */
import { Controller } from '@hotwired/stimulus'

const SHORT = ['S', 'M', 'T', 'W', 'T', 'F', 'S']

export default class extends Controller {
  static targets = [
    'backdrop', 'modal',
    'stage1', 'stage2',
    'dateTitle',
    'slot1Btn', 'slot1Label', 'slot1Time',
    'slot2Btn', 'slot2Label', 'slot2Time',
    'allDayToggle',
    'dayScroll', 'monthScroll', 'yearScroll', 'hourScroll', 'minuteScroll', 'stage2Title',
    'dateDisplay', 'dateField', 'endDateField', 'startField', 'endField',
    'startTimeDisplay', 'endTimeDisplay', 'timeRow'
  ]

  static values = {
    // [[startISODate, endISODate], ...] — the user's predicted period days.
    periodRanges: { type: Array, default: [] }
  }

  _allDay = false
  _mode = 'date'
  // Set true only for the single re-entrant confirm() call right after the
  // user dismisses the past-date warning by choosing to proceed anyway.
  _pastDateConfirmed = false
  // Slot 1 date state
  _pickDay = 1
  _pickMonth = 1
  _pickYear = 2026
  // Slot 2 date state (null = auto: slot1 + 1 day)
  _pickDay2 = null
  _pickMonth2 = null
  _pickYear2 = null
  // Time state
  _pickHour1 = 12
  _pickMin1 = 0
  _pickHour2 = 13
  _pickMin2 = 0
  _editingSlot = 1

  connect () {
    this.#updateDateDisplay()
    this.#updateTimeDisplays()
    this.element.addEventListener('form-persistence:restored', () => {
      this.#updateDateDisplay()
      this.#updateTimeDisplays()
    })
  }

  open () {
    this._allDay = false
    this.allDayToggleTargets.forEach(btn => {
      btn.style.background = '#D9D9D9'
      const d = btn.querySelector('span')
      if (d) d.style.transform = 'translateX(0)'
    })

    this.#setDateFromField()
    this.#syncTimesFromField()
    this.#buildSlots()
    this.#showStage1()

    this.backdropTarget.classList.remove('hidden')
    this.backdropTarget.style.display = 'block'
    this.modalTarget.classList.remove('hidden')
    this.modalTarget.style.display = 'flex'
    this.modalTarget.style.alignItems = 'center'
    this.modalTarget.style.justifyContent = 'center'
    this.modalTarget.style.position = 'fixed'
    this.modalTarget.style.inset = '0'
    this.modalTarget.style.zIndex = '50'
  }

  close () {
    this.backdropTarget.classList.add('hidden')
    this.backdropTarget.style.display = 'none'
    this.modalTarget.classList.add('hidden')
    this.modalTarget.style.display = 'none'
    this.#resetBold()
  }

  editDate1 () {
    this._editingSlot = 1
    this._mode = 'date'
    this.#openStage2()
  }

  editDate2 () {
    this._editingSlot = 2
    this._mode = 'date'
    // Initialise slot 2 date from its effective date if not yet set
    if (this._pickDay2 === null) {
      const d2 = this.#getSlot2Date()
      this._pickDay2 = d2.getDate()
      this._pickMonth2 = d2.getMonth() + 1
      this._pickYear2 = d2.getFullYear()
    }
    this.#openStage2()
  }

  editTime1 () {
    this._editingSlot = 1
    this._mode = 'time'
    this.#openStage2()
  }

  editTime2 () {
    this._editingSlot = 2
    this._mode = 'time'
    this.#openStage2()
  }

  #openStage2 () {
    const time24 = this.#getSlotTime24(this._editingSlot)
    const [h24raw, mRaw] = time24.split(':').map(Number)
    const [h24, m] = this.#round5(h24raw, mRaw)
    this.#setPickHour(h24)
    this.#setPickMin(m)

    let d
    if (this._editingSlot === 2 && this._mode === 'date') {
      d = this.#getSlot2Date()
      this._pickDay2 = d.getDate()
      this._pickMonth2 = d.getMonth() + 1
      this._pickYear2 = d.getFullYear()
    } else {
      const dateStr = this.#dateStr()
      d = dateStr ? new Date(dateStr + 'T00:00:00') : new Date(this._pickYear, this._pickMonth - 1, this._pickDay)
      this._pickYear = d.getFullYear()
      this._pickMonth = d.getMonth() + 1
      this._pickDay = d.getDate()
    }

    // Figma's title never changes between the compact and expanded views —
    // it's always just the overall date, not "Start date: …"/"End time: …".
    // Mirroring dateTitleTarget's own text (rather than recomputing it here)
    // guarantees the two stay byte-for-byte identical.
    this.stage2TitleTarget.textContent = this.dateTitleTarget.textContent

    this.#updateAllSlotLabels()
    this.#setBoldForEditingSlot()

    requestAnimationFrame(() => {
      if (this._mode === 'date') {
        const pm = this._editingSlot === 2 ? this._pickMonth2 : this._pickMonth
        const pd = this._editingSlot === 2 ? this._pickDay2 : this._pickDay
        const py = this._editingSlot === 2 ? this._pickYear2 : this._pickYear
        this.#scrollTo(this.monthScrollTarget, pm)
        this.#scrollTo(this.dayScrollTarget, pd)
        this.#scrollTo(this.yearScrollTarget, py)
      } else {
        this.#scrollTo(this.hourScrollTarget, this.#getPickHour())
        this.#scrollTo(this.minuteScrollTarget, this.#getPickMin())
      }
      this.#highlightScrollers()
    })

    this.#showStage2()
  }

  confirmTime () {
    const time12 = this._allDay ? 'All day' : this.#fmt12h(this.#getPickHour(), this.#getPickMin())
    const time24 = `${String(this.#getPickHour()).padStart(2, '0')}:${String(this.#getPickMin()).padStart(2, '0')}`

    this.#setSlotTime24(this._editingSlot, time24)
    this.#updateSlotTimeDisplay(this._editingSlot, time12)

    this.#showStage1()
  }

  confirm () {
    const dateStr = this.#dateStr()
    if (!dateStr) return

    const today = new Date()
    today.setHours(0, 0, 0, 0)
    const picked = new Date(dateStr + 'T00:00:00')
    if (picked < today && !this._pastDateConfirmed) {
      // Warn, don't dead-end: pass a callback that re-runs confirm() with
      // the bypass flag set, so choosing to proceed actually sets the date
      // instead of silently discarding the pick.
      this.dispatch('past-date', { detail: { onConfirm: () => { this._pastDateConfirmed = true; this.confirm() } } })
      return
    }
    this._pastDateConfirmed = false

    // Non-blocking — the date/time is still set below, this just flags it.
    if (this.#isOnPeriod(dateStr)) {
      this.dispatch('sensitive-period')
    }

    // Write start date
    this.dateFieldTarget.value = dateStr

    // Write end date (slot 2 date)
    const d2 = this.#getSlot2Date()
    const endDateStr = `${d2.getFullYear()}-${String(d2.getMonth() + 1).padStart(2, '0')}-${String(d2.getDate()).padStart(2, '0')}`
    if (this.hasEndDateFieldTarget) {
      this.endDateFieldTarget.value = endDateStr
    }

    // Update date display — show range if different days
    this.#applyDateDisplay(dateStr, endDateStr)

    if (this._allDay) {
      this.startFieldTarget.value = '00:00'
      this.endFieldTarget.value = '23:59'
    } else {
      const start24 = this.#getSlotTime24(1)
      const [sh, sm] = start24.split(':').map(Number)
      this.startFieldTarget.value = `${String(sh).padStart(2, '0')}:${String(sm).padStart(2, '0')}`

      const end24 = this.#getSlotTime24(2)
      const [eh, em] = end24.split(':').map(Number)
      this.endFieldTarget.value = `${String(eh).padStart(2, '0')}:${String(em).padStart(2, '0')}`
    }

    // Sync the (now display-only) time pill on the main page
    if (this.hasStartTimeDisplayTarget) {
      const [sh, sm] = (this.startFieldTarget.value || '00:00').split(':').map(Number)
      this.startTimeDisplayTarget.textContent = this._allDay ? 'All day' : this.#fmt12h(sh, sm)
    }
    if (this.hasEndTimeDisplayTarget) {
      const [eh, em] = (this.endFieldTarget.value || '23:59').split(':').map(Number)
      this.endTimeDisplayTarget.textContent = this._allDay ? 'All day' : this.#fmt12h(eh, em)
    }

    this.close()
  }

  toggleAllDay () {
    this._allDay = !this._allDay
    this.allDayToggleTargets.forEach(btn => {
      btn.style.background = this._allDay ? '#933A35' : '#D9D9D9'
      const d = btn.querySelector('span')
      if (d) d.style.transform = this._allDay ? 'translateX(29px)' : 'translateX(0)'
    })
    this.#updateAllDayLabels()
  }

  #updateAllDayLabels () {
    const label1 = this._allDay ? 'All day' : this.#fmt12h(this._pickHour1, this._pickMin1)
    const label2 = this._allDay ? 'All day' : this.#fmt12h(this._pickHour2, this._pickMin2)
    this.#updateSlotTimeDisplay(1, label1)
    this.#updateSlotTimeDisplay(2, label2)
  }

  onHourScroll () {
    if (this._hrRaf) return
    this._hrRaf = requestAnimationFrame(() => {
      this._hrRaf = null
      const item = this.#closestItem(this.hourScrollTarget)
      if (item) this.#setPickHour(parseInt(item.dataset.value))
      this.#highlightScrollers()
      this.#updateAllSlotTimes()
    })
  }

  onMinuteScroll () {
    if (this._minRaf) return
    this._minRaf = requestAnimationFrame(() => {
      this._minRaf = null
      const item = this.#closestItem(this.minuteScrollTarget)
      if (item) this.#setPickMin(parseInt(item.dataset.value))
      this.#highlightScrollers()
      this.#updateAllSlotTimes()
    })
  }

  #updateAllSlotTimes () {
    const time12 = this.#fmt12h(this.#getPickHour(), this.#getPickMin())
    const time24 = `${String(this.#getPickHour()).padStart(2, '0')}:${String(this.#getPickMin()).padStart(2, '0')}`
    this.#setSlotTime24(this._editingSlot, time24)
    this.#updateSlotTimeDisplay(this._editingSlot, time12)
  }

  #getPickHour () { return this._editingSlot === 1 ? this._pickHour1 : this._pickHour2 }
  #getPickMin () { return this._editingSlot === 1 ? this._pickMin1 : this._pickMin2 }
  #setPickHour (v) { if (this._editingSlot === 1) this._pickHour1 = v; else this._pickHour2 = v }
  // Callers are expected to pass an already-valid multiple of 5 (via
  // #round5, or straight off a scroller's own discrete [0,5,...,55]
  // values) — this just stores it, it doesn't re-round, so it can't
  // reintroduce the min:60 bug #round5 exists to avoid.
  #setPickMin (v) { if (this._editingSlot === 1) this._pickMin1 = v; else this._pickMin2 = v }

  #getSlotTime24 (slot) {
    return slot === 1
      ? `${String(this._pickHour1).padStart(2, '0')}:${String(this._pickMin1).padStart(2, '0')}`
      : `${String(this._pickHour2).padStart(2, '0')}:${String(this._pickMin2).padStart(2, '0')}`
  }

  #setSlotTime24 (slot, time24) {
    this.slot1BtnTargets.forEach(el => { el.dataset.time24 = this.#getSlotTime24(1) })
    this.slot2BtnTargets.forEach(el => { el.dataset.time24 = this.#getSlotTime24(2) })
  }

  #updateSlotTimeDisplay (slot, label) {
    if (slot === 1) {
      this.slot1TimeTargets.forEach(el => { el.textContent = label })
    } else {
      this.slot2TimeTargets.forEach(el => { el.textContent = label })
    }
  }

  // Returns the effective Date object for slot 2 (independent if set, else slot1 + 1 day)
  #getSlot2Date () {
    if (this._pickDay2 !== null) {
      return new Date(this._pickYear2, this._pickMonth2 - 1, this._pickDay2)
    }
    const d = new Date(this._pickYear, this._pickMonth - 1, this._pickDay)
    d.setDate(d.getDate() + 1)
    return d
  }

  onDayScroll () {
    if (this._dRaf) return
    this._dRaf = requestAnimationFrame(() => {
      this._dRaf = null
      const item = this.#closestItem(this.dayScrollTarget)
      if (item) {
        if (this._editingSlot === 2 && this._mode === 'date') {
          this._pickDay2 = parseInt(item.dataset.value)
        } else {
          this._pickDay = parseInt(item.dataset.value)
        }
      }
      this.#highlightScrollers()
      this.#updateAllSlotLabels()
    })
  }

  onMonthScroll () {
    if (this._moRaf) return
    this._moRaf = requestAnimationFrame(() => {
      this._moRaf = null
      const item = this.#closestItem(this.monthScrollTarget)
      if (item) {
        if (this._editingSlot === 2 && this._mode === 'date') {
          this._pickMonth2 = parseInt(item.dataset.value)
        } else {
          this._pickMonth = parseInt(item.dataset.value)
        }
      }
      this.#highlightScrollers()
      this.#updateAllSlotLabels()
    })
  }

  onYearScroll () {
    if (this._yRaf) return
    this._yRaf = requestAnimationFrame(() => {
      this._yRaf = null
      const item = this.#closestItem(this.yearScrollTarget)
      if (item) {
        if (this._editingSlot === 2 && this._mode === 'date') {
          this._pickYear2 = parseInt(item.dataset.value)
        } else {
          this._pickYear = parseInt(item.dataset.value)
        }
      }
      this.#highlightScrollers()
      this.#updateAllSlotLabels()
    })
  }

  #updateAllSlotLabels () {
    const d1 = new Date(this._pickYear, this._pickMonth - 1, this._pickDay)
    const d2 = this.#getSlot2Date()

    // Title stays constant (always the overall From date) — matches
    // dateTitleTarget, which #updateDateTitle keeps in sync as d1 changes.
    this.stage2TitleTarget.textContent = this.dateTitleTarget.textContent

    const fmt = (d) => `${SHORT[d.getDay()]} ${String(d.getDate()).padStart(2, '0')}.${String(d.getMonth() + 1).padStart(2, '0')}.${d.getFullYear()}`
    this.slot1LabelTargets.forEach(el => { el.textContent = fmt(d1) })
    this.slot2LabelTargets.forEach(el => { el.textContent = fmt(d2) })
  }

  #setBoldForEditingSlot () {
    this.slot1LabelTargets.forEach(el => { el.style.fontWeight = (this._editingSlot === 1 && this._mode === 'date') ? '700' : '500' })
    this.slot2LabelTargets.forEach(el => { el.style.fontWeight = (this._editingSlot === 2 && this._mode === 'date') ? '700' : '500' })
    this.slot1TimeTargets.forEach(el => { el.style.fontWeight = (this._editingSlot === 1 && this._mode === 'time') ? '700' : '500' })
    this.slot2TimeTargets.forEach(el => { el.style.fontWeight = (this._editingSlot === 2 && this._mode === 'time') ? '700' : '500' })
  }

  #showStage1 () {
    this.stage1Target.classList.remove('hidden')
    this.stage2Target.classList.add('hidden')
    this.modalTarget.querySelector('div').style.height = '406px'
    this.#resetBold()
    this.#buildSlots()
  }

  #resetBold () {
    this.slot1LabelTargets.forEach(el => { el.style.fontWeight = '500' })
    this.slot2LabelTargets.forEach(el => { el.style.fontWeight = '500' })
    this.slot1TimeTargets.forEach(el => { el.style.fontWeight = '500' })
    this.slot2TimeTargets.forEach(el => { el.style.fontWeight = '500' })
  }

  #showStage2 () {
    this.stage1Target.classList.add('hidden')
    this.stage2Target.classList.remove('hidden')

    const datePicker = this.stage2Target.querySelector('[data-picker="date"]')
    const timePicker = this.stage2Target.querySelector('[data-picker="time"]')
    const picker = this._mode === 'date' ? datePicker : timePicker
    const other = this._mode === 'date' ? timePicker : datePicker
    picker.style.display = 'flex'
    other.style.display = 'none'

    const slot2 = this.stage2Target.querySelector('[data-stage2-slot2]')
    const dividerBefore = this.stage2Target.querySelector('[data-stage2-divider-before]')
    const divider = this.stage2Target.querySelector('[data-stage2-divider]')
    const allday = this.stage2Target.querySelector('[data-stage2-allday]')
    const button = this.stage2Target.querySelector('[data-stage2-button]')
    const card = this.modalTarget.querySelector('div')

    // Positions measured directly off Figma's four expanded "Europa" frames
    // (12090:3325/3241 for slot 1, 12090:3491/3409 for slot 2) — the
    // scroller always inserts right after whichever row was tapped, not
    // always after From. Card height (539px) and the allday/button
    // positions are identical either way; only where the scroller and the
    // *other* row land differs.
    if (this._editingSlot === 1) {
      dividerBefore.style.display = ''
      picker.style.top = '205px'
      slot2.style.top = '345px'
      divider.style.top = '326px'
    } else {
      // No divider between the From and To rows when To is the one being
      // edited — the scroller inserts after To instead, with nothing
      // separating From/To above it.
      dividerBefore.style.display = 'none'
      picker.style.top = '255px'
      slot2.style.top = '176px'
      divider.style.top = '376px'
    }
    allday.style.top = '395px'
    button.style.top = '460px'
    card.style.height = '559px'
  }

  #highlightScrollers () {
    if (this._mode === 'date') {
      const pd = this._editingSlot === 2 ? this._pickDay2 : this._pickDay
      const pm = this._editingSlot === 2 ? this._pickMonth2 : this._pickMonth
      const py = this._editingSlot === 2 ? this._pickYear2 : this._pickYear
      this.#highlightTrack(this.dayScrollTarget, pd)
      this.#highlightTrack(this.monthScrollTarget, pm)
      this.#highlightTrack(this.yearScrollTarget, py)
    } else {
      this.#highlightTrack(this.hourScrollTarget, this.#getPickHour())
      this.#highlightTrack(this.minuteScrollTarget, this.#getPickMin())
    }
  }

  #scrollTo (track, val) {
    const items = track.querySelectorAll('[data-value]')
    for (const item of items) {
      if (parseInt(item.dataset.value) === val) {
        track.scrollTop = item.offsetTop - track.clientHeight / 2 + item.clientHeight / 2
        break
      }
    }
  }

  #syncTimesFromField () {
    const [shRaw, smRaw] = (this.startFieldTarget.value || '19:00').split(':').map(Number)
    const [ehRaw, emRaw] = (this.endFieldTarget.value || '20:00').split(':').map(Number)
    const start = this.#round5(shRaw, smRaw)
    const end = this.#round5(ehRaw, emRaw)
    this._pickHour1 = start[0]
    this._pickMin1 = start[1]
    this._pickHour2 = end[0]
    this._pickMin2 = end[1]
  }

  #highlightTrack (track, activeVal) {
    const items = track.querySelectorAll('[data-value]')
    items.forEach(el => {
      const active = parseInt(el.dataset.value) === activeVal
      el.style.opacity = active ? '1' : '0.35'
      el.style.fontWeight = active ? '700' : '400'
    })
  }

  #closestItem (track) {
    const centerY = track.scrollTop + track.clientHeight / 2
    let closest = null
    let minDist = Infinity
    for (const el of track.querySelectorAll('[data-value]')) {
      const elCenter = el.offsetTop + el.clientHeight / 2
      const dist = Math.abs(elCenter - centerY)
      if (dist < minDist) { minDist = dist; closest = el }
    }
    return closest
  }

  #applyDateDisplay (startDateStr, endDateStr) {
    const d1 = new Date(startDateStr + 'T00:00:00')
    const d2 = endDateStr ? new Date(endDateStr + 'T00:00:00') : null
    const multiDay = d2 && d2.toDateString() !== d1.toDateString()

    const dayName1 = d1.toLocaleDateString('en-US', { weekday: 'short' })
    const monthName1 = d1.toLocaleDateString('en-US', { month: 'long' })
    const dateNum1 = d1.getDate()
    const year1 = d1.getFullYear()
    const nth1 = this.#ordinal(dateNum1)

    if (multiDay) {
      const dayName2 = d2.toLocaleDateString('en-US', { weekday: 'short' })
      const monthName2 = d2.toLocaleDateString('en-US', { month: 'long' })
      const dateNum2 = d2.getDate()
      const nth2 = this.#ordinal(dateNum2)
      const year2 = d2.getFullYear()
      const line1 = `${dayName1}. ${monthName1} ${dateNum1}${nth1} ${year1}`
      const line2 = `${dayName2}. ${monthName2} ${dateNum2}${nth2} ${year2}`
      // Three lines — date, a "-" on its own line, date — matching
      // Figma's multi-day card (node 12090:3531), not two dates stacked
      // directly on each other.
      this.dateDisplayTarget.innerHTML = `${line1}<br><span class="font-light">-</span><br>${line2}`
    } else {
      this.dateDisplayTarget.textContent = `${dayName1}. ${monthName1} ${dateNum1}${nth1} ${year1}`
    }
    this.dateDisplayTarget.style.fontSize = ''

    // Figma shows no time row at all for a multi-day span — keep this in
    // sync live as the picker's date changes, not just on initial render.
    if (this.hasTimeRowTarget) {
      this.timeRowTarget.classList.toggle('hidden', multiDay)
    }
  }

  #setDateFromField () {
    const dateStr = this.dateFieldTarget.value || this.#todayStr()
    const [y, m, d] = dateStr.split('-').map(Number)
    this._pickYear = y
    this._pickMonth = m
    this._pickDay = d

    // Load saved end_date into slot 2 state
    const endDateStr = this.hasEndDateFieldTarget ? this.endDateFieldTarget.value : ''
    if (endDateStr) {
      const [ey, em2, ed] = endDateStr.split('-').map(Number)
      this._pickYear2 = ey
      this._pickMonth2 = em2
      this._pickDay2 = ed
    } else {
      this._pickDay2 = null
      this._pickMonth2 = null
      this._pickYear2 = null
    }

    this.#updateDateTitle()
  }

  #buildSlots () {
    const d1 = new Date(this._pickYear, this._pickMonth - 1, this._pickDay)
    const d2 = this.#getSlot2Date()

    const fmt = (d) => `${SHORT[d.getDay()]} ${String(d.getDate()).padStart(2, '0')}.${String(d.getMonth() + 1).padStart(2, '0')}.${d.getFullYear()}`
    this.slot1LabelTargets.forEach(el => { el.textContent = fmt(d1) })
    this.slot2LabelTargets.forEach(el => { el.textContent = fmt(d2) })

    const time12a = this.#fmt12h(this._pickHour1, this._pickMin1)
    const time12b = this.#fmt12h(this._pickHour2, this._pickMin2)
    this.slot1TimeTargets.forEach(el => { el.textContent = time12a })
    this.slot2TimeTargets.forEach(el => { el.textContent = time12b })

    this.slot1BtnTargets.forEach(el => { el.dataset.time24 = this.#getSlotTime24(1) })
    this.slot2BtnTargets.forEach(el => { el.dataset.time24 = this.#getSlotTime24(2) })
  }

  #updateDateTitle () {
    const d = new Date(this._pickYear, this._pickMonth - 1, this._pickDay)
    const dayName = SHORT[d.getDay()]
    const month = String(d.getMonth() + 1).padStart(2, '0')
    const dateNum = String(d.getDate()).padStart(2, '0')
    const year = d.getFullYear()
    this.dateTitleTarget.textContent = `${dayName} ${dateNum}.${month}.${year}`
  }

  #updateDateDisplay () {
    const startDateStr = this.dateFieldTarget.value
    if (!startDateStr) return
    const endDateStr = this.hasEndDateFieldTarget ? this.endDateFieldTarget.value : ''
    this.#applyDateDisplay(startDateStr, endDateStr || null)
  }

  #updateTimeDisplays () {
    if (this.hasStartTimeDisplayTarget) {
      const [sh, sm] = (this.startFieldTarget.value || '19:00').split(':').map(Number)
      this.startTimeDisplayTarget.textContent = this.#fmt12h(...this.#round5(sh, sm))
    }
    if (this.hasEndTimeDisplayTarget) {
      const [eh, em] = (this.endFieldTarget.value || '20:00').split(':').map(Number)
      this.endTimeDisplayTarget.textContent = this.#fmt12h(...this.#round5(eh, em))
    }
  }

  // dateStr is 'YYYY-MM-DD', same lexicographic order as the ISO strings in
  // periodRangesValue, so plain string comparison is enough — no Date math.
  #isOnPeriod (dateStr) {
    return this.periodRangesValue.some(([start, end]) => dateStr >= start && dateStr <= end)
  }

  // Floors (not rounds) to the nearest 5-minute mark. The scroller only
  // ever produces exact multiples of 5 in the first place, so the choice
  // between floor/round never affects a value that actually came from it —
  // this only matters for values that didn't, like the "All day" end-time
  // sentinel (23:59). Math.round(59/5)*5 = 60, an invalid minute that
  // rendered as "11:60 PM"; carrying that into the next hour instead
  // "fixed" it into 00:00 — identical to a typical 00:00 start time, which
  // reads as a zero-length appointment (worse than the display bug it
  // replaced). Flooring keeps 23:59 at 23:55, still visibly a full day
  // later than 00:00, and never needs an hour carry at all.
  #round5 (h24, m) {
    return [h24, Math.floor(m / 5) * 5]
  }

  #fmt12h (h24, m) {
    const ampm = h24 >= 12 ? 'PM' : 'AM'
    const h12 = h24 % 12 || 12
    return `${h12}:${String(m).padStart(2, '0')} ${ampm}`
  }

  #dateStr () {
    return `${this._pickYear}-${String(this._pickMonth).padStart(2, '0')}-${String(this._pickDay).padStart(2, '0')}`
  }

  #todayStr () {
    const now = new Date()
    return `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}-${String(now.getDate()).padStart(2, '0')}`
  }

  #ordinal (n) {
    if (n > 3 && n < 21) return 'th'
    switch (n % 10) {
      case 1: return 'st'
      case 2: return 'nd'
      case 3: return 'rd'
      default: return 'th'
    }
  }
}
