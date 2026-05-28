import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static values = { type: { type: String, default: 'feedback' } }

  open () {
    const type = this.typeValue
    const isSupport = type === 'support' || type === 'bug_report'
    const containerId = isSupport ? 'support-modal-container' : 'feedback-modal-container'
    const eventName = isSupport ? 'support-modal:open' : 'feedback-modal:open'

    const container = document.getElementById(containerId)
    if (container) {
      container.style.display = 'flex'
    }

    document.dispatchEvent(
      new CustomEvent(eventName, { detail: { type } })
    )
  }
}
