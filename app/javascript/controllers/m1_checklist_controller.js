import { Controller } from '@hotwired/stimulus'

// Admin M1 test checklist — persists each checkbox to the database keyed to
// the logged-in admin (POST /admin/m1_checklist/toggle) so every tester's
// checks are shared and attributable ("who tested what, when"). The header
// progress bar reflects the current admin's own checks.
export default class extends Controller {
  static targets = ['checkbox', 'progressFill', 'progressLabel']

  connect () {
    this.update()
  }

  toggle (event) {
    const cb = event.target
    const body = new URLSearchParams()
    body.set('item_key', cb.dataset.item)
    body.set('checked', cb.checked ? '1' : '0')
    this.#post('/admin/m1_checklist/toggle', body)
      .then(json => {
        if (json.ok) this.#setProgress(json.done, json.total)
        else cb.checked = !cb.checked
      })
      .catch(() => { cb.checked = !cb.checked })
  }

  reset () {
    this.checkboxTargets.forEach(cb => { cb.checked = false })
    this.update()
    this.#post('/admin/m1_checklist/reset', new URLSearchParams())
      .then(() => this.update())
      .catch(() => {})
  }

  update () {
    const total = this.checkboxTargets.length
    const done = this.checkboxTargets.filter(cb => cb.checked).length
    const pct = total === 0 ? 0 : Math.round((done / total) * 100)
    if (this.hasProgressFillTarget) this.progressFillTarget.style.width = `${pct}%`
    if (this.hasProgressLabelTarget) {
      this.progressLabelTarget.textContent = `${done} / ${total} (${pct}% — you)`
    }
  }

  #post (url, body) {
    const token = document.querySelector('meta[name="csrf-token"]')?.content
    return fetch(url, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'X-CSRF-Token': token || ''
      },
      body
    }).then(r => r.json())
  }

  #setProgress (done, total) {
    const pct = total === 0 ? 0 : Math.round((done / total) * 100)
    if (this.hasProgressFillTarget) this.progressFillTarget.style.width = `${pct}%`
    if (this.hasProgressLabelTarget) {
      this.progressLabelTarget.textContent = `${done} / ${total} (${pct}% — you)`
    }
  }
}
