import { Controller } from "@hotwired/stimulus"

// Captures the browser's "beforeinstallprompt" event and exposes
// a method to actually trigger the install prompt.
//
// Why this exists:
//   Browsers fire `beforeinstallprompt` once per page load when the
//   app is installable (manifest valid, SW registered, HTTPS, etc.).
//   We can't show the prompt directly when it fires — we have to save
//   the event and call `event.prompt()` later from a user gesture
//   (e.g. clicking our "Install" button).
//
// Usage:
//   <div data-controller="pwa-install"
//        data-pwa-install-target="banner"
//        class="hidden ...">
//     <button data-action="pwa-install#prompt">Install</button>
//     <button data-action="pwa-install#dismiss">Not now</button>
//   </div>
//
// Targets:
//   - banner: the install-prompt UI (hidden by default, shown when ready)
//
// Events:
//   - "pwa-install:ready" — fired on `this.element` when install is available
//   - "pwa-install:installed" — fired when the user actually installs
//   - "pwa-install:dismissed" — fired when the user dismisses
//
// Persistence:
//   - Dismissal is stored in localStorage so we don't pester users
//   - Auto-expires after 14 days so we re-prompt eventually
const DISMISS_KEY = "puroxa_pwa_dismissed_at"
const DISMISS_DAYS = 14

export default class extends Controller {
  static targets = ["banner"]
  static values = {
    delayMs: { type: Number, default: 30000 }, // Don't show for 30s after page load
  }

  connect() {
    this._deferredPrompt = null
    this._wasInstalled = false

    // Browser fires this when the app is installable
    window.addEventListener("beforeinstallprompt", (event) => {
      event.preventDefault() // We want to show it on our terms
      this._deferredPrompt = event
      this._maybeShow()
    })

    // Fires after a successful install
    window.addEventListener("appinstalled", () => {
      this._wasInstalled = true
      this._hideBanner()
      this.dispatch("installed")
      console.info("[PWA] App installed")
    })
  }

  // User clicked the install button
  async prompt(event) {
    if (event) event.preventDefault()
    if (!this._deferredPrompt) {
      console.info("[PWA] No deferred install prompt available")
      return
    }

    try {
      this._deferredPrompt.prompt()
      const choice = await this._deferredPrompt.userChoice
      console.info("[PWA] User choice:", choice.outcome)

      if (choice.outcome === "accepted") {
        this._hideBanner()
      } else {
        this.dismiss()
      }

      // The prompt can only be used once
      this._deferredPrompt = null
    } catch (err) {
      console.error("[PWA] Install prompt failed:", err)
    }
  }

  // User clicked "Not now" / "Maybe later"
  dismiss(event) {
    if (event) event.preventDefault()
    this._hideBanner()
    try {
      localStorage.setItem(DISMISS_KEY, Date.now().toString())
    } catch (e) {
      // localStorage may be blocked — that's fine, just don't persist
    }
    this.dispatch("dismissed")
  }

  // ------------------------------------------------------------------

  _maybeShow() {
    // Don't show if user already installed
    if (this._isRunningStandalone()) {
      return
    }

    // Don't show if user dismissed recently
    if (this._isDismissedRecently()) {
      return
    }

    // Don't show on this page if there's no banner target
    if (!this.hasBannerTarget) {
      // Still fire the event so an external listener can react
      this.dispatch("ready")
      return
    }

    // Wait a bit so we don't interrupt the user's first interaction
    if (this._timer) clearTimeout(this._timer)
    this._timer = setTimeout(() => {
      this._showBanner()
      this.dispatch("ready")
    }, this.delayMsValue)
  }

  _showBanner() {
    if (!this.hasBannerTarget) return
    this.bannerTarget.classList.remove("hidden")
    // Make it keyboard focusable in case it has interactive children
    this.bannerTarget.setAttribute("aria-hidden", "false")
  }

  _hideBanner() {
    if (!this.hasBannerTarget) return
    this.bannerTarget.classList.add("hidden")
    this.bannerTarget.setAttribute("aria-hidden", "true")
  }

  _isRunningStandalone() {
    // iOS Safari
    if (window.navigator.standalone === true) return true
    // Other browsers (display-mode: standalone)
    return (
      window.matchMedia &&
      window.matchMedia("(display-mode: standalone)").matches
    )
  }

  _isDismissedRecently() {
    try {
      const stored = localStorage.getItem(DISMISS_KEY)
      if (!stored) return false
      const dismissedAt = parseInt(stored, 10)
      if (Number.isNaN(dismissedAt)) return false
      const ageMs = Date.now() - dismissedAt
      return ageMs < DISMISS_DAYS * 24 * 60 * 60 * 1000
    } catch (e) {
      return false
    }
  }
}
