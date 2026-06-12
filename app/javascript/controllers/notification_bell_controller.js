import { Controller } from "@hotwired/stimulus"

// Toggles the notification dropdown panel. Wires up:
//   - click on the bell button → toggle panel
//   - click anywhere outside the panel → close it
//   - press Escape → close it
//
// Targets (defined inline on the button + panel in the partial):
//   data-controller="notification-bell"
//   data-notification-bell-target="button"
//   data-notification-bell-target="panel"
//
// Stimulus auto-reconnects this controller on Turbo navigations, so the
// dropdown keeps working after every page swap — unlike inline onclick
// which can lose its handler when Turbo replaces the body.
export default class extends Controller {
  static targets = ["button", "panel"]

  connect() {
    this._onDocClick = this._onDocClick.bind(this)
    this._onKey = this._onKey.bind(this)
    document.addEventListener("click", this._onDocClick, true)
    document.addEventListener("keydown", this._onKey)
  }

  disconnect() {
    document.removeEventListener("click", this._onDocClick, true)
    document.removeEventListener("keydown", this._onKey)
  }

  toggle(event) {
    if (event) event.preventDefault()
    this.panelTarget.classList.toggle("hidden")
  }

  // Close panel when clicking outside the bell element
  _onDocClick(event) {
    if (this.panelTarget.classList.contains("hidden")) return
    if (this.element.contains(event.target)) return
    this.panelTarget.classList.add("hidden")
  }

  // Close panel on Escape
  _onKey(event) {
    if (event.key === "Escape" && !this.panelTarget.classList.contains("hidden")) {
      this.panelTarget.classList.add("hidden")
      this.buttonTarget.focus()
    }
  }
}
