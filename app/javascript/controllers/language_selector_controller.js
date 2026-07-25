import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['select']
  static values = { currentLanguage: String }

  async handleChange (event) {
    const selectedLanguage = event.target.value

    if (!selectedLanguage) return

    this.selectTarget.disabled = true
    this.selectTarget.classList.add('opacity-50')

    try {
      const response = await fetch('/settings/language', {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          Accept: 'application/json'
        },
        body: JSON.stringify({
          user: { language: selectedLanguage }
        })
      })

      const data = await response.json()

      if (response.ok) {
        this.currentLanguageValue = selectedLanguage
        this.showSuccess(data.message || 'Language updated')
        setTimeout(() => window.location.reload(), 500)
      } else {
        this.selectTarget.value = this.currentLanguageValue
        this.showError(data.error || 'Failed to update language')
      }
    } catch (error) {
      console.error('Language update error:', error)
      this.selectTarget.value = this.currentLanguageValue
      this.showError('Error updating language. Please try again.')
    } finally {
      this.selectTarget.disabled = false
      this.selectTarget.classList.remove('opacity-50')
    }
  }

  showSuccess (message) {
    const el = document.createElement('div')
    el.className = 'fixed top-4 left-4 right-4 bg-green-100 text-green-800 px-4 py-3 rounded-lg z-50 text-sm font-medium text-center shadow-lg'
    el.textContent = message
    el.style.maxWidth = 'calc(100% - 32px)'
    el.style.margin = '0 auto'
    document.body.appendChild(el)
    setTimeout(() => el.remove(), 3000)
  }

  showError (message) {
    const el = document.createElement('div')
    el.className = 'fixed top-4 left-4 right-4 bg-brand-error text-brand-primary px-4 py-3 rounded-lg z-50 text-sm font-medium text-center shadow-lg'
    el.textContent = message
    el.style.maxWidth = 'calc(100% - 32px)'
    el.style.margin = '0 auto'
    document.body.appendChild(el)
    setTimeout(() => el.remove(), 4000)
  }
}
