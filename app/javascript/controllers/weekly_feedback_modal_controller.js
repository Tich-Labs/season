import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['container', 'questions', 'weekLabel', 'alreadyCompleted', 'questionTemplate', 'success']

  connect () {
    this._openHandler = () => this.open()
    document.addEventListener('weekly-feedback:open', this._openHandler)
  }

  disconnect () {
    document.removeEventListener('weekly-feedback:open', this._openHandler)
  }

  open () {
    this.containerTarget.style.display = 'flex'
    this.successTarget.style.display = 'none'
    this._loadQuestions()
  }

  close () {
    this.containerTarget.style.display = 'none'
  }

  clickOutside (event) {
    if (event.target === this.containerTarget) this.close()
  }

  toggleYesNo (event) {
    const button = event.currentTarget
    const group = button.closest('[data-question-id]')
    group.querySelectorAll('.wf-yesno-btn').forEach(b => {
      const active = b === button
      b.style.background = active ? '#933a35' : '#FFFFFF'
      b.style.color = active ? '#FFFFFF' : '#933a35'
      b.style.borderColor = active ? '#933a35' : '#EDE1D5'
      b.setAttribute('aria-pressed', active.toString())
    })

    if (button.dataset.value === 'yes') {
      group.querySelector('.wf-why-input').style.display = 'block'
    } else {
      group.querySelector('.wf-why-input').style.display = 'none'
      group.querySelector('.wf-why-textarea').value = ''
    }
  }

  selectOption (event) {
    const button = event.currentTarget
    const group = button.closest('[data-question-id]')
    group.querySelectorAll('.wf-option-btn').forEach(b => {
      const active = b === button
      b.style.background = active ? '#933a35' : '#EDE1D5'
      b.style.color = active ? '#FFFFFF' : '#933A35'
      b.style.opacity = active ? '1' : '0.5'
      b.setAttribute('aria-pressed', active.toString())
    })
  }

  async submit (event) {
    event.preventDefault()
    const form = event.target
    const answers = {}

    form.querySelectorAll('[data-question-id]').forEach(q => {
      const id = q.dataset.questionId
      const type = q.dataset.questionType

      if (type === 'multiple_choice') {
        const selected = q.querySelector('.wf-option-btn[aria-pressed="true"]')
        if (selected) answers[id] = selected.dataset.value
      } else if (type === 'yes_no_with_input') {
        const yes = q.querySelector('.wf-yesno-btn[aria-pressed="true"]')
        if (yes) {
          const why = q.querySelector('.wf-why-textarea')?.value || ''
          answers[id] = why ? `${yes.dataset.value}|${why}` : yes.dataset.value
        }
      } else if (type === 'text_only') {
        const text = q.querySelector('.wf-text-textarea')?.value
        if (text) answers[id] = text
      }
    })

    const token = document.querySelector('meta[name="csrf-token"]')?.content
    if (!token) return

    try {
      const resp = await fetch('/weekly_feedback/submit', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': token
        },
        body: JSON.stringify({ answers })
      })

      if (resp.ok) {
        this.containerTarget.querySelector('.wf-form-wrapper').style.display = 'none'
        this.successTarget.style.display = 'block'
      }
    } catch (e) {
      // silent
    }
  }

  async _loadQuestions () {
    this.questionsTarget.innerHTML = ''
    this.containerTarget.querySelector('.wf-form-wrapper').style.display = 'block'
    this.alreadyCompletedTarget.style.display = 'none'

    try {
      const resp = await fetch('/weekly_feedback')
      const data = await resp.json()

      if (!data.week) {
        this.weekLabelTarget.textContent = ''
        return
      }

      this.weekLabelTarget.textContent = `Week ${data.week}`
      this.element.dataset.week = data.week

      if (data.already_completed) {
        this.containerTarget.querySelector('.wf-form-wrapper').style.display = 'none'
        this.alreadyCompletedTarget.style.display = 'block'
        return
      }

      data.questions.forEach(q => {
        const node = this.questionTemplateTarget.content.cloneNode(true)
        const wrapper = node.querySelector('[data-question-id]')
        wrapper.dataset.questionId = q.id
        wrapper.dataset.questionType = q.question_type
        wrapper.querySelector('.wf-question-text').textContent = q.question_text

        if (q.question_type === 'multiple_choice') {
          const optsContainer = wrapper.querySelector('.wf-multiple-choice')
          optsContainer.style.display = 'flex'
          q.options.forEach(opt => {
            const btn = document.createElement('button')
            btn.type = 'button'
            btn.className = 'wf-option-btn'
            btn.dataset.value = opt
            btn.textContent = opt
            btn.style.cssText = 'flex:1;padding:10px 8px;border-radius:8px;border:1px solid #EDE1D5;background:#EDE1D5;color:#933A35;font-size:14px;font-weight:500;font-family:Montserrat,sans-serif;cursor:pointer;opacity:0.5;text-align:center'
            btn.addEventListener('click', (e) => this.selectOption(e))
            optsContainer.appendChild(btn)
          })
        } else if (q.question_type === 'yes_no_with_input') {
          const ynWrapper = wrapper.querySelector('.wf-yesno-wrapper')
          ynWrapper.style.display = 'block'
          wrapper.querySelector('.wf-why-input').style.display = 'none'
        } else if (q.question_type === 'text_only') {
          const textWrapper = wrapper.querySelector('.wf-text-wrapper')
          textWrapper.style.display = 'block'
        }

        this.questionsTarget.appendChild(wrapper)
      })
    } catch (e) {
      // silent
    }
  }
}
