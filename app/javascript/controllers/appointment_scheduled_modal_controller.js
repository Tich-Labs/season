import { Controller } from '@hotwired/stimulus'

// Post-schedule confirmation modal on /calendar (?appointment_scheduled=1
// after CalendarEventsController#create). Same close/overlay-click pattern
// as tracking_saved_modal_controller.js, kept as its own controller since
// the two modals' content and triggers are unrelated.
export default class extends Controller {
  close () {
    this.element.remove()
  }

  overlayClick (event) {
    if (event.target === this.element) this.close()
  }
}
