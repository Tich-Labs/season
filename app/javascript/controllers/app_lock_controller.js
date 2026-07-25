/* global Turbo */
import { Controller } from '@hotwired/stimulus'

// Forces a fresh Turbo visit when the app/tab returns to the foreground after
// being idle past the PIN timeout, so the server-side pin_unlock_required?
// check (and the pin/_unlock_modal overlay) fires immediately instead of
// waiting for the user's next natural navigation. Only mounted for users who
// have App Lock enabled (see application.html.erb), and only on the web/PWA
// path — the native iOS wrapper has its own equivalent in SceneDelegate.
export default class extends Controller {
  static values = { timeout: Number } // ms

  connect () {
    if (document.documentElement.hasAttribute('data-ruby-native')) return

    this.hiddenAt = null
    this._onVisibilityChange = this._onVisibilityChange.bind(this)
    this._onBlur = this._onBlur.bind(this)
    this._onFocus = this._onFocus.bind(this)

    document.addEventListener('visibilitychange', this._onVisibilityChange)
    window.addEventListener('blur', this._onBlur)
    window.addEventListener('focus', this._onFocus)
  }

  disconnect () {
    document.removeEventListener('visibilitychange', this._onVisibilityChange)
    window.removeEventListener('blur', this._onBlur)
    window.removeEventListener('focus', this._onFocus)
  }

  _onVisibilityChange () {
    if (document.hidden) {
      this._markHidden()
    } else {
      this._checkElapsed()
    }
  }

  _onBlur () {
    this._markHidden()
  }

  _onFocus () {
    this._checkElapsed()
  }

  _markHidden () {
    if (this.hiddenAt === null) this.hiddenAt = Date.now()
  }

  _checkElapsed () {
    if (this.hiddenAt === null) return
    const elapsed = Date.now() - this.hiddenAt
    this.hiddenAt = null
    if (elapsed >= this.timeoutValue) {
      Turbo.visit(window.location.href, { action: 'replace' })
    }
  }
}
