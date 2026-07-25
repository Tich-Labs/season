import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['modal', 'backdrop', 'closeBtn', 'categoryInput', 'categoryOption', 'triggerButton', 'locationModal', 'locationBackdrop', 'locationInput', 'locationField', 'locationCard', 'locationResults', 'locationSubmitBg', 'locationSubmitBtn', 'locationLabel', 'locationIconBg', 'notesModal', 'notesBackdrop', 'notesInput', 'notesField', 'notesLabel', 'notesIconBg', 'guestsModal', 'guestsBackdrop', 'guestsInput', 'guestsField', 'guestsLabel', 'guestsIconBg', 'guestsList', 'guestsCard', 'guestsSubmitBg', 'guestsSubmitBtn', 'guestsInlineList', 'reminderModal', 'reminderBackdrop', 'reminderField', 'reminderLabel', 'reminderIconBg', 'reminderOption', 'repeatModal', 'repeatBackdrop', 'repeatLabel', 'repeatIconBg', 'repeatOption', 'repeatSubOptions', 'repeatField', 'customRepeatModal', 'customRepeatBackdrop', 'repeatUntilModal', 'repeatUntilBackdrop', 'customReminderModal', 'customReminderBackdrop', 'customReminderNum', 'customReminderUnit', 'attentionModal', 'attentionBackdrop', 'attentionTitle', 'attentionBody', 'attentionConfirm', 'attentionCancel', 'recurringModal', 'recurringBackdrop', 'notifyModal', 'notifyBackdrop']
  static values = {
    selectedCategory: String,
    lastLat: Number,
    lastLon: Number
  }

  connect () {
    this._escHandler = (e) => {
      if (e.key === 'Escape') {
        if (!this.modalTarget.classList.contains('hidden')) {
          this.close()
        }
        if (this.hasLocationModalTarget && !this.locationModalTarget.classList.contains('hidden')) {
          this.closeLocation()
        }
        if (this.hasNotesModalTarget && !this.notesModalTarget.classList.contains('hidden')) {
          this.closeNotes()
        }
        if (this.hasGuestsModalTarget && !this.guestsModalTarget.classList.contains('hidden')) {
          this.closeGuests()
        }
        if (this.hasReminderModalTarget && !this.reminderModalTarget.classList.contains('hidden')) {
          this.closeReminder()
        }
        if (this.hasRepeatModalTarget && !this.repeatModalTarget.classList.contains('hidden')) {
          this.closeRepeat()
        }
        if (this.hasCustomReminderModalTarget && !this.customReminderModalTarget.classList.contains('hidden')) {
          this.closeCustomReminder()
        }
        if (this.hasAttentionModalTarget && !this.attentionModalTarget.classList.contains('hidden')) {
          this.closeAttention()
        }
      }
    }
    document.addEventListener('keydown', this._escHandler)

    // Track whether the user has actually modified the form
    this._formDirty = false
    this._submitting = false
    const _watchForm = this.element.querySelector('form')
    if (_watchForm) {
      _watchForm.addEventListener('input', () => { this._formDirty = true })
      _watchForm.addEventListener('change', () => { this._formDirty = true })
      _watchForm.addEventListener('submit', () => { this._submitting = true })
    }

    this._turboBeforeVisit = (event) => {
      if (!this.hasAttentionModalTarget) return
      if (!this._formDirty) return
      if (this._submitting) return
      const form = this.element.querySelector('form')
      if (!form) return
      const title = (new FormData(form).get('calendar_event[title]') || '').trim()
      if (!title) return
      event.preventDefault()
      this._pendingNavUrl = event.detail.url
      this.openAttention({
        body: "The appointment hasn't been saved yet. Are you sure you want to leave?",
        cancelLabel: 'Keep editing',
        confirmLabel: 'Delete',
        onConfirm: () => { window.location.href = this._pendingNavUrl }
      })
    }
    document.addEventListener('turbo:before-visit', this._turboBeforeVisit)

    this.element.addEventListener('appointment-date-picker:past-date', () => this.showPastDateAlert())
    this.element.addEventListener('appointment-date-picker:sensitive-period', (e) => this.showSensitivePeriodAlert(e.detail?.message))

    if (this.hasBackdropTarget) {
      this.backdropTarget.addEventListener('click', () => this.close())
    }
    if (this.hasLocationBackdropTarget) {
      this.locationBackdropTarget.addEventListener('click', () => this.closeLocation())
    }
    if (this.hasNotesBackdropTarget) {
      this.notesBackdropTarget.addEventListener('click', () => this.closeNotes())
    }
    if (this.hasGuestsBackdropTarget) {
      this.guestsBackdropTarget.addEventListener('click', () => this.closeGuests())
    }
    if (this.hasReminderBackdropTarget) {
      this.reminderBackdropTarget.addEventListener('click', () => this.closeReminder())
    }
    if (this.hasRepeatBackdropTarget) {
      this.repeatBackdropTarget.addEventListener('click', () => this.closeRepeat())
    }
    if (this.hasCustomRepeatBackdropTarget) {
      this.customRepeatBackdropTarget.addEventListener('click', () => this.closeCustomRepeat())
    }

    if (this.hasCategoryInputTarget) {
      this.selectedCategoryValue = this.categoryInputTarget.value
    }

    this.#restoreVisuals()
    this.element.addEventListener('form-persistence:restored', () => this.#restoreVisuals())
  }

  disconnect () {
    document.removeEventListener('keydown', this._escHandler)
    document.removeEventListener('turbo:before-visit', this._turboBeforeVisit)
  }

  open () {
    this.backdropTarget.classList.remove('hidden')
    this.backdropTarget.style.display = 'block'
    this.modalTarget.classList.remove('hidden')
    this.modalTarget.style.display = 'flex'
    setTimeout(() => this.closeBtnTarget?.focus(), 0)
  }

  close () {
    this.modalTarget.classList.add('hidden')
    this.modalTarget.style.display = 'none'
    this.backdropTarget.classList.add('hidden')
    this.backdropTarget.style.display = 'none'
  }

  selectCategory (event) {
    const button = event.currentTarget
    const category = button.dataset.categoryNameValue

    if (!category || !this.hasCategoryInputTarget) return

    this.selectedCategoryValue = category
    this.categoryInputTarget.value = category
    this.#notifyPersistence(this.categoryInputTarget)

    this.categoryOptionTargets.forEach((option) => {
      const optionCategory = option.dataset.categoryNameValue
      const isSelected = optionCategory === category
      option.style.color = isSelected ? '#933A35' : '#EDE1D5'
      option.style.opacity = '1'
      const icon = option.querySelector('img')
      const wrapper = icon ? icon.parentElement : null
      if (icon) {
        icon.style.opacity = '1'
        icon.style.filter = isSelected ? 'brightness(0) saturate(100%) invert(28%) sepia(84%) saturate(1607%) hue-rotate(342deg) brightness(63%) contrast(94%)' : 'none'
      }
      if (wrapper) {
        wrapper.style.background = 'transparent'
      }
    })

    this.updateTriggerButton(button.querySelector('img'))
  }

  deleteCategory () {
    if (!this.hasCategoryInputTarget) return

    this.selectedCategoryValue = ''
    this.categoryInputTarget.value = ''

    this.categoryOptionTargets.forEach((option) => {
      option.style.color = '#EDE1D5'
      option.style.opacity = '1'
      const icon = option.querySelector('img')
      if (icon) {
        icon.style.opacity = '1'
        icon.style.filter = 'none'
      }
      const wrapper = icon ? icon.parentElement : null
      if (wrapper) {
        wrapper.style.background = 'transparent'
      }
    })

    this.resetTriggerButton()
  }

  resetTriggerButton () {
    if (!this.hasTriggerButtonTarget) return
    this.triggerButtonTarget.innerHTML = '<svg width="24" height="24" fill="none" viewBox="0 0 24 24"><path d="M12 5v14M5 12h14" stroke="#A43600" stroke-width="2.5" stroke-linecap="round"></path></svg>'
    this.triggerButtonTarget.style.background = ''
  }

  updateTriggerButton (iconImg) {
    if (!this.hasTriggerButtonTarget || !iconImg) return
    this.triggerButtonTarget.innerHTML = ''
    const clone = iconImg.cloneNode(true)
    clone.style.width = '36px'
    clone.style.height = '36px'
    clone.style.filter = 'brightness(0) saturate(100%) invert(28%) sepia(84%) saturate(1607%) hue-rotate(342deg) brightness(63%) contrast(94%)'
    this.triggerButtonTarget.appendChild(clone)
    this.triggerButtonTarget.style.background = ''
  }

  openLocation () {
    this.locationBackdropTarget.classList.remove('hidden')
    this.locationBackdropTarget.style.display = 'block'
    this.locationModalTarget.classList.remove('hidden')
    this.locationModalTarget.style.display = 'flex'
    if (this.hasLocationFieldTarget && this.hasLocationInputTarget) {
      this.locationInputTarget.value = this.locationFieldTarget.value || ''
      this.locationInputTarget.style.color = 'rgba(147,58,53,0.5)'
    }
    this._collapseLocation()
    this._updateSubmitOpacity()
    setTimeout(() => this.locationInputTarget?.focus(), 100)
  }

  closeLocation () {
    this.locationModalTarget.classList.add('hidden')
    this.locationModalTarget.style.display = 'none'
    this.locationBackdropTarget.classList.add('hidden')
    this.locationBackdropTarget.style.display = 'none'
    this._collapseLocation()
    this._clearResults()
  }

  submitLocation () {
    const value = this.hasLocationInputTarget ? this.locationInputTarget.value.trim() : ''
    if (this.hasLocationFieldTarget) {
      this.locationFieldTarget.value = value
      this.#notifyPersistence(this.locationFieldTarget)
    }
    this._updateLocationLabel(value)
    this.closeLocation()
  }

  searchLocations () {
    const query = this.locationInputTarget.value.trim()
    this._updateSubmitOpacity()
    if (query.length < 2) {
      this._collapseLocation()
      this._clearResults()
      return
    }

    this._debouncedFetch(query)
  }

  selectLocation (event) {
    const fullName = event.currentTarget.dataset.locationFull
    const short = this.#cleanLocationName(fullName)
    this.lastLatValue = parseFloat(event.currentTarget.dataset.locationLat) || 0
    this.lastLonValue = parseFloat(event.currentTarget.dataset.locationLon) || 0
    this.locationInputTarget.value = short
    this.locationInputTarget.style.color = '#933A35'
    if (this.hasLocationFieldTarget) {
      this.locationFieldTarget.value = short
      this.#notifyPersistence(this.locationFieldTarget)
    }
    this._updateLocationLabel(short)
    this._updateSubmitOpacity()
    this._collapseLocation()
    this._clearResults()
  }

  _updateLocationLabel (value) {
    if (!this.hasLocationLabelTarget) return
    if (value) {
      this.locationLabelTarget.textContent = value
      this.locationLabelTarget.classList.remove('text-brand-graytext')
      this.locationLabelTarget.classList.add('text-brand-primary')
      if (this.hasLocationIconBgTarget) {
        this.locationIconBgTarget.classList.remove('bg-brand-field/50')
        this.locationIconBgTarget.classList.add('bg-brand-field')
        const svg = this.locationIconBgTarget.querySelector('svg')
        if (svg) svg.removeAttribute('opacity')
      }
    } else {
      this.locationLabelTarget.textContent = 'Add location'
      this.locationLabelTarget.classList.add('text-brand-graytext')
      this.locationLabelTarget.classList.remove('text-brand-primary')
      if (this.hasLocationIconBgTarget) {
        this.locationIconBgTarget.classList.add('bg-brand-field/50')
        this.locationIconBgTarget.classList.remove('bg-brand-field')
        const svg = this.locationIconBgTarget.querySelector('svg')
        if (svg) svg.setAttribute('opacity', '0.5')
      }
    }
  }

  openNotes () {
    this.notesBackdropTarget.classList.remove('hidden')
    this.notesBackdropTarget.style.display = 'block'
    this.notesModalTarget.classList.remove('hidden')
    this.notesModalTarget.style.display = 'flex'
    if (this.hasNotesFieldTarget && this.hasNotesInputTarget) {
      this.notesInputTarget.value = this.notesFieldTarget.value || ''
    }
    setTimeout(() => this.notesInputTarget?.focus(), 100)
  }

  closeNotes () {
    this.notesModalTarget.classList.add('hidden')
    this.notesModalTarget.style.display = 'none'
    this.notesBackdropTarget.classList.add('hidden')
    this.notesBackdropTarget.style.display = 'none'
  }

  submitNotes () {
    const value = this.hasNotesInputTarget ? this.notesInputTarget.value.trim() : ''
    if (this.hasNotesFieldTarget) {
      this.notesFieldTarget.value = value
      this.#notifyPersistence(this.notesFieldTarget)
    }
    this._updateNotesLabel(value)
    this.closeNotes()
  }

  _updateNotesLabel (value) {
    if (!this.hasNotesLabelTarget) return
    if (value) {
      this.notesLabelTarget.textContent = value.length > 30 ? value.substring(0, 30) + '...' : value
      this.notesLabelTarget.classList.remove('text-brand-graytext')
      this.notesLabelTarget.classList.add('text-brand-primary')
      if (this.hasNotesIconBgTarget) {
        this.notesIconBgTarget.classList.remove('bg-brand-field/50')
        this.notesIconBgTarget.classList.add('bg-brand-field')
        const svg = this.notesIconBgTarget.querySelector('svg')
        if (svg) svg.removeAttribute('stroke-opacity')
      }
    } else {
      this.notesLabelTarget.textContent = 'Notes...'
      this.notesLabelTarget.classList.add('text-brand-graytext')
      this.notesLabelTarget.classList.remove('text-brand-primary')
      if (this.hasNotesIconBgTarget) {
        this.notesIconBgTarget.classList.add('bg-brand-field/50')
        this.notesIconBgTarget.classList.remove('bg-brand-field')
        const svg = this.notesIconBgTarget.querySelector('svg')
        if (svg) svg.setAttribute('stroke-opacity', '0.5')
      }
    }
  }

  #restoreVisuals () {
    if (this.hasCategoryInputTarget && this.categoryInputTarget.value) {
      this.selectedCategoryValue = this.categoryInputTarget.value
      const option = this.hasCategoryOptionTarget
        ? this.categoryOptionTargets.find(opt => opt.dataset.categoryNameValue === this.categoryInputTarget.value)
        : null
      if (option) {
        const icon = option.querySelector('img')
        if (icon) this.updateTriggerButton(icon)
      }
    }
    if (this.hasLocationFieldTarget && this.locationFieldTarget.value) {
      this._updateLocationLabel(this.locationFieldTarget.value)
    }
    if (this.hasNotesFieldTarget && this.notesFieldTarget.value) {
      this._updateNotesLabel(this.notesFieldTarget.value)
    }
    if (this.hasGuestsFieldTarget && this.guestsFieldTarget.value) {
      this._updateGuestsLabel(this.guestsFieldTarget.value)
    }
    if (this.hasReminderFieldTarget && this.reminderFieldTarget.value) {
      this.#updateReminderLabel(parseInt(this.reminderFieldTarget.value))
    }
  }

  openGuests () {
    this.guestsBackdropTarget.classList.remove('hidden')
    this.guestsBackdropTarget.style.display = 'block'
    this.guestsModalTarget.classList.remove('hidden')
    this.guestsModalTarget.style.display = 'flex'
    this._renderGuestsList()
    this._repositionGuestsSubmit()
    setTimeout(() => this.guestsInputTarget?.focus(), 100)
  }

  closeGuests () {
    this.guestsModalTarget.classList.add('hidden')
    this.guestsModalTarget.style.display = 'none'
    this.guestsBackdropTarget.classList.add('hidden')
    this.guestsBackdropTarget.style.display = 'none'
  }

  addGuest () {
    const email = this.hasGuestsInputTarget ? this.guestsInputTarget.value.trim() : ''
    if (!email || !this.#isValidEmail(email)) return

    const guests = this.#parseGuests()
    if (!guests.includes(email)) {
      guests.push(email)
      this.#saveGuests(guests)
    }

    this.guestsInputTarget.value = ''
    this._renderGuestsList()
    this._repositionGuestsSubmit()
    this.guestsInputTarget.focus()
  }

  removeGuest (event) {
    event.stopPropagation()
    const email = event.currentTarget.dataset.guestEmail
    const guests = this.#parseGuests().filter(e => e !== email)
    this.#saveGuests(guests)
    this._renderGuestsList()
    this.#renderGuestsInline()
    this._repositionGuestsSubmit()
  }

  guestsKeydown (event) {
    if (event.key === 'Enter') {
      event.preventDefault()
      this.addGuest()
    }
  }

  _updateGuestsLabel (raw) {
    const guests = (raw || '').split(',').map(s => s.trim()).filter(s => s.length > 0)
    if (guests.length > 0) {
      if (this.hasGuestsLabelTarget) this.guestsLabelTarget.classList.add('hidden')
      if (this.hasGuestsInlineListTarget) this.guestsInlineListTarget.classList.remove('hidden')
      if (this.hasGuestsIconBgTarget) {
        this.guestsIconBgTarget.classList.remove('bg-brand-field/50')
        this.guestsIconBgTarget.classList.add('bg-brand-field')
        const svg = this.guestsIconBgTarget.querySelector('svg')
        if (svg) svg.removeAttribute('opacity')
      }
      this.#renderGuestsInline()
    } else {
      if (this.hasGuestsLabelTarget) this.guestsLabelTarget.classList.remove('hidden')
      if (this.hasGuestsInlineListTarget) this.guestsInlineListTarget.classList.add('hidden')
      if (this.hasGuestsIconBgTarget) {
        this.guestsIconBgTarget.classList.add('bg-brand-field/50')
        this.guestsIconBgTarget.classList.remove('bg-brand-field')
        const svg = this.guestsIconBgTarget.querySelector('svg')
        if (svg) svg.setAttribute('opacity', '0.5')
      }
    }
  }

  #renderGuestsInline () {
    if (!this.hasGuestsInlineListTarget) return
    const guests = this.#parseGuests()
    if (guests.length === 0) {
      this.guestsInlineListTarget.innerHTML = ''
      return
    }
    let html = ''
    guests.forEach((email) => {
      html += '<div class="flex items-center justify-between gap-2">' +
        '<span class="text-brand-primary text-base font-medium tracking-007 font-sans truncate">' + email + '</span>' +
        '<button type="button" data-action="click->season-modal#removeGuest" data-guest-email="' + email + '" class="shrink-0 bg-transparent border-none cursor-pointer p-0 w-6 h-6 flex items-center justify-center">' +
        '<svg width="12" height="12" viewBox="0 0 12 12" fill="none"><path d="M9 3L3 9M3 3l6 6" stroke="#933A35" stroke-width="1.5" stroke-linecap="round"/></svg>' +
        '</button>' +
        '</div>'
    })
    this.guestsInlineListTarget.innerHTML = html
  }

  _renderGuestsList () {
    if (!this.hasGuestsListTarget) return
    const guests = this.#parseGuests()
    this.guestsListTarget.innerHTML = ''

    guests.forEach((email) => {
      const row = document.createElement('div')
      row.style.cssText = 'width:284px;height:24px;display:flex;align-items:center;justify-content:space-between;padding:0;'

      row.innerHTML =
        '<span style="font-family:Montserrat;font-weight:500;font-size:16px;line-height:20px;letter-spacing:0.07em;color:#933A35;">' + email + '</span>' +
        '<button type="button" data-action="click->season-modal#removeGuest" data-guest-email="' + email + '" style="background:transparent;border:none;cursor:pointer;padding:0;width:24px;height:24px;display:flex;align-items:center;justify-content:center;">' +
        '<svg width="12" height="12" viewBox="0 0 12 12" fill="none"><path d="M9 3L3 9M3 3l6 6" stroke="#933A35" stroke-width="1.5" stroke-linecap="round"/></svg>' +
        '</button>'

      this.guestsListTarget.appendChild(row)
    })
  }

  _repositionGuestsSubmit () {
    const guests = this.#parseGuests()
    const count = guests.length
    const baseTop = 241
    const offset = count * 29
    const newTop = Math.min(baseTop + offset, 339)

    if (this.hasGuestsCardTarget) {
      this.guestsCardTarget.style.height = (331 + offset) + 'px'
    }
    if (this.hasGuestsSubmitBgTarget) {
      this.guestsSubmitBgTarget.style.top = newTop + 'px'
    }
    if (this.hasGuestsSubmitBtnTarget) {
      this.guestsSubmitBtnTarget.style.top = newTop + 'px'
    }
    if (this.hasGuestsListTarget) {
      this.guestsListTarget.style.top = '228px'
    }
  }

  #parseGuests () {
    const raw = this.hasGuestsFieldTarget ? this.guestsFieldTarget.value : ''
    return raw.split(',').map(s => s.trim()).filter(s => s.length > 0)
  }

  #saveGuests (list) {
    if (this.hasGuestsFieldTarget) {
      this.guestsFieldTarget.value = list.join(', ')
      this.#notifyPersistence(this.guestsFieldTarget)
    }
    this._updateGuestsLabel(list.join(', '))
  }

  #isValidEmail (email) {
    return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)
  }

  #notifyPersistence (field) {
    field.dispatchEvent(new Event('change', { bubbles: true }))
    const form = field.closest('form')
    if (form) form.dispatchEvent(new Event('change'))
  }

  _selectedReminderMinutes = 15

  openReminder () {
    this._selectedReminderMinutes = this.hasReminderFieldTarget
      ? parseInt(this.reminderFieldTarget.value) || 15
      : 15
    this.#highlightReminderOptions()
    this.reminderBackdropTarget.classList.remove('hidden')
    this.reminderBackdropTarget.style.display = 'block'
    this.reminderModalTarget.classList.remove('hidden')
    this.reminderModalTarget.style.display = 'flex'
  }

  closeReminder () {
    this.reminderModalTarget.classList.add('hidden')
    this.reminderModalTarget.style.display = 'none'
    this.reminderBackdropTarget.classList.add('hidden')
    this.reminderBackdropTarget.style.display = 'none'
  }

  selectReminder (event) {
    const minutes = parseInt(event.currentTarget.dataset.reminderMinutesValue)
    if (isNaN(minutes)) return
    if (minutes === -1) {
      this.closeReminder()
      this.openCustomReminder()
      return
    }
    this._selectedReminderMinutes = minutes
    this.#highlightReminderOptions()
  }

  openCustomReminder () {
    if (!this.hasCustomReminderModalTarget) return
    this.customReminderBackdropTarget.classList.remove('hidden')
    this.customReminderModalTarget.classList.remove('hidden')
    this.customReminderModalTarget.style.display = 'flex'
  }

  closeCustomReminder () {
    if (!this.hasCustomReminderModalTarget) return
    this.customReminderModalTarget.classList.add('hidden')
    this.customReminderModalTarget.style.display = 'none'
    this.customReminderBackdropTarget.classList.add('hidden')
  }

  confirmCustomReminder () {
    if (!this.hasCustomReminderNumTarget) return
    const scrolledNum = this.#scrolledValue(this.customReminderNumTarget) || 5
    const scrolledUnit = this.#scrolledUnit(this.customReminderUnitTarget) || 'minutes'
    let totalMinutes = scrolledNum
    if (scrolledUnit === 'hours') totalMinutes = scrolledNum * 60
    if (scrolledUnit === 'days') totalMinutes = scrolledNum * 1440
    this._selectedReminderMinutes = totalMinutes
    if (this.hasReminderFieldTarget) {
      this.reminderFieldTarget.value = totalMinutes
      this.#notifyPersistence(this.reminderFieldTarget)
    }
    this.#updateReminderLabel(totalMinutes)
    this.closeCustomReminder()
  }

  #scrolledValue (container) {
    const items = container.querySelectorAll('[data-value]')
    const rect = container.getBoundingClientRect()
    const center = rect.top + rect.height / 2
    let closest = null; let minDist = Infinity
    items.forEach(el => {
      const er = el.getBoundingClientRect()
      const dist = Math.abs(er.top + er.height / 2 - center)
      if (dist < minDist) { minDist = dist; closest = el }
    })
    return closest ? parseInt(closest.dataset.value) : null
  }

  #scrolledUnit (container) {
    const items = container.querySelectorAll('[data-value]')
    const rect = container.getBoundingClientRect()
    const center = rect.top + rect.height / 2
    let closest = null; let minDist = Infinity
    items.forEach(el => {
      const er = el.getBoundingClientRect()
      const dist = Math.abs(er.top + er.height / 2 - center)
      if (dist < minDist) { minDist = dist; closest = el }
    })
    return closest ? closest.dataset.value : null
  }

  confirmReminder () {
    if (this.hasReminderFieldTarget) {
      this.reminderFieldTarget.value = this._selectedReminderMinutes
      this.#notifyPersistence(this.reminderFieldTarget)
    }
    this.#updateReminderLabel(this._selectedReminderMinutes)
    this.closeReminder()
  }

  #highlightReminderOptions () {
    this.reminderOptionTargets.forEach(opt => {
      const val = parseInt(opt.dataset.reminderMinutesValue)
      const active = val === this._selectedReminderMinutes
      opt.style.background = active ? '#EDE1D5' : 'rgba(237,225,213,0.5)'
    })
  }

  #updateReminderLabel (minutes) {
    if (!this.hasReminderLabelTarget) return
    const labels = { 0: 'No reminder', 10080: '1 week before', 1440: '1 day before', 360: '6 hours before', 60: '1 hour before', '-1': 'Custom timer' }
    const label = labels[minutes] || `${minutes} minutes before`
    this.reminderLabelTarget.textContent = label
    if (minutes === 0) {
      this.reminderLabelTarget.classList.add('text-brand-graytext')
      this.reminderLabelTarget.classList.remove('text-brand-primary')
      if (this.hasReminderIconBgTarget) {
        this.reminderIconBgTarget.classList.add('bg-brand-field/50')
        this.reminderIconBgTarget.classList.remove('bg-brand-field')
        const svg = this.reminderIconBgTarget.querySelector('svg')
        if (svg) svg.setAttribute('opacity', '0.5')
      }
    } else {
      this.reminderLabelTarget.classList.remove('text-brand-graytext')
      this.reminderLabelTarget.classList.add('text-brand-primary')
      if (this.hasReminderIconBgTarget) {
        this.reminderIconBgTarget.classList.remove('bg-brand-field/50')
        this.reminderIconBgTarget.classList.add('bg-brand-field')
        const svg = this.reminderIconBgTarget.querySelector('svg')
        if (svg) svg.removeAttribute('opacity')
      }
    }
  }

  _selectedRepeat = 'monthly'
  _selectedRepeatSub = 'day15'

  openRepeat () {
    this.repeatBackdropTarget.classList.remove('hidden')
    this.repeatBackdropTarget.style.display = 'block'
    this.repeatModalTarget.classList.remove('hidden')
    this.repeatModalTarget.style.display = 'flex'
    this.#highlightRepeatOptions()
  }

  closeRepeat () {
    this.repeatModalTarget.classList.add('hidden')
    this.repeatModalTarget.style.display = 'none'
    this.repeatBackdropTarget.classList.add('hidden')
    this.repeatBackdropTarget.style.display = 'none'
  }

  selectRepeat (event) {
    const val = event.currentTarget.dataset.repeatValue
    if (!val) return
    if (val === 'custom') {
      this.closeRepeat()
      this.openCustomRepeat()
      return
    }
    this._selectedRepeat = val
    this.#highlightRepeatOptions()
  }

  toggleRepeatSub (event) {
    const val = event.currentTarget.dataset.subValue
    const container = event.currentTarget

    if (val === 'until') {
      this.closeRepeat()
      this.openRepeatUntil()
      return
    }

    const isActive = container.style.background === 'rgb(147, 58, 53)' || container.style.background === '#933A35'
    const dot = container.querySelector('div')

    if (isActive) {
      container.style.background = '#D9D9D9'
      dot.style.left = '2px'
      dot.style.right = 'auto'
    } else {
      container.style.background = '#933A35'
      dot.style.right = '2px'
      dot.style.left = 'auto'
    }
  }

  confirmRepeat () {
    const labels = { daily: 'Daily', weekly: 'Weekly', monthly: 'Monthly', yearly: 'Every Year', custom: 'Custom' }
    const label = labels[this._selectedRepeat] || 'Repeat'
    if (this.hasRepeatLabelTarget) {
      this.repeatLabelTarget.textContent = label
      this.repeatLabelTarget.classList.remove('text-brand-graytext')
      this.repeatLabelTarget.classList.add('text-brand-primary')
    }
    if (this.hasRepeatIconBgTarget) {
      this.repeatIconBgTarget.classList.remove('bg-brand-field/50')
      this.repeatIconBgTarget.classList.add('bg-brand-field')
      const svg = this.repeatIconBgTarget.querySelector('svg')
      if (svg) svg.removeAttribute('stroke-opacity')
    }
    if (this.hasRepeatFieldTarget) {
      this.repeatFieldTarget.value = this._selectedRepeat
      this.#notifyPersistence(this.repeatFieldTarget)
    }
    this.closeRepeat()
  }

  openCustomRepeat () {
    this.customRepeatBackdropTarget.classList.remove('hidden')
    this.customRepeatBackdropTarget.style.display = 'block'
    this.customRepeatModalTarget.classList.remove('hidden')
    this.customRepeatModalTarget.style.display = 'flex'
  }

  closeCustomRepeat () {
    this.customRepeatModalTarget.classList.add('hidden')
    this.customRepeatModalTarget.style.display = 'none'
    this.customRepeatBackdropTarget.classList.add('hidden')
    this.customRepeatBackdropTarget.style.display = 'none'
  }

  confirmCustomRepeat () {
    this._selectedRepeat = 'custom'
    const label = 'Custom'
    if (this.hasRepeatLabelTarget) {
      this.repeatLabelTarget.textContent = label
      this.repeatLabelTarget.classList.remove('text-brand-graytext')
      this.repeatLabelTarget.classList.add('text-brand-primary')
    }
    if (this.hasRepeatIconBgTarget) {
      this.repeatIconBgTarget.classList.remove('bg-brand-field/50')
      this.repeatIconBgTarget.classList.add('bg-brand-field')
      const svg = this.repeatIconBgTarget.querySelector('svg')
      if (svg) svg.removeAttribute('stroke-opacity')
    }
    if (this.hasRepeatFieldTarget) {
      this.repeatFieldTarget.value = 'custom'
      this.#notifyPersistence(this.repeatFieldTarget)
    }
    this.closeCustomRepeat()
  }

  openRepeatUntil () {
    this.repeatUntilBackdropTarget.classList.remove('hidden')
    this.repeatUntilBackdropTarget.style.display = 'block'
    this.repeatUntilModalTarget.classList.remove('hidden')
    this.repeatUntilModalTarget.style.display = 'flex'
  }

  closeRepeatUntil () {
    this.repeatUntilModalTarget.classList.add('hidden')
    this.repeatUntilModalTarget.style.display = 'none'
    this.repeatUntilBackdropTarget.classList.add('hidden')
    this.repeatUntilBackdropTarget.style.display = 'none'
  }

  confirmRepeatUntil () {
    const modal = this.hasRepeatUntilModalTarget ? this.repeatUntilModalTarget : null
    if (modal) {
      const dayCol = modal.querySelector('[style*="width:44px"]')
      const monCol = modal.querySelector('[style*="width:52px"]')
      const yrCol = modal.querySelector('[style*="width:60px"]')
      const picked = (col) => {
        if (!col) return null
        const items = col.querySelectorAll('div[style*="height:44px"]')
        const rect = col.getBoundingClientRect()
        const center = rect.top + rect.height / 2
        let best = null; let min = Infinity
        items.forEach(el => {
          const er = el.getBoundingClientRect()
          const d = Math.abs(er.top + er.height / 2 - center)
          if (d < min) { min = d; best = el }
        })
        return best ? best.textContent.trim() : null
      }
      const d = picked(dayCol); const m = picked(monCol); const y = picked(yrCol)
      if (d && m && y) {
        const monthMap = { Jan: 0, Feb: 1, Mar: 2, Apr: 3, May: 4, Jun: 5, Jul: 6, Aug: 7, Sep: 8, Oct: 9, Nov: 10, Dec: 11 }
        const pickedDate = new Date(parseInt(y), monthMap[m] ?? 0, parseInt(d))
        const today = new Date(); today.setHours(0, 0, 0, 0)
        if (pickedDate < today) {
          this.closeRepeatUntil()
          this.openAttention({
            body: 'The "Repeat until" date must be in the future.',
            cancelLabel: 'Go back',
            confirmLabel: 'OK',
            onConfirm: () => { if (this.hasRepeatUntilModalTarget) { this.repeatUntilModalTarget.classList.remove('hidden'); this.repeatUntilModalTarget.style.display = 'flex'; this.repeatUntilBackdropTarget.classList.remove('hidden'); this.repeatUntilBackdropTarget.style.display = 'block' } }
          })
          return
        }
        const label = `Repeat until ${m} ${d}, ${y}`
        if (this.hasRepeatLabelTarget) {
          this.repeatLabelTarget.textContent = label
          this.repeatLabelTarget.classList.remove('text-brand-graytext')
          this.repeatLabelTarget.classList.add('text-brand-primary')
        }
        if (this.hasRepeatIconBgTarget) {
          this.repeatIconBgTarget.classList.remove('bg-brand-field/50')
          this.repeatIconBgTarget.classList.add('bg-brand-field')
          const svg = this.repeatIconBgTarget.querySelector('svg')
          if (svg) svg.removeAttribute('stroke-opacity')
        }
        if (this.hasRepeatFieldTarget) {
          this.repeatFieldTarget.value = `until:${y}-${m}-${d}`
          this.#notifyPersistence(this.repeatFieldTarget)
        }
      }
    }
    this.closeRepeatUntil()
  }

  #highlightRepeatOptions () {
    this.repeatOptionTargets.forEach(opt => {
      const active = opt.dataset.repeatValue === this._selectedRepeat
      opt.style.background = active ? '#EDE1D5' : 'rgba(237,225,213,0.5)'
    })
  }

  _expandLocation () {
    if (!this.hasLocationCardTarget) return
    this.locationCardTarget.style.height = '508px'
    if (this.hasLocationSubmitBgTarget) {
      this.locationSubmitBgTarget.style.top = '429px'
      this.locationSubmitBgTarget.style.opacity = '1'
    }
    if (this.hasLocationSubmitBtnTarget) {
      this.locationSubmitBtnTarget.style.top = '443px'
    }
  }

  _collapseLocation () {
    if (!this.hasLocationCardTarget) return
    this.locationCardTarget.style.height = '301px'
    if (this.hasLocationSubmitBgTarget) {
      this.locationSubmitBgTarget.style.top = '203px'
    }
    if (this.hasLocationSubmitBtnTarget) {
      this.locationSubmitBtnTarget.style.top = '203px'
    }
  }

  _updateSubmitOpacity () {
    if (!this.hasLocationSubmitBgTarget || !this.hasLocationInputTarget) return
    const hasValue = this.locationInputTarget.value.trim().length > 0
    this.locationSubmitBgTarget.style.opacity = hasValue ? '1' : '0.5'
  }

  _clearResults () {
    if (!this.hasLocationResultsTarget) return
    this.locationResultsTarget.innerHTML = ''
    this.locationResultsTarget.style.display = 'none'
  }

  _showResults (results) {
    if (!this.hasLocationResultsTarget) return
    this.locationResultsTarget.innerHTML = ''

    if (results.length === 0) {
      this.locationResultsTarget.innerHTML = '<div style="padding:12px 40px;font-family:Montserrat;font-size:13px;font-weight:500;letter-spacing:0.07em;color:rgba(147,58,53,0.4);">No locations found</div>'
      this.locationResultsTarget.style.display = 'flex'
      this._expandLocation()
      return
    }

    const pinSVG = '<svg width="21" height="24" viewBox="0 0 21 24" fill="none" style="flex-shrink:0;"><path d="M10.6 19.6L5.6 14.4C4.6 13.4 3.9 12.1 3.7 10.6C3.4 9.2 3.5 7.7 4.1 6.4C4.6 5 5.5 3.9 6.7 3.1C7.8 2.3 9.2 1.8 10.6 1.8C12 1.8 13.4 2.3 14.5 3.1C15.7 3.9 16.6 5 17.1 6.4C17.6 7.7 17.8 9.2 17.5 10.6C17.2 12.1 16.5 13.4 15.5 14.4L10.6 19.6Z" stroke="#933A35" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"/><circle cx="10.6" cy="10" r="1.5" stroke="#933A35" stroke-width="1.7"/></svg>'

    results.forEach((place) => {
      const short = this.#cleanLocationName(place.display_name)
      const parts = place.display_name.split(',')
      const address = parts.slice(1).join(',').trim()

      const row = document.createElement('button')
      row.type = 'button'
      row.dataset.action = 'click->season-modal#selectLocation'
      row.dataset.locationName = short
      row.dataset.locationFull = place.display_name
      row.dataset.locationLat = place.lat
      row.dataset.locationLon = place.lon
      row.style.cssText = 'width:283px;height:43px;display:flex;align-items:center;gap:0;padding:0 40px;background:transparent;border:none;border-bottom:1px solid rgba(237,225,213,0.5);cursor:pointer;text-align:left;box-sizing:border-box;'

      row.innerHTML = pinSVG +
        '<div style="display:flex;flex-direction:column;margin-left:2px;overflow:hidden;">' +
        '<span style="font-family:Montserrat;font-weight:500;font-size:13px;line-height:16px;letter-spacing:0.07em;color:#933A35;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">' + short + '</span>' +
        '<span style="font-family:Montserrat;font-weight:500;font-size:13px;line-height:16px;letter-spacing:0.07em;color:rgba(147,58,53,0.5);white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">' + address + '</span>' +
        '</div>'

      this.locationResultsTarget.appendChild(row)
    })

    this.locationResultsTarget.style.display = 'flex'
    this._expandLocation()
  }

  #cleanLocationName (displayName) {
    const parts = displayName.split(',').map(s => s.trim())
    const first = parts[0]
    const country = this.#extractCountry(displayName)
    return first === country ? first : `${first}, ${country}`
  }

  #extractCountry (displayName) {
    const parts = displayName.split(',').map(s => s.trim()).reverse()
    return parts.find(p => p.length > 0 && !/^\d+$/.test(p)) || ''
  }

  _debouncedFetch (query) {
    clearTimeout(this._searchTimeout)
    this._searchTimeout = setTimeout(() => {
      this._fetchLocations(query)
    }, 300)
  }

  async _fetchLocations (query) {
    try {
      let url = `https://nominatim.openstreetmap.org/search?q=${encodeURIComponent(query)}&format=json&limit=5&addressdetails=0`
      let biased = false

      if ('geolocation' in navigator) {
        try {
          const pos = await new Promise((resolve, reject) => {
            navigator.geolocation.getCurrentPosition(resolve, reject, { timeout: 3000, maximumAge: 300000 })
          })
          url += `&viewbox=${pos.coords.longitude - 0.5},${pos.coords.latitude - 0.3},${pos.coords.longitude + 0.5},${pos.coords.latitude + 0.3}&bounded=1`
          biased = true
        } catch (_) { /* geolocation unavailable */ }
      }

      if (!biased && this.lastLatValue && this.lastLonValue) {
        url += `&viewbox=${this.lastLonValue - 1},${this.lastLatValue - 0.6},${this.lastLonValue + 1},${this.lastLatValue + 0.6}`
      }

      const resp = await fetch(url, { headers: { 'Accept-Language': navigator.language || 'en' } })
      const data = await resp.json()
      this._showResults(data)
    } catch (_) {
      this._clearResults()
    }
  }

  // ── Attention dialogs ────────────────────────────────────────────────────

  openAttention ({ body, confirmLabel = 'OK', cancelLabel = 'Keep editing', onConfirm = null } = {}) {
    if (!this.hasAttentionModalTarget) return
    if (body) this.attentionBodyTarget.textContent = body
    if (confirmLabel) this.attentionConfirmTarget.textContent = confirmLabel
    if (this.hasAttentionCancelTarget) this.attentionCancelTarget.textContent = cancelLabel
    this._attentionOnConfirm = onConfirm
    this.attentionBackdropTarget.classList.remove('hidden')
    this.attentionModalTarget.classList.remove('hidden')
    this.attentionModalTarget.style.display = 'flex'
    this.attentionConfirmTarget.onclick = () => {
      this.closeAttention()
      if (typeof this._attentionOnConfirm === 'function') this._attentionOnConfirm()
    }
  }

  closeAttention () {
    if (!this.hasAttentionModalTarget) return
    this.attentionModalTarget.classList.add('hidden')
    this.attentionModalTarget.style.display = 'none'
    this.attentionBackdropTarget.classList.add('hidden')
  }

  showUnsavedChangesAlert (event) {
    const form = this.element.querySelector('form')
    if (!form) return
    const data = new FormData(form)
    const title = (data.get('calendar_event[title]') || '').trim()
    if (!title) return
    event.preventDefault()
    this.openAttention({
      body: "The appointment hasn't been saved yet. Are you sure you want to leave?",
      cancelLabel: 'Keep editing',
      confirmLabel: 'Delete',
      onConfirm: () => { window.history.back() }
    })
  }

  showPastDateAlert () {
    this.openAttention({
      body: 'This appointment is in the past. No reminder notification can be set for past dates.',
      cancelLabel: 'Set date',
      confirmLabel: 'Choose another date',
      onConfirm: () => { if (this.hasReminderModalTarget) this.openReminder() }
    })
  }

  showSensitivePeriodAlert (message) {
    this.openAttention({
      body: message || 'During your period, your body is often more sensitive. Procedures such as tattoos, piercings, or laser treatments may be more painful. Consider rescheduling if possible.',
      cancelLabel: 'Set date',
      confirmLabel: 'Choose another date'
    })
  }

  // ── Recurring event edit modal ───────────────────────────────────────────

  openRecurring () {
    if (!this.hasRecurringModalTarget) return
    this.recurringBackdropTarget.classList.remove('hidden')
    this.recurringModalTarget.classList.remove('hidden')
    this.recurringModalTarget.style.display = 'flex'
  }

  closeRecurring () {
    if (!this.hasRecurringModalTarget) return
    this.recurringModalTarget.classList.add('hidden')
    this.recurringModalTarget.style.display = 'none'
    this.recurringBackdropTarget.classList.add('hidden')
  }

  // ── Notify guests modal ──────────────────────────────────────────────────

  openNotifyGuests () {
    if (!this.hasNotifyModalTarget) return
    this.notifyBackdropTarget.classList.remove('hidden')
    this.notifyModalTarget.classList.remove('hidden')
    this.notifyModalTarget.style.display = 'flex'
  }

  closeNotify () {
    if (!this.hasNotifyModalTarget) return
    this.notifyModalTarget.classList.add('hidden')
    this.notifyModalTarget.style.display = 'none'
    this.notifyBackdropTarget.classList.add('hidden')
  }
}
