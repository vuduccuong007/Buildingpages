import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["track"]

  previous() {
    this.scroll(-1)
  }

  next() {
    this.scroll(1)
  }

  scroll(direction) {
    const panel = this.trackTarget.querySelector(".gallery-panel")
    if (!panel) return

    const gap = parseFloat(getComputedStyle(this.trackTarget).columnGap) || 0
    this.trackTarget.scrollBy({
      left: direction * (panel.getBoundingClientRect().width + gap),
      behavior: "smooth"
    })
  }
}
