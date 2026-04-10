import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    window.openFeedbackModal = (type) => this.openWithType(type)
  }

  open(event) {
    this.openWithType(event.currentTarget?.dataset?.type || "feedback")
  }

  delayedOpen(event) {
    setTimeout(() => {
      this.openWithType(event.currentTarget?.dataset?.type || "feedback")
    }, 350)
  }

  openWithType(type) {
    this.setupType(type)
    this.element.style.display = "flex"
  }

  setupType(type) {
    document.getElementById("feedback_type").value = type
    document.querySelectorAll(".type-option").forEach(opt => {
      opt.classList.remove("bg-[#933a35]", "text-white")
      opt.classList.add("bg-[#f5ede8]", "text-[#933a35]")
    })
    const selected = document.querySelector(`.type-option[data-type="${type}"]`)
    if (selected) {
      selected.classList.remove("bg-[#f5ede8]", "text-[#933a35]")
      selected.classList.add("bg-[#933a35]", "text-white")
    }
  }

  selectType(event) {
    const type = event.currentTarget.dataset.type
    document.getElementById("feedback_type").value = type
    document.querySelectorAll(".type-option").forEach(opt => {
      opt.classList.remove("bg-[#933a35]", "text-white")
      opt.classList.add("bg-[#f5ede8]", "text-[#933a35]")
    })
    event.currentTarget.classList.remove("bg-[#f5ede8]", "text-[#933a35]")
    event.currentTarget.classList.add("bg-[#933a35]", "text-white")
  }

  close() {
    this.element.style.display = "none"
  }

  clickOutside(event) {
    if (event.target === this.element) {
      this.close()
    }
  }
}