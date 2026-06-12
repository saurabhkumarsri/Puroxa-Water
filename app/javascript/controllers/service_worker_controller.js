import { Controller } from "@hotwired/stimulus"

// Registers the service worker on connect.
//
// Why a controller instead of inline script?
//   - Runs on every Turbo navigation (Stimulus handles re-mounting)
//   - Only registers once per page (controller connects once, then we early-out)
//   - Logs clear status messages so we can verify in DevTools → Application → Service Workers
//
// Usage:
//   <div data-controller="service-worker"></div>
//
// Place this anywhere on the page (it's a singleton — the markup can live in
// the layout, not in a partial that gets re-rendered).
export default class extends Controller {
  connect() {
    // Bail if not supported
    if (!("serviceWorker" in navigator)) {
      console.info("[PWA] Service workers not supported in this browser")
      return
    }

    // Guard against double-registration
    if (window.__puroxa_sw_registered) return
    window.__puroxa_sw_registered = true

    // Wait for the page to be fully loaded — registering during load can
    // delay first paint on slow networks
    window.addEventListener("load", () => {
      this._register()
    })
  }

  async _register() {
    try {
      const registration = await navigator.serviceWorker.register("/service-worker.js", {
        scope: "/",
        updateViaCache: "none", // Always re-fetch the SW file itself
      })

      console.info("[PWA] Service worker registered:", registration.scope)

      // Detect updates and reload so the user gets the new version
      registration.addEventListener("updatefound", () => {
        const newWorker = registration.installing
        if (!newWorker) return

        newWorker.addEventListener("statechange", () => {
          if (
            newWorker.state === "installed" &&
            navigator.serviceWorker.controller
          ) {
            // New version is ready — let user know
            console.info("[PWA] New service worker installed, ready to activate")
            this.dispatch("updated", { detail: { registration } })
          }
        })
      })

      // Listen for controller changes (when new SW takes over)
      navigator.serviceWorker.addEventListener("controllerchange", () => {
        // Auto-reload to pick up the new SW — this is a one-time event
        // so we don't loop. The new SW will be in control from this point.
        if (window.__puroxa_sw_reloaded) return
        window.__puroxa_sw_reloaded = true
        window.location.reload()
      })
    } catch (err) {
      console.error("[PWA] Service worker registration failed:", err)
    }
  }
}
