import { Controller } from '@hotwired/stimulus'

// Circular avatar crop: pick a file -> drag to reposition + zoom slider ->
// "Set picture" bakes the current pan/zoom into an actual cropped image
// (plain <canvas>, no library) and hands that off as the file that gets
// uploaded. What's stored is exactly what was shown in the preview, not the
// original untouched photo — an object-position offset saved separately
// would mean every future place that renders the avatar has to know to
// re-apply it; baking it in once here means it doesn't.
export default class extends Controller {
  static targets = ['pickerStep', 'cropStep', 'frame', 'image', 'zoom', 'fileInput', 'form']

  #naturalWidth = 0
  #naturalHeight = 0
  #baseScale = 1
  #frameSize = 0
  #posX = 0
  #posY = 0
  #dragging = false
  #dragStartX = 0
  #dragStartY = 0
  #dragStartPosX = 0
  #dragStartPosY = 0

  // Fires on the hidden file input's change event — replaces the old
  // "upload the raw file as-is" flow. Nothing is saved until #confirm.
  open (event) {
    const file = event.currentTarget.files?.[0]
    if (!file) return

    // Reveal the crop step *before* measuring the frame below — clientWidth
    // reads 0 on a `display:none` ancestor, so measuring first would size
    // everything off a frame that hasn't actually laid out yet.
    this.pickerStepTarget.classList.add('hidden')
    this.cropStepTarget.classList.remove('hidden')

    const url = URL.createObjectURL(file)
    const img = this.imageTarget
    img.style.opacity = '0'
    img.onload = () => {
      this.#naturalWidth = img.naturalWidth
      this.#naturalHeight = img.naturalHeight
      this.#frameSize = this.frameTarget.clientWidth
      // Cover-fit on the shorter natural dimension — at zoom 1 (the slider's
      // minimum) the image exactly fills the frame with no empty edges.
      this.#baseScale = this.#frameSize / Math.min(this.#naturalWidth, this.#naturalHeight)

      const scaledW = this.#naturalWidth * this.#baseScale
      const scaledH = this.#naturalHeight * this.#baseScale
      // Centred by default, not top-left-anchored — matters whenever the
      // photo isn't square, which is most photos.
      this.#posX = (this.#frameSize - scaledW) / 2
      this.#posY = (this.#frameSize - scaledH) / 2

      this.zoomTarget.value = '1'
      this.#applyTransform(1)
      img.style.opacity = '1'
      URL.revokeObjectURL(url)
    }
    img.src = url
  }

  cancel () {
    this.cropStepTarget.classList.add('hidden')
    this.pickerStepTarget.classList.remove('hidden')
    this.fileInputTarget.value = ''
  }

  zoomChanged () {
    this.#applyTransform(parseFloat(this.zoomTarget.value))
  }

  dragStart (event) {
    this.#dragging = true
    this.#dragStartX = event.clientX
    this.#dragStartY = event.clientY
    this.#dragStartPosX = this.#posX
    this.#dragStartPosY = this.#posY
    this.frameTarget.setPointerCapture(event.pointerId)
  }

  dragMove (event) {
    if (!this.#dragging) return
    this.#posX = this.#dragStartPosX + (event.clientX - this.#dragStartX)
    this.#posY = this.#dragStartPosY + (event.clientY - this.#dragStartY)
    this.#applyTransform(parseFloat(this.zoomTarget.value))
  }

  dragEnd () {
    this.#dragging = false
  }

  // Renders exactly what's visible in the frame into a square canvas at a
  // fixed output resolution, converts that to a File, and swaps it into the
  // real file input (via DataTransfer — the only way to set a <input
  // type=file>'s FileList from script) before submitting the existing form
  // unchanged. The server never has to know cropping happened.
  confirm () {
    const zoom = parseFloat(this.zoomTarget.value)
    const scale = this.#baseScale * zoom
    const outputSize = 512

    const canvas = document.createElement('canvas')
    canvas.width = outputSize
    canvas.height = outputSize
    const ctx = canvas.getContext('2d')

    // Inverse of #applyTransform's CSS math: convert the frame's visible
    // window back into natural-pixel source coordinates on the image.
    const sx = -this.#posX / scale
    const sy = -this.#posY / scale
    const sSize = this.#frameSize / scale
    ctx.drawImage(this.imageTarget, sx, sy, sSize, sSize, 0, 0, outputSize, outputSize)

    canvas.toBlob((blob) => {
      if (!blob) return
      const file = new File([blob], 'avatar.jpg', { type: 'image/jpeg' })
      const transfer = new DataTransfer()
      transfer.items.add(file)
      this.fileInputTarget.files = transfer.files
      this.formTarget.requestSubmit()
    }, 'image/jpeg', 0.92)
  }

  // Applies the current pan/zoom to the <img>'s CSS transform, clamping
  // position so it can never be dragged or zoomed out to reveal empty space
  // around the frame's edges.
  #applyTransform (zoom) {
    const scale = this.#baseScale * zoom
    const scaledW = this.#naturalWidth * scale
    const scaledH = this.#naturalHeight * scale

    const minX = this.#frameSize - scaledW
    const minY = this.#frameSize - scaledH
    this.#posX = Math.min(0, Math.max(minX, this.#posX))
    this.#posY = Math.min(0, Math.max(minY, this.#posY))

    this.imageTarget.style.width = `${scaledW}px`
    this.imageTarget.style.height = `${scaledH}px`
    this.imageTarget.style.transform = `translate(${this.#posX}px, ${this.#posY}px)`
  }
}
