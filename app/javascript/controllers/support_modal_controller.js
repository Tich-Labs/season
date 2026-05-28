import { Controller } from '@hotwired/stimulus'

const TYPE_META = {
  bug_report: {
    heading: 'Report a bug',
    description: "Something isn't working as it should",
    placeholder: 'Describe what happened and what you expected to happen...'
  },
  support: {
    heading: 'Get support',
    description: "We're here to help",
    placeholder: 'How can we help? Describe your issue...'
  }
}

export default class extends Controller {
  connect () {
    window.openSupportModal = (type) => this.openWithType(type)
    this._openHandler = (e) => this.openWithType(e.detail?.type || 'support')
    document.addEventListener('support-modal:open', this._openHandler)
    this.applyType('support')
  }

  disconnect () {
    document.removeEventListener('support-modal:open', this._openHandler)
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
    if (label) label.textContent = 'No file selected'
  }

  clickOutside (event) {
    if (event.target === this.element) this.close()
  }

  applyType (type) {
    const meta = TYPE_META[type] || TYPE_META.support

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
