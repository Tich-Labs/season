/* global requestAnimationFrame */
import { Controller } from '@hotwired/stimulus'

const SHORT = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa']

export default class extends Controller {
  static targets = [
    'backdrop', 'modal',
    'stage1', 'stage2',
    'dateTitle',
    'slot1Btn', 'slot1Label', 'slot1Time',
    'slot2Btn', 'slot2Label', 'slot2Time',
    'allDayToggle',
    'dayScroll', 'monthScroll', 'yearScroll', 'hourScroll', 'minuteScroll', 'stage2Title',
    'dateDisplay', 'dateField', 'startField', 'endField'
  ]

  _allDay = false
  _mode = 'date'
  _pickDay = 1
  _pickMonth = 1
  _pickYear = 2026
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
    const [h24, m] = time24.split(':').map(Number)
    this.#setPickHour(h24)
    this.#setPickMin(Math.round(m / 5) * 5)

    const dateStr = this.#dateStr()
    const d = dateStr ? new Date(dateStr + 'T00:00:00') : new Date(this._pickYear, this._pickMonth - 1, this._pickDay)
    this._pickYear = d.getFullYear()
    this._pickMonth = d.getMonth() + 1
    this._pickDay = d.getDate()

    const dayName = d.toLocaleDateString('en-US', { weekday: 'short' })
    const month = String(d.getMonth() + 1).padStart(2, '0')
    const dateNum = String(d.getDate()).padStart(2, '0')
    const year = d.getFullYear()
    this.stage2TitleTarget.textContent = `${dayName} ${month}.${dateNum}.${year}`

    this.#updateAllSlotLabels()
    this.#setBoldForEditingSlot()

    requestAnimationFrame(() => {
      if (this._mode === 'date') {
        this.#scrollTo(this.monthScrollTarget, this._pickMonth)
        this.#scrollTo(this.dayScrollTarget, this._pickDay)
        this.#scrollTo(this.yearScrollTarget, this._pickYear)
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

    this.#applyDate(dateStr)

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

    // Sync time-picker display buttons on the main page
    const startDisplay = this.element.querySelector('[data-appointment-date-picker-target="startField"]')
      ?.closest('[data-controller="time-picker"]')?.querySelector('[data-time-picker-target="display"]')
    const endDisplay = this.element.querySelector('[data-appointment-date-picker-target="endField"]')
      ?.closest('[data-controller="time-picker"]')?.querySelector('[data-time-picker-target="display"]')

    if (startDisplay) {
      const [sh, sm] = (this.startFieldTarget.value || '00:00').split(':').map(Number)
      startDisplay.textContent = this._allDay ? 'All day' : this.#fmt12h(sh, sm)
    }
    if (endDisplay) {
      const [eh, em] = (this.endFieldTarget.value || '23:59').split(':').map(Number)
      endDisplay.textContent = this._allDay ? 'All day' : this.#fmt12h(eh, em)
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
  #setPickMin (v) { if (this._editingSlot === 1) this._pickMin1 = Math.round(v / 5) * 5; else this._pickMin2 = Math.round(v / 5) * 5 }

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

  onDayScroll () {
    if (this._dRaf) return
    this._dRaf = requestAnimationFrame(() => {
      this._dRaf = null
      const item = this.#closestItem(this.dayScrollTarget)
      if (item) this._pickDay = parseInt(item.dataset.value)
      this.#highlightScrollers()
      this.#updateAllSlotLabels()
    })
  }

  onMonthScroll () {
    if (this._moRaf) return
    this._moRaf = requestAnimationFrame(() => {
      this._moRaf = null
      const item = this.#closestItem(this.monthScrollTarget)
      if (item) this._pickMonth = parseInt(item.dataset.value)
      this.#highlightScrollers()
      this.#updateAllSlotLabels()
    })
  }

  onYearScroll () {
    if (this._yRaf) return
    this._yRaf = requestAnimationFrame(() => {
      this._yRaf = null
      const item = this.#closestItem(this.yearScrollTarget)
      if (item) this._pickYear = parseInt(item.dataset.value)
      this.#highlightScrollers()
      this.#updateAllSlotLabels()
    })
  }

  #updateAllSlotLabels () {
    const d = new Date(this._pickYear, this._pickMonth - 1, this._pickDay)
    const dayName = d.toLocaleDateString('en-US', { weekday: 'short' })
    const month = String(d.getMonth() + 1).padStart(2, '0')
    const dateNum = String(d.getDate()).padStart(2, '0')
    const year = d.getFullYear()
    this.stage2TitleTarget.textContent = `${dayName} ${month}.${dateNum}.${year}`

    const dateShort = `${SHORT[d.getDay()]} ${month}.${dateNum}.${year}`
    const tomorrow = new Date(d)
    tomorrow.setDate(tomorrow.getDate() + 1)
    const date2Short = `${SHORT[tomorrow.getDay()]} ${String(tomorrow.getMonth() + 1).padStart(2, '0')}.${String(tomorrow.getDate()).padStart(2, '0')}.${tomorrow.getFullYear()}`

    this.slot1LabelTargets.forEach(el => { el.textContent = dateShort })
    this.slot2LabelTargets.forEach(el => { el.textContent = date2Short })
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
    const divider = this.stage2Target.querySelector('[data-stage2-divider]')
    const allday = this.stage2Target.querySelector('[data-stage2-allday]')
    const button = this.stage2Target.querySelector('[data-stage2-button]')
    const card = this.modalTarget.querySelector('div')

    if (this._editingSlot === 1) {
      picker.style.top = '170px'
      divider.style.top = '268px'
      slot2.style.top = '282px'
      allday.style.top = '410px'
      button.style.top = '475px'
      card.style.height = '575px'
    } else {
      picker.style.top = '240px'
      divider.style.top = '338px'
      slot2.style.top = '185px'
      allday.style.top = '355px'
      button.style.top = '420px'
      card.style.height = '520px'
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
    const [sh, sm] = (this.startFieldTarget.value || '19:00').split(':').map(Number)
    const [eh, em] = (this.endFieldTarget.value || '20:00').split(':').map(Number)
    this._pickHour1 = sh
    this._pickMin1 = Math.round(sm / 5) * 5
    this._pickHour2 = eh
    this._pickMin2 = Math.round(em / 5) * 5
  }

  #highlightScrollers () {
    if (this._mode === 'date') {
      this.#highlightTrack(this.dayScrollTarget, this._pickDay)
      this.#highlightTrack(this.monthScrollTarget, this._pickMonth)
      this.#highlightTrack(this.yearScrollTarget, this._pickYear)
    } else {
      this.#highlightTrack(this.hourScrollTarget, this.#getPickHour())
      this.#highlightTrack(this.minuteScrollTarget, this.#getPickMin())
    }
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

  #applyDate (dateStr) {
    const d = new Date(dateStr + 'T00:00:00')
    const dayName = d.toLocaleDateString('en-US', { weekday: 'short' })
    const monthName = d.toLocaleDateString('en-US', { month: 'long' })
    const dateNum = d.getDate()
    const year = d.getFullYear()
    const nth = this.#ordinal(dateNum)
    this.dateDisplayTarget.textContent = `${dayName}. ${monthName} ${dateNum}${nth} ${year}`
    this.dateFieldTarget.value = dateStr
  }

  #dateStr () {
    return `${this._pickYear}-${String(this._pickMonth).padStart(2, '0')}-${String(this._pickDay).padStart(2, '0')}`
  }

  #updateDateTitle () {
    const d = new Date(this._pickYear, this._pickMonth - 1, this._pickDay)
    const dayName = d.toLocaleDateString('en-US', { weekday: 'short' })
    const month = String(d.getMonth() + 1).padStart(2, '0')
    const dateNum = String(d.getDate()).padStart(2, '0')
    const year = d.getFullYear()
    this.dateTitleTarget.textContent = `${dayName} ${month}.${dateNum}.${year}`
  }

  #updateDateDisplay () {
    const dateStr = this.dateFieldTarget.value
    if (!dateStr) return
    const d = new Date(dateStr + 'T00:00:00')
    const dayName = d.toLocaleDateString('en-US', { weekday: 'short' })
    const monthName = d.toLocaleDateString('en-US', { month: 'long' })
    const dateNum = d.getDate()
    const year = d.getFullYear()
    const nth = this.#ordinal(dateNum)
    this.dateDisplayTarget.textContent = `${dayName}. ${monthName} ${dateNum}${nth} ${year}`
  }

