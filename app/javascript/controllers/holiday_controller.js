/* global localStorage, CustomEvent */
import { Controller } from '@hotwired/stimulus'

const STORAGE_COUNTRY = 'season_holiday_country'
const STORAGE_ENABLED = 'season_holiday_enabled'

const COUNTRIES = [
  { code: 'ar', name: 'Argentina' },
  { code: 'au', name: 'Australia' },
  { code: 'at', name: 'Austria' },
  { code: 'br', name: 'Brazil' },
  { code: 'ca', name: 'Canada' },
  { code: 'cl', name: 'Chile' },
  { code: 'co', name: 'Colombia' },
  { code: 'cr', name: 'Costa Rica' },
  { code: 'hr', name: 'Croatia' },
  { code: 'cy', name: 'Cyprus' },
  { code: 'cz', name: 'Czechia' },
  { code: 'dk', name: 'Denmark' },
  { code: 'ee', name: 'Estonia' },
  { code: 'fi', name: 'Finland' },
  { code: 'fr', name: 'France' },
  { code: 'ge', name: 'Georgia' },
  { code: 'de', name: 'Germany' },
  { code: 'gr', name: 'Greece' },
  { code: 'gg', name: 'Guernsey' },
  { code: 'hk', name: 'Hong Kong' },
  { code: 'hu', name: 'Hungary' },
  { code: 'is', name: 'Iceland' },
  { code: 'in', name: 'India' },
  { code: 'ie', name: 'Ireland' },
  { code: 'im', name: 'Isle of Man' },
  { code: 'il', name: 'Israel' },
  { code: 'it', name: 'Italy' },
  { code: 'jp', name: 'Japan' },
  { code: 'je', name: 'Jersey' },
  { code: 'kz', name: 'Kazakhstan' },
  { code: 'ke', name: 'Kenya' },
  { code: 'kr', name: 'Korea (South)' },
  { code: 'lv', name: 'Latvia' },
  { code: 'li', name: 'Liechtenstein' },
  { code: 'lt', name: 'Lithuania' },
  { code: 'lu', name: 'Luxembourg' },
  { code: 'my', name: 'Malaysia' },
  { code: 'mx', name: 'Mexico' },
  { code: 'mc', name: 'Monaco' },
  { code: 'ma', name: 'Morocco' },
  { code: 'nl', name: 'Netherlands' },
  { code: 'nz', name: 'New Zealand' },
  { code: 'ng', name: 'Nigeria' },
  { code: 'no', name: 'Norway' },
  { code: 'pe', name: 'Peru' },
  { code: 'ph', name: 'Philippines' },
  { code: 'pl', name: 'Poland' },
  { code: 'pt', name: 'Portugal' },
  { code: 'ro', name: 'Romania' },
  { code: 'ru', name: 'Russia' },
  { code: 'sg', name: 'Singapore' },
  { code: 'sk', name: 'Slovakia' },
  { code: 'si', name: 'Slovenia' },
  { code: 'za', name: 'South Africa' },
  { code: 'es', name: 'Spain' },
  { code: 'se', name: 'Sweden' },
  { code: 'ch', name: 'Switzerland' },
  { code: 'th', name: 'Thailand' },
  { code: 'tn', name: 'Tunisia' },
  { code: 'tr', name: 'Turkey' },
  { code: 'ua', name: 'Ukraine' },
  { code: 'gb', name: 'United Kingdom' },
  { code: 'us', name: 'United States' },
  { code: 've', name: 'Venezuela' },
  { code: 'vn', name: 'Vietnam' }
]

export default class extends Controller {
  static targets = ['toggle', 'countryInput', 'countryResults', 'countrySection']

  connect () {
    this.country = localStorage.getItem(STORAGE_COUNTRY) || 'ke'
    this.enabled = (localStorage.getItem(STORAGE_ENABLED) ?? 'true') !== 'false'

    this.#reflectState()
    if (this.enabled) {
      this.#fetchHolidays()
    } else {
      this.#emit('holidays:cleared', {})
      this.#clearDots()
    }
  }

  toggle () {
    this.enabled = !this.enabled
    localStorage.setItem(STORAGE_ENABLED, this.enabled ? 'true' : 'false')
    this.#reflectEnabled()
    if (this.enabled) {
      this.#fetchHolidays()
    } else {
      this.#emit('holidays:cleared', {})
      this.#clearDots()
    }
  }

  searchCountries () {
    const query = this.countryInputTarget.value.trim().toLowerCase()
    this.#clearResults()
    if (!query) return

    const matches = COUNTRIES
      .filter(c => c.name.toLowerCase().includes(query) || c.code === query)
      .slice(0, 6)

    matches.forEach(c => {
      const btn = document.createElement('button')
      btn.type = 'button'
      btn.textContent = c.name
      btn.className = 'w-full text-left px-4 py-3 text-base text-brand-primary hover:bg-brand-field'
      btn.dataset.countryCode = c.code
      btn.addEventListener('pointerdown', () => this.#selectCountry(c.code, c.name))
      this.countryResultsTarget.appendChild(btn)
    })
    this.countryResultsTarget.classList.toggle('hidden', matches.length === 0)
  }

  closeResults () {
    this.#clearResults()
  }

  #selectCountry (code, name) {
    this.country = code
    localStorage.setItem(STORAGE_COUNTRY, code)
    this.countryInputTarget.value = name
    this.#clearResults()
    if (this.enabled) this.#fetchHolidays()
  }

  #reflectState () {
    this.#reflectEnabled()
    const country = COUNTRIES.find(c => c.code === this.country)
    if (country) this.countryInputTarget.value = country.name
  }

  #reflectEnabled () {
    this.toggleTarget.classList.toggle('active', this.enabled)
    this.toggleTarget.setAttribute('aria-pressed', String(this.enabled))
    this.countrySectionTarget.hidden = !this.enabled
  }

  #clearResults () {
    this.countryResultsTarget.innerHTML = ''
    this.countryResultsTarget.classList.add('hidden')
  }

  #fetchHolidays () {
    const params = new URLSearchParams({ country: this.country })
    fetch(`/api/holidays?${params.toString()}`)
      .then(r => r.json())
      .then(data => {
        const holidays = data.holidays || []
        this.#emit('holidays:loaded', { holidays })
        this.#renderDots(holidays)
      })
      .catch(() => {
        this.#emit('holidays:cleared', {})
        this.#clearDots()
      })
  }

  #renderDots (holidays) {
    document.querySelectorAll('[data-holiday-date]').forEach(cell => {
      const date = cell.dataset.holidayDate
      const matches = holidays.filter(h => h.date === date)
      if (matches.length === 0) return

      const dot = document.createElement('span')
      dot.className = 'inline-block rounded-full'
      dot.style.cssText = 'width:4px; height:4px; background:#A9A29B; flex-shrink:0;'
      dot.title = matches.map(h => h.name).join(', ')
      dot.setAttribute('aria-label', dot.title)
      cell.appendChild(dot)
    })
  }

  #clearDots () {
    document.querySelectorAll('[data-holiday-date]').forEach(cell => {
      cell.innerHTML = ''
    })
  }

  #emit (name, detail) {
    window.dispatchEvent(new CustomEvent(name, { detail }))
  }
}
