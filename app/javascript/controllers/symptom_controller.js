import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { url: String }

  #notesTimer = null

  save(event) {
    const field = event.currentTarget.dataset.field
    const value = event.currentTarget.dataset.value
    const date  = this.element.dataset.date

    fetch(this.urlValue, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
        "Accept": "application/json"
      },
      body: JSON.stringify({ symptom_log: { date, [field]: value } })
    }).then(() => {
      // Update visual state for scale buttons in the same dot-group
      const group = event.currentTarget.closest(".dot-group")
      if (!group) return
      group.querySelectorAll(".dot").forEach((dot, i) => {
        const selected = i === parseInt(value) - 1
        dot.setAttribute("aria-pressed", selected.toString())
      })
    })
  }

  saveNotes(event) {
    clearTimeout(this.#notesTimer)
    const value = event.currentTarget.value
    const date  = this.element.dataset.date

    this.#notesTimer = setTimeout(() => {
      fetch(this.urlValue, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
          "Accept": "application/json"
        },
        body: JSON.stringify({ symptom_log: { date, notes: value } })
      })
    }, 600)
  }
}
