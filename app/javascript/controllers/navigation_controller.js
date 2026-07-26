import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "drawer"]

  toggle() {
    this.drawerTarget.hidden ? this.open() : this.close()
  }

  open() {
    this.drawerTarget.hidden = false
    this.buttonTarget.setAttribute("aria-expanded", "true")
    this.buttonTarget.setAttribute("aria-label", "Close navigation")
  }

  close() {
    if (this.drawerTarget.hidden) return

    this.drawerTarget.hidden = true
    this.buttonTarget.setAttribute("aria-expanded", "false")
    this.buttonTarget.setAttribute("aria-label", "Open navigation")
    this.buttonTarget.focus()
  }

  dismiss(event) {
    if (this.drawerTarget.hidden) return
    if (this.drawerTarget.contains(event.target) || this.buttonTarget.contains(event.target)) return

    this.close()
  }
}
