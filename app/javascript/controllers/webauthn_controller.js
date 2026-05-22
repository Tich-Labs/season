import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['status']

  connect () {
    this.supported = window.PublicKeyCredential !== undefined
  }

  async register (event) {
    event.preventDefault()

    if (!this.supported) {
      this._status('Biometrics not supported on this device')
      return
    }

    try {
      const challengeResp = await fetch('/webauthn/registration-challenge')
      if (!challengeResp.ok) {
        this._status('Failed to start registration')
        return
      }
      const options = await challengeResp.json()
      options.challenge = this._base64url(options.challenge)
      options.user.id = this._base64url(options.user.id)

      const cred = await navigator.credentials.create({ publicKey: options })
      if (!cred) {
        this._status('Registration cancelled')
        return
      }

      const credential = {
        id: cred.id,
        type: cred.type,
        response: {
          publicKey: this._ab2str(cred.response.getPublicKey())
        }
      }

      const resp = await fetch('/webauthn/register', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'X-CSRF-Token': this._csrf() },
        body: JSON.stringify({ credential })
      })

      if (resp.ok) {
        this._status('Face ID / Touch ID enabled')
        window.location.reload()
      } else {
        this._status('Registration failed')
      }
    } catch (e) {
      this._status(e.message)
    }
  }

  async authenticate (event) {
    event.preventDefault()

    if (!this.supported) return

    try {
      const challengeResp = await fetch('/webauthn/authentication-challenge')
      if (!challengeResp.ok) return
      const options = await challengeResp.json()
      options.challenge = this._base64url(options.challenge)
      if (options.allowCredentials) {
        options.allowCredentials.forEach(c => {
          c.id = this._base64url(c.id)
        })
      }

      const assertion = await navigator.credentials.get({ publicKey: options })
      if (!assertion) return

      const credential = {
        id: assertion.id,
        type: assertion.type,
        response: {
          authenticatorData: this._ab2str(assertion.response.authenticatorData),
          signature: this._ab2str(assertion.response.signature),
          clientDataJSON: this._ab2str(assertion.response.clientDataJSON),
          userHandle: assertion.response.userHandle
            ? this._ab2str(assertion.response.userHandle)
            : null
        }
      }

      const resp = await fetch('/webauthn/authenticate', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'X-CSRF-Token': this._csrf() },
        body: JSON.stringify({ credential })
      })

      if (resp.ok) {
        const data = await resp.json()
        window.location.href = data.redirect || '/calendar'
      }
    } catch (e) {
      console.warn('WebAuthn auth failed:', e.message)
    }
  }

  async remove (event) {
    event.preventDefault()
    const id = this.data.get('credentialId')
    if (!id) return

    await fetch(`/webauthn/credentials/${id}`, {
      method: 'DELETE',
      headers: { 'X-CSRF-Token': this._csrf() }
    })
    window.location.reload()
  }

  _status (msg) {
    if (this.hasStatusTarget) {
      this.statusTarget.textContent = msg
    }
  }

  _base64url (str) {
    return Uint8Array.from(atob(str.replace(/-/g, '+').replace(/_/g, '/')), c => c.charCodeAt(0))
  }

  _ab2str (buf) {
    return btoa(String.fromCharCode(...new Uint8Array(buf)))
  }

  _csrf () {
    return document.querySelector("[name='csrf-token']")?.content || ''
  }
}
