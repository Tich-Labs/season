import { Controller } from "@hotwired/stimulus"

// Dispatches a document-level event to open the feedback modal.
// Usage: data-controller="open-feedback" data-open-feedback-type-value="feedback"
//        data-action="click->open-feedback#open"
export default class extends Controller {
  static values = { type: { type: String, default: "feedback" } }

  open() {
    document.dispatchEvent(
      new CustomEvent("feedback-modal:open", { detail: { type: this.typeValue } })
    )
  }
}
