/* global requestAnimationFrame */
import { Controller } from '@hotwired/stimulus'

// Fallback only — the real, locale-aware list comes from the
// weekdayNamesValue Stimulus value (see static values below), rendered
// server-side from config/locales/*.yml's date.abbr_day_names so a
// German user sees "Mo/Di/Mi..." instead of English names. This English
// array only covers the case of the value never being set at all.
// 3 letters, not 1: a single letter can't tell Sunday from Saturday
// apart (same for 'T': Tuesday vs Thursday) — showed up as e.g.
// "S 23 Oct 2027" in the picker's own title and From/To row labels with
// no way to tell which day that actually was.
const SHORT_FALLBACK = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
const MON_SHORT = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']

export default class extends Controller {
  static targets = [
    'backdrop', 'modal',
    'dateTitle',
    'slot1Btn', 'slot1Label', 'slot1Time', 'slot1Row', 'slot1InlineDate', 'slot1InlineTime',
    'slot2Btn', 'slot2Label', 'slot2Time', 'slot2Row', 'slot2InlineDate', 'slot2InlineTime',
    'allDayToggle',
    'dayScroll', 'monthScroll', 'yearScroll', 'hourScroll', 'minuteScroll',
    'dateDisplay', 'dateField', 'endDateField', 'startField', 'endField',
    'startTimeDisplay', 'endTimeDisplay', 'timeRow',
    'protoCard', 'protoDatePicker', 'protoTimePicker'
  ]

  static values = {
    periodRanges: { type: Array, default: [] },
    // prototype: single-stage mode (new UX) vs legacy two-stage
    prototype: { type: Boolean, default: true },
    // Locale-aware weekday abbreviations, Sunday-first (matches
    // Date#getDay()) — see config/locales/*.yml's date.abbr_day_names.
    weekdayNames: { type: Array, default: SHORT_FALLBACK }
  }

