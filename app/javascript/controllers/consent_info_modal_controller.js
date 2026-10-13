import { Controller } from '@hotwired/stimulus'
import { t, tArray } from 'i18n'

const CONSENT_TYPES = ['health_data_processing', 'symptom_tracking', 'cycle_tracking', 'menstrual_data']

// Content lives in config/locales/*.yml under `js.consent.<type>` so the
// consent explainer modal is translated alongside the rest of the app.
function consentDetails (type) {
  if (!CONSENT_TYPES.includes(type)) return null
  const base = `js.consent.${type}`
  return {
    title: t(`${base}.title`),
    what: t(`${base}.what`),
    items: tArray(`${base}.items`),
    why: t(`${base}.why`),
    rights: t(`${base}.rights`)
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
    const details = consentDetails(type)
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
