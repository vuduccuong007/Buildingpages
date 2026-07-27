import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"
import { redirectOnError, redirectToErrorPage } from "error_redirect"

export default class extends Controller {
  static targets = ["sentinel", "status"]

  connect() {
    this.loading = false
    this.abortController = null
    this.observer = new IntersectionObserver(
      (entries) => {
        if (entries.some((entry) => entry.isIntersecting)) this.loadNextPage()
      },
      { rootMargin: "300px 0px" }
    )

    if (this.hasSentinelTarget) this.observer.observe(this.sentinelTarget)
  }

  disconnect() {
    this.abortController?.abort()
    this.observer.disconnect()
  }

  sentinelTargetConnected(element) {
    this.observer?.observe(element)
  }

  sentinelTargetDisconnected(element) {
    this.observer?.unobserve(element)
  }

  retry() {
    this.loadNextPage()
  }

  async loadNextPage() {
    const sentinel = this.sentinelTarget
    const url = sentinel.dataset.nextPageUrl

    if (this.loading || !url) return

    this.loading = true
    sentinel.setAttribute("aria-busy", "true")
    this.setStatus("Loading more buildings…")
    this.abortController = new AbortController()

    try {
      const response = await fetch(url, {
        headers: { Accept: "text/vnd.turbo-stream.html" },
        credentials: "same-origin",
        signal: this.abortController.signal
      })

      if (redirectOnError(response)) return

      Turbo.renderStreamMessage(await response.text())
    } catch (error) {
      if (error.name !== "AbortError") redirectToErrorPage()
    } finally {
      this.loading = false
      this.abortController = null
      sentinel.removeAttribute("aria-busy")
    }
  }

  setStatus(message) {
    if (this.hasStatusTarget) this.statusTarget.textContent = message
  }

  showRetry() {
    if (!this.hasStatusTarget) return

    this.statusTarget.replaceChildren(
      document.createTextNode("Could not load more buildings. "),
      this.retryButton()
    )
  }

  retryButton() {
    const button = document.createElement("button")
    button.type = "button"
    button.className = "building-pagination__retry"
    button.textContent = "Try again"
    button.dataset.action = "infinite-scroll#retry"
    return button
  }
}
