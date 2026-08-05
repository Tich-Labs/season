/* global fetch */
import { Controller } from '@hotwired/stimulus'

// Persists a notification preference toggle via a real Stimulus data-action.
// Deliberately not an inline onclick/onchange attribute: this app's CSP
// (config/initializers/content_security_policy.rb) nonces script-src, and
// once a nonce is present browsers ignore 'unsafe-inline' entirely per spec —
// so any inline event handler attribute is silently blocked outright. That
// was the actual root cause of these toggles doing nothing at all (not just
// a missing visual update): the background save never fired either.
export default class extends Controller {
  static values = { key: String, url: String }

  toggle () {
    const isActive = this.element.classList.toggle('active')
    this.element.setAttribute('aria-checked', String(isActive))

    fetch(this.urlValue, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')?.content
      },
      body: JSON.stringify({ [this.keyValue]: isActive })
    })
  }
}
