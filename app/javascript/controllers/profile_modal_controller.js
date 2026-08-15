import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  connect () {
    // Trap focus in modals using keyboard navigation
    this.setupKeyboardTraps()
  }

  openAvatarModal () {
    const modal = document.getElementById('avatar-modal')
    if (!modal) return
    modal.style.display = 'flex'
    this.trapFocusIn(modal)
  }

  closeAvatarModal () {
    const modal = document.getElementById('avatar-modal')
    if (!modal) return
    modal.style.display = 'none'
    modal.removeEventListener('keydown', this.handleAvatarKeydown)
  }

  openPersonalInfoModal () {
    const modal = document.getElementById('personal-info-modal')
    if (!modal) return
    modal.style.display = 'flex'
    this.trapFocusIn(modal)
  }

  closePersonalInfoModal () {
    const modal = document.getElementById('personal-info-modal')
    if (!modal) return
    modal.style.display = 'none'
    modal.removeEventListener('keydown', this.handlePersonalInfoKeydown)
  }

  openEmailModal () {
    const modal = document.getElementById('email-modal')
    if (!modal) return
    modal.style.display = 'flex'
    this.trapFocusIn(modal)
  }

  closeEmailModal () {
    const modal = document.getElementById('email-modal')
    if (!modal) return
    modal.style.display = 'none'
    modal.removeEventListener('keydown', this.handleEmailKeydown)
  }

  openPasswordModal () {
    const modal = document.getElementById('password-modal')
    if (!modal) return
    modal.style.display = 'flex'
    this.trapFocusIn(modal)
  }

  closePasswordModal () {
    const modal = document.getElementById('password-modal')
    if (!modal) return
    modal.style.display = 'none'
    modal.removeEventListener('keydown', this.handlePasswordKeydown)
  }

  clickAvatarUpload () {
    const fileInput = document.getElementById('avatar-file')
    if (fileInput) fileInput.click()
  }

  // Selecting a preset only highlights it — the change is saved when the
  // "Add Photo" button submits the form (single avatar-upload-form).
  selectAvatarPreset (event) {
    this.#setSelectedPreset(event.currentTarget.dataset.avatarPreset)
    const fileInput = document.getElementById('avatar-file')
    if (fileInput) fileInput.value = ''
  }

  fileSelected () {
    this.#setSelectedPreset('')
  }

  // ── private ────────────────────────────────────────────────────────────

  // Keeps the hidden avatar_preset input and the grid highlight in sync.
  // The preset buttons all live inside #avatar-modal.
  #setSelectedPreset (presetId) {
    const hidden = document.getElementById('avatar-selected-preset')
    if (hidden) hidden.value = presetId || ''
    document.querySelectorAll('#avatar-modal [data-avatar-preset]').forEach(btn => {
      const selected = btn.dataset.avatarPreset === presetId
      btn.classList.toggle('border-[3px]', selected)
      btn.classList.toggle('border-brand-primary', selected)
      btn.classList.toggle('border', !selected)
      btn.classList.toggle('border-brand-divider', !selected)
      btn.setAttribute('aria-pressed', selected.toString())
    })
  }

  setupKeyboardTraps () {
    // Setup Escape key handling for all modals
    document.addEventListener('keydown', (e) => {
      if (e.key === 'Escape') {
        const avatarModal = document.getElementById('avatar-modal')
        const personalModal = document.getElementById('personal-info-modal')
        const emailModal = document.getElementById('email-modal')
        const passwordModal = document.getElementById('password-modal')

        if (avatarModal?.style.display === 'flex') this.closeAvatarModal()
        if (personalModal?.style.display === 'flex') this.closePersonalInfoModal()
        if (emailModal?.style.display === 'flex') this.closeEmailModal()
        if (passwordModal?.style.display === 'flex') this.closePasswordModal()
      }
    })
  }

  trapFocusIn (modal) {
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

  clickOutside (event) {
    if (event.target.id === 'avatar-modal') this.closeAvatarModal()
    if (event.target.id === 'personal-info-modal') this.closePersonalInfoModal()
    if (event.target.id === 'email-modal') this.closeEmailModal()
    if (event.target.id === 'password-modal') this.closePasswordModal()
  }
}