  #updateTimeDisplays () {
    const startDisplay = this.element.querySelector('[data-appointment-date-picker-target="startField"]')
      ?.closest('[data-controller="time-picker"]')?.querySelector('[data-time-picker-target="display"]')
    const endDisplay = this.element.querySelector('[data-appointment-date-picker-target="endField"]')
      ?.closest('[data-controller="time-picker"]')?.querySelector('[data-time-picker-target="display"]')

    if (startDisplay) {
      const [sh, sm] = (this.startFieldTarget.value || '19:00').split(':').map(Number)
      startDisplay.textContent = this.#fmt12h(sh, Math.round(sm / 5) * 5)
    }
    if (endDisplay) {
      const [eh, em] = (this.endFieldTarget.value || '20:00').split(':').map(Number)
      endDisplay.textContent = this.#fmt12h(eh, Math.round(em / 5) * 5)
    }
  }

  #setDateFromField () {
    const dateStr = this.dateFieldTarget.value || this.#todayStr()
    const [y, m, d] = dateStr.split('-').map(Number)
    this._pickYear = y
    this._pickMonth = m
    this._pickDay = d
    this.#updateDateTitle()
  }

  #buildSlots () {
    const dateStr = this.#dateStr() || this.#todayStr()
    const d = new Date(dateStr + 'T00:00:00')
    const tomorrow = new Date(d)
    tomorrow.setDate(tomorrow.getDate() + 1)

    const sd = SHORT[d.getDay()]
    const td = SHORT[tomorrow.getDay()]
    const date1Str = `${String(d.getMonth() + 1).padStart(2, '0')}.${String(d.getDate()).padStart(2, '0')}.${d.getFullYear()}`
    const date2Str = `${String(tomorrow.getMonth() + 1).padStart(2, '0')}.${String(tomorrow.getDate()).padStart(2, '0')}.${tomorrow.getFullYear()}`

    this.slot1LabelTarget.textContent = `${sd} ${date1Str}`
    this.slot2LabelTarget.textContent = `${td} ${date2Str}`

    const time12a = this.#fmt12h(this._pickHour1, this._pickMin1)
    const time12b = this.#fmt12h(this._pickHour2, this._pickMin2)
    this.slot1TimeTarget.textContent = time12a
    this.slot2TimeTarget.textContent = time12b

    this.slot1BtnTargets.forEach(el => { el.dataset.time24 = this.#getSlotTime24(1) })
    this.slot2BtnTargets.forEach(el => { el.dataset.time24 = this.#getSlotTime24(2) })
  }

  #fmt12h (h24, m) {
    const ampm = h24 >= 12 ? 'PM' : 'AM'
    const h12 = h24 % 12 || 12
    return `${h12}:${String(m).padStart(2, '0')} ${ampm}`
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
