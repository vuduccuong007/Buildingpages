import { Controller } from "@hotwired/stimulus"

const DEBOUNCE_DELAY = 275

export default class extends Controller {
  static targets = ["input", "listbox"]
  static values = { url: String }

  connect() {
    this.activeIndex = -1
    this.results = []
    this.requestSequence = 0
  }

  disconnect() {
    this.cancelPendingRequest()
    clearTimeout(this.debounceTimer)
  }

  search() {
    clearTimeout(this.debounceTimer)
    this.cancelPendingRequest()

    const query = this.inputTarget.value.trim()

    if (query.length < 2) {
      this.clearResults()
      return
    }

    this.debounceTimer = setTimeout(() => this.fetchResults(query), DEBOUNCE_DELAY)
  }

  keydown(event) {
    if (event.key === "Escape") {
      event.preventDefault()
      this.dismissResults()
      return
    }

    if (this.results.length === 0) return

    if (event.key === "ArrowDown") {
      event.preventDefault()
      this.moveActiveOption(1)
    } else if (event.key === "ArrowUp") {
      event.preventDefault()
      this.moveActiveOption(-1)
    } else if (event.key === "Enter" && this.activeIndex >= 0) {
      event.preventDefault()
      this.navigateTo(this.results[this.activeIndex].url)
    }
  }

  focusOut(event) {
    if (!this.element.contains(event.relatedTarget)) this.dismissResults()
  }

  async fetchResults(query) {
    const requestSequence = ++this.requestSequence
    this.abortController = new AbortController()
    const url = new URL(this.urlValue, window.location.origin)
    url.searchParams.set("q", query)

    try {
      const response = await fetch(url, {
        headers: { Accept: "application/json" },
        signal: this.abortController.signal
      })

      if (!response.ok) throw new Error(`Autocomplete request failed: ${response.status}`)

      const results = await response.json()
      if (requestSequence !== this.requestSequence) return

      this.renderResults(results)
    } catch (error) {
      if (error.name !== "AbortError" && requestSequence === this.requestSequence) {
        this.clearResults()
      }
    }
  }

  renderResults(results) {
    this.listboxTarget.replaceChildren()
    this.results = results
    this.activeIndex = -1
    this.inputTarget.removeAttribute("aria-activedescendant")

    if (results.length === 0) {
      const emptyOption = document.createElement("li")
      emptyOption.className = "building-search__empty"
      emptyOption.setAttribute("role", "option")
      emptyOption.setAttribute("aria-disabled", "true")
      emptyOption.textContent = "No buildings found"
      this.listboxTarget.append(emptyOption)
    } else {
      results.forEach((result, index) => {
        this.listboxTarget.append(this.buildOption(result, index))
      })
    }

    this.listboxTarget.hidden = false
    this.inputTarget.setAttribute("aria-expanded", "true")
  }

  buildOption(result, index) {
    const option = document.createElement("li")
    option.id = `building-autocomplete-option-${index}`
    option.className = "building-search__option"
    option.setAttribute("role", "option")
    option.setAttribute("aria-selected", "false")
    option.addEventListener("mousedown", (event) => event.preventDefault())
    option.addEventListener("click", () => this.navigateTo(result.url))

    const name = document.createElement("span")
    name.className = "building-search__name"
    name.textContent = result.name

    const details = document.createElement("span")
    details.className = "building-search__details"
    details.textContent = [result.neighborhood, result.full_address].filter(Boolean).join(" · ")

    option.append(name, details)
    return option
  }

  moveActiveOption(direction) {
    const options = this.listboxTarget.querySelectorAll('[role="option"]:not([aria-disabled="true"])')
    if (options.length === 0) return

    if (this.activeIndex === -1) {
      this.activeIndex = direction > 0 ? 0 : options.length - 1
    } else {
      this.activeIndex = (this.activeIndex + direction + options.length) % options.length
    }

    options.forEach((option, index) => {
      option.setAttribute("aria-selected", String(index === this.activeIndex))
    })

    const activeOption = options[this.activeIndex]
    this.inputTarget.setAttribute("aria-activedescendant", activeOption.id)
    activeOption.scrollIntoView({ block: "nearest" })
  }

  navigateTo(url) {
    window.location.assign(url)
  }

  cancelPendingRequest() {
    this.requestSequence += 1
    this.abortController?.abort()
    this.abortController = null
  }

  dismissResults() {
    clearTimeout(this.debounceTimer)
    this.cancelPendingRequest()
    this.clearResults()
  }

  clearResults() {
    this.results = []
    this.activeIndex = -1
    this.listboxTarget.replaceChildren()
    this.listboxTarget.hidden = true
    this.inputTarget.setAttribute("aria-expanded", "false")
    this.inputTarget.removeAttribute("aria-activedescendant")
  }
}
