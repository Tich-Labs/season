import { Controller } from "@hotwired/stimulus"

const TYPE_META = {
  feedback: {
    heading:     "Share your feedback",
    description: "We'd love to hear what you think",
    placeholder: "What's on your mind?"
  },
  bug_report: {
    heading:     "Report a bug",
    description: "Something isn't working as it should",
    placeholder: "Describe what happened and what you expected to happen…"
  },
  support: {
    heading:     "Get support",
    description: "We're here to help",
    placeholder: "How can we help? Describe your issue…"
  }
}

export default class extends Controller {
  connect() {
    window.openFeedbackModal = (type) => this.openWithType(type)
    this.applyType("feedback")
  }

  openWithType(event) {
    const type = typeof event === "string"
      ? event
      : event?.currentTarget?.dataset?.type || event?.currentTarget?.dataset?.feedbackModalTypeParam

    this.applyType(type || "feedback")
    this.element.style.display = "flex"
  }

  selectType(event) {
    this.applyType(event.currentTarget.dataset.type)
  }

  fileSelected(event) {
    const fileName = event.currentTarget.files[0]?.name || ""
    const label = document.getElementById("attachment-name")
    if (label) label.textContent = fileName
  }

  close() {
    this.element.style.display = "none"
    feedbackClearMedia()
  }

  // Close when tapping the dark backdrop (not the sheet)
  clickOutside(event) {
    if (event.target === this.element) this.close()
  }

  // ── private ────────────────────────────────────────────────────────────

  applyType(type) {
    const meta = TYPE_META[type] || TYPE_META.feedback

    // Hidden input value
    const typeInput = document.getElementById("feedback_type")
    if (typeInput) typeInput.value = type

    // Heading + description
    const heading = document.getElementById("fm-heading")
    if (heading) heading.textContent = meta.heading

    const desc = document.getElementById("fm-description")
    if (desc) desc.textContent = meta.description

    // Textarea placeholder
    const msg = document.getElementById("fm-message")
    if (msg) {
      msg.placeholder = meta.placeholder
      msg.value = msg.value // preserve user input if type changes
    }

    // Tab button styles
    document.querySelectorAll(".fm-type-btn").forEach(btn => {
      const isActive = btn.dataset.type === type
      btn.style.background     = isActive ? "#933a35" : "#FFFFFF"
      btn.style.color          = isActive ? "#FFFFFF" : "#933a35"
      btn.style.borderColor    = isActive ? "#933a35" : "#EDE1D5"
    })
  }
}
