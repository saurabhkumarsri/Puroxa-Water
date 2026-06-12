import { Controller } from "@hotwired/stimulus"

// Slide-in mobile menu for the guest navbar (Login / Sign up sheet).
//
// Usage:
//   <div data-controller="mobile-menu" data-mobile-menu-open-class="translate-x-0">
//     <button data-action="mobile-menu#open">…</button>
//     <div data-mobile-menu-target="backdrop" data-action="click->mobile-menu#close"
//          class="fixed inset-0 … opacity-0 pointer-events-none transition-opacity">
//     </div>
//     <div data-mobile-menu-target="panel"
//          class="fixed top-0 right-0 … translate-x-full transition-transform">
//     </div>
//   </div>
//
// The controller:
//   - Toggles a class on the body to lock scroll (avoids body-jump on iOS)
//   - Closes on backdrop click, Escape key, or any link inside the panel
//   - Slides the panel in via a transform class (configurable)
export default class extends Controller {
  static targets = ["backdrop", "panel", "openButton"]

  connect() {
    this._onKey = this._onKey.bind(this)
    this._onLinkClick = this._onLinkClick.bind(this)
    document.addEventListener("keydown", this._onKey)
    this.element.addEventListener("click", this._onLinkClick, true)
  }

  disconnect() {
    document.removeEventListener("keydown", this._onKey)
    this.element.removeEventListener("click", this._onLinkClick, true)
    document.body.classList.remove("overflow-hidden")
  }

  open(event) {
    if (event) event.preventDefault()
    document.body.classList.add("overflow-hidden")
    if (this.hasBackdropTarget) this._showBackdrop()
    if (this.hasPanelTarget) this._showPanel()
    this._swapHamburger(true)
  }

  close(event) {
    if (event) event.preventDefault()
    if (this.hasBackdropTarget) this._hideBackdrop()
    if (this.hasPanelTarget) this._hidePanel()
    document.body.classList.remove("overflow-hidden")
    this._swapHamburger(false)
  }

  toggle(event) {
    if (event) event.preventDefault()
    if (this.hasPanelTarget && !this.panelTarget.classList.contains("translate-x-0")) {
      this.open()
    } else {
      this.close()
    }
  }

  // Private

  _onKey(event) {
    if (event.key === "Escape" && this.hasPanelTarget && this.panelTarget.classList.contains("translate-x-0")) {
      this.close()
    }
  }

  // If the user taps any link inside the menu, close the sheet first so
  // Turbo's page swap isn't fighting an in-flight transition.
  _onLinkClick(event) {
    if (!event.target.closest("a")) return
    if (this.hasPanelTarget && this.panelTarget.classList.contains("translate-x-0")) {
      this.close()
    }
  }

  _showBackdrop() {
    this.backdropTarget.classList.remove("opacity-0", "pointer-events-none")
    this.backdropTarget.classList.add("opacity-100")
  }

  _hideBackdrop() {
    this.backdropTarget.classList.add("opacity-0", "pointer-events-none")
    this.backdropTarget.classList.remove("opacity-100")
  }

  _showPanel() {
    this.panelTarget.classList.remove("translate-x-full")
    this.panelTarget.classList.add("translate-x-0")
  }

  _hidePanel() {
    this.panelTarget.classList.add("translate-x-full")
    this.panelTarget.classList.remove("translate-x-0")
  }

  _swapHamburger(isOpen) {
    if (!this.hasOpenButtonTarget) return
    this.openButtonTarget.setAttribute("aria-expanded", isOpen ? "true" : "false")
  }
}
