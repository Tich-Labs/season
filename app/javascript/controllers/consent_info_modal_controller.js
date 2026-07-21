import { Controller } from '@hotwired/stimulus'

const CONSENT_DETAILS = {
  health_data_processing: {
    title: 'Health Data Processing',
    what: 'All health-related information you log in the app.',
    items: [
      'Cycle dates, symptoms, mood, energy levels',
      'Pain, sleep, temperature, and weight',
      'Personal notes about your health',
      'Cravings, discharge, and intercourse'
    ],
    why: 'This data powers your cycle predictions, symptom trends, and personalized insights. It is stored encrypted and never shared with third parties.',
    rights: 'You can withdraw consent at any time. Historical data will be deleted per our retention policy.'
  },
  symptom_tracking: {
    title: 'Symptom Tracking',
    what: 'Your daily symptom logs across all categories.',
    items: [
      'Physical symptoms (pain, cramps, bloating, etc.)',
      'Mental & emotional state (mood, anxiety, energy)',
      'Cravings and food-related symptoms',
      'Discharge tracking and patterns'
    ],
    why: 'Enables your symptom history, trend analysis, and helps identify patterns across your cycle phases.',
    rights: 'Withdraw consent anytime. Previously logged data will be deleted per our retention schedule.'
  },
  cycle_tracking: {
    title: 'Cycle Tracking',
    what: 'Your menstrual cycle dates and predictions.',
    items: [
      'Period start and end dates',
      'Cycle phase calculations and labels',
      'Ovulation and fertility window predictions',
      'Cycle length and period length history'
    ],
    why: 'Core app functionality — predictions, phase detection, and calendar views depend on this data.',
    rights: 'Required for app functionality. Deletion requires account deletion.'
  },
  menstrual_data: {
    title: 'Menstrual Data',
    what: 'Your period-specific information and flow intensity.',
    items: [
      'Period start and end dates',
      'Flow intensity (light, medium, heavy)',
      'Bleeding patterns over time'
    ],
    why: 'Enables period predictions, cycle statistics, and phase colouring on the calendar.',
    rights: 'You can withdraw consent. Past data will be anonymized.'
  }
}

export default class extends Controller {
  connect () {
    this._openHandler = (e) => this.openWithType(e.detail?.type || e.currentTarget?.dataset?.type)
    document.addEventListener('consent-info:open', this._openHandler)
  }

  disconnect () {
    document.removeEventListener('consent-info:open', this._openHandler)
  }

  openWithType (event) {
    if (typeof event === 'string') {
      this._render(event)
      return
    }
    const type = event.currentTarget?.dataset?.consentType
    if (type) {
      this._render(type)
    }
  }

  _render (type) {
    const details = CONSENT_DETAILS[type]
    if (!details) return

    document.getElementById('ci-title').textContent = details.title
    document.getElementById('ci-what').textContent = details.what

    const list = document.getElementById('ci-items')
    list.innerHTML = details.items.map(i => `<li class="flex items-start gap-2 text-brand-secondary text-sm"><svg class="mt-0.5 shrink-0" width="14" height="14" fill="none" stroke="#933a35" stroke-width="2" viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"/></svg><span>${i}</span></li>`).join('')

    document.getElementById('ci-why').textContent = details.why
    document.getElementById('ci-rights').textContent = details.rights

    this.element.style.display = 'flex'
  }

  close () {
    this.element.style.display = 'none'
  }

  clickOutside (event) {
    if (event.target === this.element) this.close()
  }
}
