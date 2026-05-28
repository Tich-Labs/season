import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  connect () {
    window.openFeedbackModal = () => this.open()
    this._openHandler = () => this.open()
    document.addEventListener('feedback-modal:open', this._openHandler)
  }

  disconnect () {
    document.removeEventListener('feedback-modal:open', this._openHandler)
  }

  open () {
    this.element.style.display = 'flex'
  }

  fileSelected (event) {
    const fileName = event.currentTarget.files[0]?.name || ''
    const label = document.getElementById('attachment-name')
    if (label) label.textContent = fileName
  }

  close () {
    this.element.style.display = 'none'
    this.clearMedia()
  }

  clearMedia () {
    const fileInput = document.getElementById('feedback_attachment')
    if (fileInput) fileInput.value = ''

    const label = document.getElementById('attachment-name')
    if (label) label.textContent = 'No file selected'
  }

  clickOutside (event) {
    if (event.target === this.element) this.close()
  }
}
