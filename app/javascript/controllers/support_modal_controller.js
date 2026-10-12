import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static values = {
    bugHeading: String,
    bugDescription: String,
    bugPlaceholder: String,
    supportHeading: String,
    supportDescription: String,
    supportPlaceholder: String,
    noFile: String
  }

  connect () {
    window.openSupportModal = (type) => this.openWithType(type)
    this._openHandler = (e) => this.openWithType(e.detail?.type || 'support')
    document.addEventListener('support-modal:open', this._openHandler)
    this.applyType('support')
  }

  disconnect () {
    document.removeEventListener('support-modal:open', this._openHandler)
  }

  get typeMeta () {
    return {
      bug_report: {
        heading: this.bugHeadingValue,
        description: this.bugDescriptionValue,
        placeholder: this.bugPlaceholderValue
      },
      support: {
        heading: this.supportHeadingValue,
        description: this.supportDescriptionValue,
        placeholder: this.supportPlaceholderValue
      }
    }
  }

  openWithType (event) {
    const type = typeof event === 'string'
      ? event
      : event?.currentTarget?.dataset?.type || event?.currentTarget?.dataset?.supportModalTypeParam

    this.applyType(type || 'support')
    this.element.style.display = 'flex'
  }

  selectType (event) {
    this.applyType(event.currentTarget.dataset.type)
  }

  fileSelected (event) {
    const fileName = event.currentTarget.files[0]?.name || ''
    const label = document.getElementById('sm-attachment-name')
    if (label) label.textContent = fileName
  }

  close () {
    this.element.style.display = 'none'
    this.clearMedia()
  }

  clearMedia () {
    const fileInput = document.getElementById('support_attachment')
    if (fileInput) fileInput.value = ''

    const label = document.getElementById('sm-attachment-name')
    if (label) label.textContent = this.noFileValue || 'No file selected'
  }

  clickOutside (event) {
    if (event.target === this.element) this.close()
  }

  applyType (type) {
    const meta = this.typeMeta[type] || this.typeMeta.support

    const typeInput = document.getElementById('support_type')
    if (typeInput) typeInput.value = type

    const heading = document.getElementById('sm-heading')
    if (heading) heading.textContent = meta.heading

    const desc = document.getElementById('sm-description')
    if (desc) desc.textContent = meta.description

    const msg = document.getElementById('sm-message')
    if (msg) {
      msg.placeholder = meta.placeholder
      msg.value = msg.value // eslint-disable-line no-self-assign
    }

    document.querySelectorAll('.sm-type-btn').forEach(btn => {
      const isActive = btn.dataset.type === type
      btn.style.background = isActive ? '#933a35' : '#FFFFFF'
      btn.style.color = isActive ? '#FFFFFF' : '#933a35'
      btn.style.borderColor = isActive ? '#933a35' : '#EDE1D5'
    })
  }
}
