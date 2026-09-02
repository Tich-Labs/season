import { Controller } from '@hotwired/stimulus'

// Drives the one-question-at-a-time weekly feedback wizard
// (app/views/weekly_feedbacks/show.html.erb) — per Figma nodes 12178:6399 /
// 12178:7300 / 12178:7283. Answers are held in memory and posted together
// to the existing /weekly_feedback/submit endpoint once the last question
// is confirmed, mirroring the batch-submit the old modal used.
export default class extends Controller {
  static targets = ['question', 'dot', 'nextBtn', 'wizard', 'success', 'whyInput']
  static values = { submitUrl: String, redirectUrl: String }

  connect () {
    this.index = 0
    this.answers = {}
  }

  selectOption (event) {
    const button = event.currentTarget
    const group = button.closest('[data-question-id]')
    group.querySelectorAll('.fw-option-btn').forEach(b => {
      const active = b === button
      b.classList.toggle('opacity-50', !active)
      b.setAttribute('aria-pressed', active.toString())
    })
    this.answers[group.dataset.questionId] = button.dataset.value
  }

  toggleYesNo (event) {
    const button = event.currentTarget
    const group = button.closest('[data-question-id]')
    group.querySelectorAll('.fw-yesno-btn').forEach(b => {
      const active = b === button
      b.classList.toggle('opacity-50', !active)
      b.setAttribute('aria-pressed', active.toString())
    })

    const why = group.querySelector('.fw-why-textarea')
    if (button.dataset.value === 'yes') {
      why.hidden = false
    } else {
      why.hidden = true
      why.value = ''
    }

    const answer = why.hidden ? button.dataset.value : `${button.dataset.value}|${why.value}`
    this.answers[group.dataset.questionId] = answer
  }

  textChanged (event) {
    const group = event.currentTarget.closest('[data-question-id]')
    this.answers[group.dataset.questionId] = event.currentTarget.value
  }

  advance () {
    const current = this.questionTargets[this.index]
    if (!this._isAnswered(current)) return

    const isLast = this.index === this.questionTargets.length - 1
    if (isLast) {
      this._submit()
      return
    }

    current.hidden = true
    this.index += 1
    this.questionTargets[this.index].hidden = false
    this._updateDots()
    this._updateButtonLabel()
  }

  _isAnswered (question) {
    const id = question.dataset.questionId
    const type = question.dataset.questionType
    const answer = this.answers[id]

    if (type === 'yes_no_with_input') {
      // A bare "yes"/"no" (no "|why") is a complete answer — the textarea is optional.
      return typeof answer === 'string' && answer.length > 0
    }
    return typeof answer === 'string' && answer.trim().length > 0
  }

  _updateDots () {
    this.dotTargets.forEach((dot, i) => {
      dot.classList.toggle('bg-brand-primary', i === this.index)
      dot.classList.toggle('bg-brand-primary/20', i !== this.index)
    })
  }

  _updateButtonLabel () {
    const isLast = this.index === this.questionTargets.length - 1
    this.nextBtnTarget.textContent = isLast ? this.nextBtnTarget.dataset.submitLabel || 'Submit' : this.nextBtnTarget.dataset.nextLabel || 'Next'
  }

  async _submit () {
    const token = document.querySelector('meta[name="csrf-token"]')?.content
    if (!token) return

    this.nextBtnTarget.disabled = true

    try {
      const resp = await fetch(this.submitUrlValue, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': token
        },
        body: JSON.stringify({ answers: this.answers })
      })

      if (resp.ok) {
        this.wizardTarget.hidden = true
        this.successTarget.hidden = false
      } else {
        this.nextBtnTarget.disabled = false
      }
    } catch (e) {
      this.nextBtnTarget.disabled = false
    }
  }
}
