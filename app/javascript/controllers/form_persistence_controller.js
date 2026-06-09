/* global sessionStorage */
import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static values = {
    key: String
  }

  connect () {
    if (sessionStorage.getItem(`${this.keyValue}_submitted`)) {
      sessionStorage.removeItem(`${this.keyValue}_submitted`)
      sessionStorage.removeItem(this.keyValue)
    } else {
      const restored = this.#restore()
      if (restored) {
        this.element.dispatchEvent(new CustomEvent('form-persistence:restored', { bubbles: true }))
      }
    }

    this._onChange = () => this.#debouncedSave()
    this._onSubmit = () => {
      sessionStorage.setItem(`${this.keyValue}_submitted`, '1')
      sessionStorage.removeItem(this.keyValue)
    }
    this._onUnload = () => this.#save()
    this.element.addEventListener('change', this._onChange)
    this.element.addEventListener('input', this._onChange)
    this.element.addEventListener('submit', this._onSubmit)
    window.addEventListener('beforeunload', this._onUnload)
  }

  disconnect () {
    this.#save()
    this.element.removeEventListener('change', this._onChange)
    this.element.removeEventListener('input', this._onChange)
    this.element.removeEventListener('submit', this._onSubmit)
    window.removeEventListener('beforeunload', this._onUnload)
  }

  #save () {
    const data = {}
    new FormData(this.element).forEach((value, key) => {
      if (value) data[key] = value
    })
    if (Object.keys(data).length > 0) {
      sessionStorage.setItem(this.keyValue, JSON.stringify(data))
    }
  }

  #restore () {
    try {
      const raw = sessionStorage.getItem(this.keyValue)
      if (!raw) return false
      const data = JSON.parse(raw)
      let restored = false
      Object.entries(data).forEach(([name, value]) => {
        const field = this.element.querySelector(`[name="${name}"]`)
        if (field && !field.value) {
          field.value = value
          restored = true
        }
      })
      return restored
    } catch (_) {
      return false
    }
  }

  #debouncedSave () {
    clearTimeout(this._timer)
    this._timer = setTimeout(() => this.#save(), 300)
  }
}
