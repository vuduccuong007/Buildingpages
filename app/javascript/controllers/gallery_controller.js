import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["track"]
  static values = {
    interval: { type: Number, default: 5000 }
  }

  connect() {
    this.play()
  }

  disconnect() {
    this.pause()
  }

  previous() {
    this.scroll(-1)
    this.restart()
  }

  next() {
    this.scroll(1)
    this.restart()
  }

  scroll(direction) {
    const panel = this.trackTarget.querySelector(".gallery-panel")
    if (!panel) return

    const gap = parseFloat(getComputedStyle(this.trackTarget).columnGap) || 0
    const step = panel.getBoundingClientRect().width + gap
    const maximumScroll = this.trackTarget.scrollWidth - this.trackTarget.clientWidth
    const atStart = this.trackTarget.scrollLeft <= 1
    const atEnd = this.trackTarget.scrollLeft >= maximumScroll - 1
    const reduceMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches
    let left = this.trackTarget.scrollLeft + direction * step

    if (direction > 0 && atEnd) left = 0
    if (direction < 0 && atStart) left = maximumScroll

    this.trackTarget.scrollTo({
      left,
      behavior: reduceMotion ? "auto" : "smooth"
    })
  }

  play() {
    this.pause()

    if (
      this.intervalValue <= 0 ||
      this.trackTarget.querySelectorAll(".gallery-panel").length < 2 ||
      window.matchMedia("(prefers-reduced-motion: reduce)").matches ||
      document.hidden
    ) return

    this.timer = window.setInterval(() => this.scroll(1), this.intervalValue)
  }

  pause() {
    if (!this.timer) return

    window.clearInterval(this.timer)
    this.timer = null
  }

  restart() {
    if (
      !this.element.matches(":hover") &&
      !this.element.matches(":focus-within")
    ) this.play()
  }

  visibilityChanged() {
    document.hidden ? this.pause() : this.play()
  }
}
