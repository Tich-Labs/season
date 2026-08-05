/* global localStorage */
import { Controller } from '@hotwired/stimulus'

const STORAGE_COUNTRY = 'season_holiday_country'
const STORAGE_ENABLED = 'season_holiday_enabled'

// Headless — paints holiday dots into this page's [data-holiday-date] cells based
// on the enabled/country preference set in Settings > Calendar (holiday_controller.js).
// Renders no UI of its own; the toggle + country picker live only in Settings.
export default class extends Controller {
  connect () {
    const enabled = (localStorage.getItem(STORAGE_ENABLED) ?? 'true') !== 'false'
    if (!enabled) return

    const country = localStorage.getItem(STORAGE_COUNTRY) || 'ke'
    const params = new URLSearchParams({ country })

    fetch(`/api/holidays?${params.toString()}`)
      .then(r => r.json())
      .then(data => this.#renderDots(data.holidays || []))
      .catch(() => {})
  }

  #renderDots (holidays) {
    this.element.querySelectorAll('[data-holiday-date]').forEach(cell => {
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
}
