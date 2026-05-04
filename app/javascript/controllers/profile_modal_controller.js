import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Trap focus in modals using keyboard navigation
    this.setupKeyboardTraps()
  }

  openAvatarModal() {
    const modal = document.getElementById('avatar-modal')
    if (!modal) return
    modal.style.display = 'flex'
    this.trapFocusIn(modal)
  }

  closeAvatarModal() {
    const modal = document.getElementById('avatar-modal')
    if (!modal) return
    modal.style.display = 'none'
    modal.removeEventListener('keydown', this.handleAvatarKeydown)
  }

  openPersonalInfoModal() {
    const modal = document.getElementById('personal-info-modal')
    if (!modal) return
    modal.style.display = 'flex'
    this.trapFocusIn(modal)
  }

  closePersonalInfoModal() {
    const modal = document.getElementById('personal-info-modal')
    if (!modal) return
    modal.style.display = 'none'
    modal.removeEventListener('keydown', this.handlePersonalInfoKeydown)
  }

  openEmailModal() {
    const modal = document.getElementById('email-modal')
    if (!modal) return
    modal.style.display = 'flex'
    this.trapFocusIn(modal)
  }

  closeEmailModal() {
    const modal = document.getElementById('email-modal')
    if (!modal) return
    modal.style.display = 'none'
    modal.removeEventListener('keydown', this.handleEmailKeydown)
  }

  clickAvatarUpload() {
    const fileInput = document.getElementById('avatar-file')
    if (fileInput) fileInput.click()
  }

  submitAvatarForm() {
    const form = document.getElementById('avatar-upload-form')
    if (form) form.submit()
  }

  // ── private ────────────────────────────────────────────────────────────

  setupKeyboardTraps() {
    // Setup Escape key handling for all modals
    document.addEventListener('keydown', (e) => {
      if (e.key === 'Escape') {
        const avatarModal = document.getElementById('avatar-modal')
        const personalModal = document.getElementById('personal-info-modal')
        const emailModal = document.getElementById('email-modal')

        if (avatarModal?.style.display === 'flex') this.closeAvatarModal()
        if (personalModal?.style.display === 'flex') this.closePersonalInfoModal()
        if (emailModal?.style.display === 'flex') this.closeEmailModal()
      }
    })
  }

  trapFocusIn(modal) {
    const focusable = Array.from(
      modal.querySelectorAll('button, input, a[href], [tabindex]:not([tabindex="-1"])')
    )
    if (!focusable.length) return

    const first = focusable[0]
    const last = focusable[focusable.length - 1]

    // Trap Tab/Shift+Tab within modal
    const trapHandler = (e) => {
      if (e.key !== 'Tab') return
      if (e.shiftKey) {
        if (document.activeElement === first) {
          e.preventDefault()
          last.focus()
        }
      } else {
        if (document.activeElement === last) {
          e.preventDefault()
          first.focus()
        }
      }
    }

    modal.addEventListener('keydown', trapHandler)
    first.focus()
  }

  clickOutside(event) {
    if (event.target.id === 'avatar-modal') this.closeAvatarModal()
    if (event.target.id === 'personal-info-modal') this.closePersonalInfoModal()
    if (event.target.id === 'email-modal') this.closeEmailModal()
  }
}
