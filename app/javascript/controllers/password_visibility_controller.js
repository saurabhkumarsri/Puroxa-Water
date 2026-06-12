import { Controller } from "@hotwired/stimulus"

// Toggle password field between text and password type.
// Also flips the show/hide icon (two child SVGs).

// Usage:
//   <div data-controller="password-visibility">
//     <input data-password-visibility-target="input" type="password" ...>
//     <button data-action="password-visibility#toggle" type="button">
//       <svg data-password-visibility-target="iconShow" ...>...</svg>
//       <svg data-password-visibility-target="iconHide" class="hidden" ...>...</svg>
//     </button>
//   </div>
export default class extends Controller {
  static targets = ["input", "iconShow", "iconHide"]

  toggle(event) {
    if (event) event.preventDefault()
    const showing = this.inputTarget.type === "text"
    this.inputTarget.type = showing ? "password" : "text"
    if (this.hasIconShowTarget) this.iconShowTarget.classList.toggle("hidden", !showing)
    if (this.hasIconHideTarget) this.iconHideTarget.classList.toggle("hidden", showing)
  }
}
