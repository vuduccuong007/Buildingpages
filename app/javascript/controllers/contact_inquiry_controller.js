import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dialog", "listingId", "unit"]
  static values = { open: Boolean }

  connect() {
    this.restoreFocus = this.restoreFocus.bind(this)
    this.dialogTarget.addEventListener("close", this.restoreFocus)
    this.listingIdTarget.disabled = false

    if (this.dialogTarget.open) this.dialogTarget.close()
    if (this.openValue) this.dialogTarget.showModal()
  }

  disconnect() {
    this.dialogTarget.removeEventListener("close", this.restoreFocus)
  }

  open(event) {
    this.triggeringButton = event.currentTarget
    this.listingIdTarget.value = event.params.listingId
    this.unitTarget.textContent = event.params.unit
    this.dialogTarget.showModal()
  }

  close() {
    this.dialogTarget.close()
  }

  restoreFocus() {
    this.triggeringButton?.focus()
  }
}
