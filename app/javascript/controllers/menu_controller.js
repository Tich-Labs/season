/* global requestAnimationFrame */
import { Controller } from '@hotwired/stimulus'

// FABs live outside this controller's element (rendered as later siblings in
// the layout, or from the page's own content), and one variant --
// shared/_calendar_center_fab.html.erb, z-[60] -- sits above this menu's own
// z-50, so it would otherwise render fully clickable on top of an open menu
// instead of being covered by it. Hiding them by hand sidesteps having to
// keep every FAB's z-index below the menu's forever.
const FAB_SELECTOR = '[data-controller="quick-actions"], a[aria-label="Back to calendar"], a[aria-label="Go to calendar"]'

export default class extends Controller {
  static targets = ['slider', 'panel']

  open () {
    this.sliderTarget.classList.remove('hidden')
    this.sliderTarget.classList.add('flex')
    requestAnimationFrame(() => {
      this.panelTarget.style.transform = 'translateX(0%)'
    })
    document.querySelectorAll(FAB_SELECTOR).forEach(el => el.classList.add('hidden'))
  }

  close () {
    this.panelTarget.style.transform = 'translateX(-100%)'
    setTimeout(() => {
      this.sliderTarget.classList.remove('flex')
      this.sliderTarget.classList.add('hidden')
    }, 300)
    document.querySelectorAll(FAB_SELECTOR).forEach(el => el.classList.remove('hidden'))
  }

  connect () {
    if (this.hasPanelTarget) {
      this.panelTarget.style.transform = 'translateX(-100%)'
    }
    this.element.addEventListener('close-menu', () => this.close())
  }

  openFeedback (event) {
    const type = event.currentTarget.dataset.type
    this.element.dispatchEvent(new CustomEvent('close-menu', { bubbles: true }))
    setTimeout(() => {
      if (type === 'bug_report') {
        window.openSupportModal?.(type)
      } else {
        window.openFeedbackModal?.()
      }
    }, 350)
  }
}