  // this.weekdayNamesValue directly would also work, but a private getter
  // keeps every SHORT[...] call site below unchanged and guards against a
  // malformed/short value (fewer than 7 entries) falling back safely
  // instead of throwing on an out-of-range index.
  get #SHORT () {
    return (this.weekdayNamesValue.length === 7) ? this.weekdayNamesValue : SHORT_FALLBACK
  }

  _allDay = false
  _mode = 'date'
  _pastDateConfirmed = false
  _pickDay = 1
  _pickMonth = 1
  _pickYear = 2026
  _pickDay2 = null
  _pickMonth2 = null
  _pickYear2 = null
  _pickHour1 = 12
  _pickMin1 = 0
  _pickHour2 = 13
  _pickMin2 = 0
  _editingSlot = 1
  // legacy stage targets (kept for fallback if prototype false)
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
    this.#showProto()
    this.backdropTarget.classList.remove('hidden')
    this.backdropTarget.style.display = 'block'
    this.modalTarget.classList.remove('hidden')
    this.modalTarget.style.display = 'flex'
    this.modalTarget.style.alignItems = 'center'
    this.modalTarget.style.justifyContent = 'center'
    this.modalTarget.style.position = 'fixed'
    this.modalTarget.style.inset = '0'
    this.modalTarget.style.zIndex = '70'
  }

  close () {
    this.backdropTarget.classList.add('hidden')
    this.backdropTarget.style.display = 'none'
    this.modalTarget.classList.add('hidden')
    this.modalTarget.style.display = 'none'
    this.#hideAllInline()
    this.#resetBold()
  }

  #hideAllInline () {
    ;['slot1InlineDate', 'slot1InlineTime', 'slot2InlineDate', 'slot2InlineTime'].forEach(n => {
      const t = this[`has${n[0].toUpperCase() + n.slice(1)}Target`] ? this[`${n}Target`] : null
      if (t) { t.classList.add('hidden'); t.style.display = 'none' }
    })
    ;['slot1Label', 'slot1Time', 'slot2Label', 'slot2Time'].forEach(n => {
      const t = this[`has${n[0].toUpperCase() + n.slice(1)}Target`] ? this[`${n}Target`] : null
      if (t) t.classList.remove('hidden')
    })
    this.#resetBold()
  }

  // click on empty card area → exit drum, show chosen dates
  exitInline (e) {
    if (e.target.closest('button')) return
    this.#hideAllInline()
  }

  // ---- prototype inline morph ----
  #showProto () {
    this._editingSlot = 1
    this._mode = 'date'
    this.#activateProtoPicker()
  }

  #activateProtoPicker () {
    this.#setBoldForEditingSlot()
    this.#hideAllInline()
    const isDate = this._mode === 'date'
    if (this._editingSlot === 1) {
      if (isDate) {
        this.slot1LabelTarget.classList.add('hidden')
        this.slot1InlineDateTarget.classList.remove('hidden')
        this.slot1InlineDateTarget.style.display = 'flex'
        if (!this.slot1InlineDateTarget.contains(this.protoDatePickerTarget)) this.slot1InlineDateTarget.appendChild(this.protoDatePickerTarget)
        this.protoDatePickerTarget.style.display = 'flex'
        this.protoTimePickerTarget.style.display = 'none'
      } else {
        this.slot1TimeTarget.classList.add('hidden')
        this.slot1InlineTimeTarget.classList.remove('hidden')
        this.slot1InlineTimeTarget.style.display = 'flex'
        if (!this.slot1InlineTimeTarget.contains(this.protoTimePickerTarget)) this.slot1InlineTimeTarget.appendChild(this.protoTimePickerTarget)
        this.protoTimePickerTarget.style.display = 'flex'
        this.protoDatePickerTarget.style.display = 'none'
      }
    } else {
      if (this._pickDay2 === null) { const d2 = this.#getSlot2Date(); this._pickDay2 = d2.getDate(); this._pickMonth2 = d2.getMonth() + 1; this._pickYear2 = d2.getFullYear() }
      if (isDate) {
        this.slot2LabelTarget.classList.add('hidden')
        this.slot2InlineDateTarget.classList.remove('hidden')
        this.slot2InlineDateTarget.style.display = 'flex'
        if (!this.slot2InlineDateTarget.contains(this.protoDatePickerTarget)) this.slot2InlineDateTarget.appendChild(this.protoDatePickerTarget)
        this.protoDatePickerTarget.style.display = 'flex'
        this.protoTimePickerTarget.style.display = 'none'
      } else {
        this.slot2TimeTarget.classList.add('hidden')
        this.slot2InlineTimeTarget.classList.remove('hidden')
        this.slot2InlineTimeTarget.style.display = 'flex'
        if (!this.slot2InlineTimeTarget.contains(this.protoTimePickerTarget)) this.slot2InlineTimeTarget.appendChild(this.protoTimePickerTarget)
        this.protoTimePickerTarget.style.display = 'flex'
        this.protoDatePickerTarget.style.display = 'none'
      }
    }
    requestAnimationFrame(() => {
      if (this._mode === 'date') {
        let pm = this._editingSlot === 2 ? this._pickMonth2 : this._pickMonth
        let pd = this._editingSlot === 2 ? this._pickDay2 : this._pickDay
        let py = this._editingSlot === 2 ? this._pickYear2 : this._pickYear
        if (this._editingSlot === 2 && pd === null) {
          const d2 = this.#getSlot2Date()
          this._pickDay2 = d2.getDate(); this._pickMonth2 = d2.getMonth() + 1; this._pickYear2 = d2.getFullYear()
          pm = this._pickMonth2; pd = this._pickDay2; py = this._pickYear2
        }
        this.#scrollTo(this.monthScrollTarget, pm)
        this.#scrollTo(this.dayScrollTarget, pd)
        this.#scrollTo(this.yearScrollTarget, py)
      } else {
        this.#scrollTo(this.hourScrollTarget, this.#getPickHour())
        this.#scrollTo(this.minuteScrollTarget, this.#getPickMin())
      }
      this.#highlightScrollers()
    })
  }

  // called from proto row taps
  editDate1 () { this._editingSlot = 1; this._mode = 'date'; this.#activateProtoPicker() }
  editDate2 () {
    this._editingSlot = 2; this._mode = 'date'
    if (this._pickDay2 === null) { const d2 = this.#getSlot2Date(); this._pickDay2 = d2.getDate(); this._pickMonth2 = d2.getMonth() + 1; this._pickYear2 = d2.getFullYear() }
    this.#activateProtoPicker()
  }

  editTime1 () { this._editingSlot = 1; this._mode = 'time'; this.#activateProtoPicker() }
  editTime2 () { this._editingSlot = 2; this._mode = 'time'; this.#activateProtoPicker() }

  #openStage2 () {
    const time24 = this.#getSlotTime24(this._editingSlot)
    const [h24raw, mRaw] = time24.split(':').map(Number)
    const [h24, m] = this.#round5(h24raw, mRaw)
    this.#setPickHour(h24); this.#setPickMin(m)
    let d
    if (this._editingSlot === 2 && this._mode === 'date') {
      d = this.#getSlot2Date(); this._pickDay2 = d.getDate(); this._pickMonth2 = d.getMonth() + 1; this._pickYear2 = d.getFullYear()
    } else {
      const dateStr = this.#dateStr()
      d = dateStr ? new Date(dateStr + 'T00:00:00') : new Date(this._pickYear, this._pickMonth - 1, this._pickDay)
      this._pickYear = d.getFullYear(); this._pickMonth = d.getMonth() + 1; this._pickDay = d.getDate()
    }
    this.#updateAllSlotLabels(); this.#setBoldForEditingSlot()
    requestAnimationFrame(() => {
      if (this._mode === 'date') {
        const pm = this._editingSlot === 2 ? this._pickMonth2 : this._pickMonth
        const pd = this._editingSlot === 2 ? this._pickDay2 : this._pickDay
        const py = this._editingSlot === 2 ? this._pickYear2 : this._pickYear
        this.#scrollTo(this.monthScrollTarget, pm); this.#scrollTo(this.dayScrollTarget, pd); this.#scrollTo(this.yearScrollTarget, py)
      } else { this.#scrollTo(this.hourScrollTarget, this.#getPickHour()); this.#scrollTo(this.minuteScrollTarget, this.#getPickMin()) }
      this.#highlightScrollers()
    })
    this.#activateProtoPicker()
  }

  confirmTime () {
    const time12 = this._allDay ? 'All day' : this.#fmtTime24(this.#getPickHour(), this.#getPickMin())
    const time24 = this.#fmtTime24(this.#getPickHour(), this.#getPickMin())
    this.#setSlotTime24(this._editingSlot, time24)
    this.#updateSlotTimeDisplay(this._editingSlot, time12)
    this.#activateProtoPicker()
  }

  confirm () {
    const dateStr = this.#dateStr(); if (!dateStr) return
    const today = new Date(); today.setHours(0, 0, 0, 0)
    const picked = new Date(dateStr + 'T00:00:00')
    if (picked < today && !this._pastDateConfirmed) {
      this.dispatch('past-date', { detail: { onConfirm: () => { this._pastDateConfirmed = true; this.confirm() } } }); return
    }
    this._pastDateConfirmed = false
    if (this.#isOnPeriod(dateStr)) this.dispatch('sensitive-period')
    this.dateFieldTarget.value = dateStr
    const d2 = this.#getSlot2Date()
    const endDateStr = `${d2.getFullYear()}-${String(d2.getMonth() + 1).padStart(2, '0')}-${String(d2.getDate()).padStart(2, '0')}`
    if (this.hasEndDateFieldTarget) this.endDateFieldTarget.value = endDateStr
    this.#applyDateDisplay(dateStr, endDateStr)
    if (this._allDay) { this.startFieldTarget.value = '00:00'; this.endFieldTarget.value = '23:59' } else {
      const s = this.#getSlotTime24(1).split(':').map(Number); this.startFieldTarget.value = `${String(s[0]).padStart(2, '0')}:${String(s[1]).padStart(2, '0')}`
      const e = this.#getSlotTime24(2).split(':').map(Number); this.endFieldTarget.value = `${String(e[0]).padStart(2, '0')}:${String(e[1]).padStart(2, '0')}`
    }
    if (this.hasStartTimeDisplayTarget) { const [sh, sm] = (this.startFieldTarget.value || '00:00').split(':').map(Number); this.startTimeDisplayTarget.textContent = this._allDay ? 'All day' : this.#fmt12h(sh, sm) }
    if (this.hasEndTimeDisplayTarget) { const [eh, em] = (this.endFieldTarget.value || '23:59').split(':').map(Number); this.endTimeDisplayTarget.textContent = this._allDay ? 'All day' : this.#fmt12h(eh, em) }
    this.close()
  }

  toggleAllDay () {
    this._allDay = !this._allDay
    this.allDayToggleTargets.forEach(btn => { btn.style.background = this._allDay ? '#933A35' : '#D9D9D9'; const d = btn.querySelector('span'); if (d) d.style.transform = this._allDay ? 'translateX(29px)' : 'translateX(0)' })
    this.#updateAllDayLabels()
  }

  #updateAllDayLabels () {
    const l1 = this._allDay ? 'All day' : this.#fmt12h(this._pickHour1, this._pickMin1)
    const l2 = this._allDay ? 'All day' : this.#fmt12h(this._pickHour2, this._pickMin2)
    this.#updateSlotTimeDisplay(1, l1); this.#updateSlotTimeDisplay(2, l2)
  }

  onHourScroll () { if (this._hrRaf) return; this._hrRaf = requestAnimationFrame(() => { this._hrRaf = null; const it = this.#closestItem(this.hourScrollTarget); if (it) this.#setPickHour(parseInt(it.dataset.value)); this.#highlightScrollers(); this.#updateAllSlotTimes() }) }
  onMinuteScroll () { if (this._minRaf) return; this._minRaf = requestAnimationFrame(() => { this._minRaf = null; const it = this.#closestItem(this.minuteScrollTarget); if (it) this.#setPickMin(parseInt(it.dataset.value)); this.#highlightScrollers(); this.#updateAllSlotTimes() }) }
  #updateAllSlotTimes () { const t12 = this.#fmt12h(this.#getPickHour(), this.#getPickMin()); const t24 = `${String(this.#getPickHour()).padStart(2, '0')}:${String(this.#getPickMin()).padStart(2, '0')}`; this.#setSlotTime24(this._editingSlot, t24); this.#updateSlotTimeDisplay(this._editingSlot, t12) }
  #getPickHour () { return this._editingSlot === 1 ? this._pickHour1 : this._pickHour2 }
  #getPickMin () { return this._editingSlot === 1 ? this._pickMin1 : this._pickMin2 }
  #setPickHour (v) { if (this._editingSlot === 1) this._pickHour1 = v; else this._pickHour2 = v }
  #setPickMin (v) { if (this._editingSlot === 1) this._pickMin1 = v; else this._pickMin2 = v }
  #getSlotTime24 (s) { return s === 1 ? this.#fmtTime24(this._pickHour1, this._pickMin1) : this.#fmtTime24(this._pickHour2, this._pickMin2) }
  #setSlotTime24 (slot, time24) {
    const v = time24 || this.#getSlotTime24(slot)
    if (slot === 1) this.slot1BtnTargets.forEach(el => { el.dataset.time24 = v })
    else this.slot2BtnTargets.forEach(el => { el.dataset.time24 = v })
  }

  #updateSlotTimeDisplay (slot, label) { if (slot === 1) this.slot1TimeTargets.forEach(el => { el.textContent = label }); else this.slot2TimeTargets.forEach(el => { el.textContent = label }) }
  // Falls back to the *same* day as slot1 when slot2 has no explicit
  // state yet (a brand-new appointment with no end_date field value) —
  // this used to add a day unconditionally, so opening the picker on a
  // fresh single-day appointment showed "To" defaulting to tomorrow even
  // though the server's own default_end (see new.html.erb) is start + 1
  // hour, same calendar day. Only an explicit end_date (a real multi-day
  // event, or the user actively picking a different end date) should
  // ever make slot2 land on a different day.
  #getSlot2Date () { if (this._pickDay2 !== null) return new Date(this._pickYear2, this._pickMonth2 - 1, this._pickDay2); return new Date(this._pickYear, this._pickMonth - 1, this._pickDay) }
  onDayScroll () { if (this._dRaf) return; this._dRaf = requestAnimationFrame(() => { this._dRaf = null; const it = this.#closestItem(this.dayScrollTarget); if (it) { if (this._editingSlot === 2 && this._mode === 'date') this._pickDay2 = parseInt(it.dataset.value); else this._pickDay = parseInt(it.dataset.value) } this.#highlightScrollers(); this.#updateActiveSlotLabel() }) }
  onMonthScroll () { if (this._moRaf) return; this._moRaf = requestAnimationFrame(() => { this._moRaf = null; const it = this.#closestItem(this.monthScrollTarget); if (it) { if (this._editingSlot === 2 && this._mode === 'date') this._pickMonth2 = parseInt(it.dataset.value); else this._pickMonth = parseInt(it.dataset.value) } this.#highlightScrollers(); this.#updateActiveSlotLabel() }) }
  onYearScroll () { if (this._yRaf) return; this._yRaf = requestAnimationFrame(() => { this._yRaf = null; const it = this.#closestItem(this.yearScrollTarget); if (it) { if (this._editingSlot === 2 && this._mode === 'date') this._pickYear2 = parseInt(it.dataset.value); else this._pickYear = parseInt(it.dataset.value) } this.#highlightScrollers(); this.#updateActiveSlotLabel() }) }
  #updateActiveSlotLabel () {
    const fmt = (d) => `${this.#SHORT[d.getDay()]} ${String(d.getDate()).padStart(2, '0')} ${MON_SHORT[d.getMonth()]} ${d.getFullYear()}`
    if (this._editingSlot === 1) {
      const d1 = new Date(this._pickYear, this._pickMonth - 1, this._pickDay)
      this.slot1LabelTargets.forEach(el => { el.textContent = fmt(d1) })
    } else {
      const d2 = this.#getSlot2Date()
      this.slot2LabelTargets.forEach(el => { el.textContent = fmt(d2) })
    }
  }

  #updateAllSlotLabels () {
    const d1 = new Date(this._pickYear, this._pickMonth - 1, this._pickDay); const d2 = this.#getSlot2Date()
    const fmt = (d) => `${this.#SHORT[d.getDay()]} ${String(d.getDate()).padStart(2, '0')} ${MON_SHORT[d.getMonth()]} ${d.getFullYear()}`
    this.slot1LabelTargets.forEach(el => { el.textContent = fmt(d1) }); this.slot2LabelTargets.forEach(el => { el.textContent = fmt(d2) })
  }

  #setBoldForEditingSlot () {
    this.slot1LabelTargets.forEach(el => { el.style.fontWeight = (this._editingSlot === 1 && this._mode === 'date') ? '700' : '500' })
    this.slot2LabelTargets.forEach(el => { el.style.fontWeight = (this._editingSlot === 2 && this._mode === 'date') ? '700' : '500' })
    this.slot1TimeTargets.forEach(el => { el.style.fontWeight = (this._editingSlot === 1 && this._mode === 'time') ? '700' : '500' })
    this.slot2TimeTargets.forEach(el => { el.style.fontWeight = (this._editingSlot === 2 && this._mode === 'time') ? '700' : '500' })
  }

  #resetBold () { this.slot1LabelTargets.forEach(el => { el.style.fontWeight = '500' }); this.slot2LabelTargets.forEach(el => { el.style.fontWeight = '500' }); this.slot1TimeTargets.forEach(el => { el.style.fontWeight = '500' }); this.slot2TimeTargets.forEach(el => { el.style.fontWeight = '500' }) }

  #highlightScrollers () { if (this._mode === 'date') { const pd = this._editingSlot === 2 ? this._pickDay2 : this._pickDay; const pm = this._editingSlot === 2 ? this._pickMonth2 : this._pickMonth; const py = this._editingSlot === 2 ? this._pickYear2 : this._pickYear; this.#highlightTrack(this.dayScrollTarget, pd); this.#highlightTrack(this.monthScrollTarget, pm); this.#highlightTrack(this.yearScrollTarget, py) } else { this.#highlightTrack(this.hourScrollTarget, this.#getPickHour()); this.#highlightTrack(this.minuteScrollTarget, this.#getPickMin()) } }
  #scrollTo (track, val) { const items = track.querySelectorAll('[data-value]'); for (const it of items) { if (parseInt(it.dataset.value) === val) { track.scrollTop = it.offsetTop - track.clientHeight / 2 + it.clientHeight / 2; break } } }
  #syncTimesFromField () { const [shRaw, smRaw] = (this.startFieldTarget.value || '19:00').split(':').map(Number); const [ehRaw, emRaw] = (this.endFieldTarget.value || '20:00').split(':').map(Number); const s = this.#round5(shRaw, smRaw); const e = this.#round5(ehRaw, emRaw); this._pickHour1 = s[0]; this._pickMin1 = s[1]; this._pickHour2 = e[0]; this._pickMin2 = e[1] }
  #highlightTrack (track, activeVal) { const items = track.querySelectorAll('[data-value]'); items.forEach(el => { const a = parseInt(el.dataset.value) === activeVal; el.style.opacity = a ? '1' : '0.35'; el.style.fontWeight = a ? '700' : '400'; el.style.color = a ? '#933A35' : 'rgba(147,58,53,0.35)'; el.style.fontSize = a ? '17px' : '16px'; el.style.transform = a ? 'scale(1.05)' : 'scale(1)' }) }
  #closestItem (track) { const cy = track.scrollTop + track.clientHeight / 2; let c = null; let md = Infinity; for (const el of track.querySelectorAll('[data-value]')) { const ec = el.offsetTop + el.clientHeight / 2; const d = Math.abs(ec - cy); if (d < md) { md = d; c = el } } return c }
  #applyDateDisplay (startDateStr, endDateStr) {
    const d1 = new Date(startDateStr + 'T00:00:00'); const d2 = endDateStr ? new Date(endDateStr + 'T00:00:00') : null; const multi = d2 && d2.toDateString() !== d1.toDateString()
    const dn1 = d1.toLocaleDateString('en-US', { weekday: 'short' }); const mn1 = d1.toLocaleDateString('en-US', { month: 'short' }); const n1 = d1.getDate(); const y1 = d1.getFullYear(); const o1 = this.#ordinal(n1)
    if (multi) { const dn2 = d2.toLocaleDateString('en-US', { weekday: 'short' }); const mn2 = d2.toLocaleDateString('en-US', { month: 'short' }); const n2 = d2.getDate(); const o2 = this.#ordinal(n2); const y2 = d2.getFullYear(); const l1 = `${dn1}. ${mn1} ${n1}${o1} ${y1}`; const l2 = `${dn2}. ${mn2} ${n2}${o2} ${y2}`; this.dateDisplayTarget.innerHTML = `${l1}<br><span class="font-light">-</span><br>${l2}` } else { this.dateDisplayTarget.textContent = `${dn1}. ${mn1} ${n1}${o1} ${y1}` }
    this.dateDisplayTarget.style.fontSize = ''; if (this.hasTimeRowTarget) this.timeRowTarget.classList.toggle('hidden', multi)
  }

  #setDateFromField () { const ds = this.dateFieldTarget.value || this.#todayStr(); const [y, m, d] = ds.split('-').map(Number); this._pickYear = y; this._pickMonth = m; this._pickDay = d; const eds = this.hasEndDateFieldTarget ? this.endDateFieldTarget.value : ''; if (eds) { const [ey, em, ed] = eds.split('-').map(Number); this._pickYear2 = ey; this._pickMonth2 = em; this._pickDay2 = ed } else { this._pickDay2 = null; this._pickMonth2 = null; this._pickYear2 = null } this.#updateDateTitle() }
  #buildSlots () { const d1 = new Date(this._pickYear, this._pickMonth - 1, this._pickDay); const d2 = this.#getSlot2Date(); const fmt = (d) => `${this.#SHORT[d.getDay()]} ${String(d.getDate()).padStart(2, '0')} ${MON_SHORT[d.getMonth()]} ${d.getFullYear()}`; this.slot1LabelTargets.forEach(el => { el.textContent = fmt(d1) }); this.slot2LabelTargets.forEach(el => { el.textContent = fmt(d2) }); const a = this.#fmt12h(this._pickHour1, this._pickMin1); const b = this.#fmt12h(this._pickHour2, this._pickMin2); this.slot1TimeTargets.forEach(el => { el.textContent = a }); this.slot2TimeTargets.forEach(el => { el.textContent = b }); this.slot1BtnTargets.forEach(el => { el.dataset.time24 = this.#getSlotTime24(1) }); this.slot2BtnTargets.forEach(el => { el.dataset.time24 = this.#getSlotTime24(2) }) }
  #updateDateTitle () { const d = new Date(this._pickYear, this._pickMonth - 1, this._pickDay); const dn = this.#SHORT[d.getDay()]; const mon = MON_SHORT[d.getMonth()]; const dd = String(d.getDate()).padStart(2, '0'); const yy = d.getFullYear(); this.dateTitleTarget.textContent = `${dn} ${dd} ${mon} ${yy}` }
  #updateDateDisplay () { const s = this.dateFieldTarget.value; if (!s) return; const e = this.hasEndDateFieldTarget ? this.endDateFieldTarget.value : ''; this.#applyDateDisplay(s, e || null) }
  #updateTimeDisplays () { if (this.hasStartTimeDisplayTarget) { const [sh, sm] = (this.startFieldTarget.value || '19:00').split(':').map(Number); this.startTimeDisplayTarget.textContent = this.#fmt12h(...this.#round5(sh, sm)) } if (this.hasEndTimeDisplayTarget) { const [eh, em] = (this.endFieldTarget.value || '20:00').split(':').map(Number); this.endTimeDisplayTarget.textContent = this.#fmt12h(...this.#round5(eh, em)) } }
  #isOnPeriod (ds) { return this.periodRangesValue.some(([s, e]) => ds >= s && ds <= e) }
  #round5 (h, m) { return [h, Math.floor(m / 5) * 5] }
  #fmtTime24 (h, m) { return `${String(h).padStart(2, '0')}:${String(m).padStart(2, '0')}` }
  #fmt12h (h, m) { return this.#fmtTime24(h, m) }
  #dateStr () { return `${this._pickYear}-${String(this._pickMonth).padStart(2, '0')}-${String(this._pickDay).padStart(2, '0')}` }
  #todayStr () { const n = new Date(); return `${n.getFullYear()}-${String(n.getMonth() + 1).padStart(2, '0')}-${String(n.getDate()).padStart(2, '0')}` }
  #ordinal (n) { if (n > 3 && n < 21) return 'th'; switch (n % 10) { case 1:return 'st'; case 2:return 'nd'; case 3:return 'rd'; default:return 'th' } }
}
