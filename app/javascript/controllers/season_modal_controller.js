import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['modal', 'backdrop', 'closeBtn', 'categoryInput', 'categoryOption']
  static values = {
    selectedCategory: String
  }

  connect () {
    this._escHandler = (e) => {
      if (e.key === 'Escape' && !this.modalTarget.classList.contains('hidden')) {
        this.close()
      }
    }
    document.addEventListener('keydown', this._escHandler)

    if (this.hasBackdropTarget) {
      this.backdropTarget.addEventListener('click', () => this.close())
    }

    if (this.hasCategoryInputTarget) {
      this.selectedCategoryValue = this.categoryInputTarget.value
    }
  }

  disconnect () {
    document.removeEventListener('keydown', this._escHandler)
  }

  open () {
    this.modalTarget.classList.remove('hidden')
    this.backdropTarget.classList.remove('hidden')
    setTimeout(() => this.closeBtnTarget?.focus(), 0)
  }

  close () {
    this.modalTarget.classList.add('hidden')
    this.backdropTarget.classList.add('hidden')
  }

  selectCategory (event) {
    const button = event.currentTarget
    const category = button.dataset.categoryNameValue

    if (!category || !this.hasCategoryInputTarget) return

    this.selectedCategoryValue = category
    this.categoryInputTarget.value = category

    this.categoryOptionTargets.forEach((option) => {
      const optionCategory = option.dataset.categoryNameValue
      const isSelected = optionCategory === category
      option.style.color = isSelected ? '#933A35' : '#EDE1D5'
      option.style.opacity = '1'
      const icon = option.querySelector('img')
      if (icon) {
        icon.style.opacity = '1'
      }
    })
  }
}
