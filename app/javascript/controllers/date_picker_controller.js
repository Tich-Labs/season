/* global requestAnimationFrame */
import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['drum', 'content']

  connect () {
    this._closeHandler = (e) => {
      if (!this.element.contains(e.target)) this.close()
    }
    document.addEventListener('click', this._closeHandler)
  }

  disconnect () {
    document.removeEventListener('click', this._closeHandler)
  }

  toggle (e) {
    e.stopPropagation()
    if (this.#expanded) {
      this.close()
    } else {
      this.open()
    }
  }

  open () {
    this.drumTarget.style.height = '215px'
    this.drumTarget.style.borderRadius = '25px'
    this.contentTarget.classList.remove('hidden')
    this.#expanded = true

    // Scroll selected date into view
    requestAnimationFrame(() => {
      const ul = this.contentTarget.querySelector('ul')
      const sel = this.contentTarget.querySelector('[data-selected]')
      if (ul && sel) {
        const li = sel.closest('li')
        const liTop = li.offsetTop
        const liHeight = li.offsetHeight
        const visibleHeight = ul.clientHeight
        ul.scrollTop = liTop - (visibleHeight - liHeight) / 2
      }
    })
  }

  close () {
    this.drumTarget.style.height = '31px'
    this.drumTarget.style.borderRadius = '133px'
    this.contentTarget.classList.add('hidden')
    this.#expanded = false
  }

  #expanded = false
}
