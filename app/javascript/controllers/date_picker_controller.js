import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dropdown"]

  connect() {
    this._closeHandler = (e) => {
      if (!this.element.contains(e.target)) this.close()
    }
    document.addEventListener("click", this._closeHandler)
  }

  disconnect() {
    document.removeEventListener("click", this._closeHandler)
  }

  toggle(e) {
    e.stopPropagation()
    const hidden = this.dropdownTarget.classList.toggle("hidden")
    if (!hidden) {
      requestAnimationFrame(() => {
        const ul  = this.dropdownTarget.querySelector("ul")
        const sel = this.dropdownTarget.querySelector("[data-selected]")
        if (ul && sel) {
          const li = sel.closest("li")
          // Center the selected li in the visible scroll area
          const liTop = li.offsetTop
          const liHeight = li.offsetHeight
          const visibleHeight = ul.clientHeight
          ul.scrollTop = liTop - (visibleHeight - liHeight) / 2
        }
      })
    }
  }

  close() {
    this.dropdownTarget.classList.add("hidden")
  }
}
