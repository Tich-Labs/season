import { Controller } from '@hotwired/stimulus'

const LEVELS = ['', 'Low', 'Medium', 'High']

export default class extends Controller {
  static targets = ['modal', 'count', 'mood', 'physical', 'mental', 'other']

  open () {
    this.#populate()
    this.modalTarget.classList.remove('hidden')
  }

  close () {
    this.modalTarget.classList.add('hidden')
  }

  overlayClick (e) {
    if (e.target === this.modalTarget) this.close()
  }

  // ── private ──────────────────────────────────────────────────────────

  #populate () {
    const root = document.querySelector('[data-controller~="symptom"]')
    if (!root) return

    // Moods
    const moods = JSON.parse(root.dataset.activeMoods || '[]')
    if (this.hasMoodTarget) {
      this.moodTarget.innerHTML = moods.length > 0
        ? `<p class="text-brand-primary font-medium text-base tracking-003 font-sans mb-1">Mood (${moods.length})</p>
           <p class="text-brand-muted font-medium text-sm tracking-003 font-sans mb-3">${moods.map(m => m.charAt(0).toUpperCase() + m.slice(1)).join(', ')}</p>`
        : ''
    }

    // Physical symptoms
    const physical = this.#gatherSliders('physical')
    if (this.hasPhysicalTarget) {
      this.physicalTarget.innerHTML = physical.length > 0
        ? `<p class="text-brand-primary font-medium text-base tracking-003 font-sans mb-1">Physical (${physical.length})</p>
           ${physical.map(p => `<p class="text-brand-muted font-medium text-sm tracking-003 font-sans ml-2 mb-0.5">${p.label} → ${p.level}</p>`).join('')}
           <div class="mb-3"></div>`
        : ''
    }

    // Mental symptoms
    const mental = this.#gatherSliders('mental')
    if (this.hasMentalTarget) {
      this.mentalTarget.innerHTML = mental.length > 0
        ? `<p class="text-brand-primary font-medium text-base tracking-003 font-sans mb-1">Mental (${mental.length})</p>
           ${mental.map(p => `<p class="text-brand-muted font-medium text-sm tracking-003 font-sans ml-2 mb-0.5">${p.label} → ${p.level}</p>`).join('')}
           <div class="mb-3"></div>`
        : ''
    }

    // Other sections
    const other = []
    const bleedingBtn = root.querySelector('[data-flow][aria-pressed="true"]')
    if (bleedingBtn) other.push('Bleeding: ' + bleedingBtn.dataset.flow)
    const dischargeBtn = root.querySelector('[data-discharge][aria-pressed="true"]')
    if (dischargeBtn) {
      const key = dischargeBtn.dataset.discharge
      other.push('Discharge: ' + key.charAt(0).toUpperCase() + key.slice(1).replace(/-/g, ' '))
    }

    const intercourse = JSON.parse(root.dataset.activeIntercourse || '[]')
    if (intercourse.length > 0) {
      const labels = { keiner: 'None', ungeschuetzt: 'Unprotected', geschuetzt: 'Protected', orgasmus: 'Orgasm', 'kein-orgasmus': 'No orgasm', masturbation: 'Masturbation' }
      other.push('Intercourse: ' + intercourse.map(t => labels[t] || t).join(', '))
    }

    const cravings = JSON.parse(root.dataset.activeCravings || '[]')
    if (cravings.length > 0) {
      const labels = { 'fatty-fried': 'Fatty & fried', 'salty-food': 'Salty food', 'bread-noodles': 'Bread & noodles', chocolate: 'Chocolate', sugar: 'Sugar drinks & food' }
      other.push('Cravings: ' + cravings.map(c => labels[c] || c).join(', '))
    }

    const pickers = [
      ['sleep', 'Sleep'],
      ['temperature', 'Temperature'],
      ['weight', 'Weight']
    ]
    for (const [field, label] of pickers) {
      const picker = root.querySelector(`[data-scroll-picker-field-value="${field}"]`)
      if (!picker) continue
      const input = picker.querySelector('[data-scroll-picker-target="input"]')
      if (input && input.value !== '') {
        other.push(`${label}: ${input.value}${picker.dataset.scrollPickerUnitValue || ''}`)
      }
    }

    if (this.hasOtherTarget) {
      this.otherTarget.innerHTML = other.length > 0
        ? `<p class="text-brand-primary font-medium text-base tracking-003 font-sans mb-2">Other</p>
           ${other.map(o => `<p class="text-brand-muted font-medium text-sm tracking-003 font-sans ml-2 mb-0.5">${o}</p>`).join('')}`
        : ''
    }

    // Total count
    const total = moods.length + physical.length + mental.length + other.length
    if (this.hasCountTarget) {
      this.countTarget.textContent = total > 0 ? `${total} symptoms selected` : ''
    }
  }

  #gatherSliders (section) {
    const items = []
    const sectionEl = document.getElementById('section-' + section)
    if (!sectionEl) return items
    sectionEl.querySelectorAll('.symptom-slider').forEach(slider => {
      const v = parseInt(slider.value)
      if (v > 0) {
        // The slider rows are rendered with class "sp-row" (see
        // symptoms/_symptom_slider_row.html.erb), not "symptom-row" -- that
        // mismatch meant this always found nothing, silently dropping the
        // label and leaving only "→ Medium" etc. in the review modal.
        const row = slider.closest('.sp-row')
        const labelEl = row?.querySelector('span:first-child')
        items.push({ label: labelEl?.textContent || '', level: LEVELS[v] })
      }
    })
    return items
  }
}
