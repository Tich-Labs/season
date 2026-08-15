import { Controller } from '@hotwired/stimulus'

// Post-tracking-save prediction modal on /tracking (period save, symptoms
// submit, superpowers submit all land here with ?tracking_saved=1). Was
// previously wired with onclick="..." attributes, which this app's
// nonce-based CSP silently blocks -- script-src carrying a nonce makes
// browsers ignore 'unsafe-inline' entirely, including for inline event
// handler attributes, not just <script> tags. Moot while the modal was
// unreachable (nothing ever set the param it checked), but now that it's
// wired up for real, it needs actual working close buttons.
export default class extends Controller {
  close () {
    this.element.remove()
  }

  overlayClick (event) {
    if (event.target === this.element) this.close()
  }
}
