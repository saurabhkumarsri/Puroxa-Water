/* Puroxa Water — Service Worker
 * Provides:
 *   - Offline fallback page when the network is down
 *   - Network-first for HTML navigations (fresh content preferred)
 *   - Cache-first for static assets (faster repeat loads)
 *   - Auto-cleanup of old caches on activate
 *
 * Versioned cache name — bump "vN" to force a clean slate of old caches.
 */

const VERSION = "v1";
const CACHE_RUNTIME = `puroxa-runtime-${VERSION}`;
const CACHE_STATIC = `puroxa-static-${VERSION}`;

// Files to precache on install so the app shell works offline
const PRECACHE_URLS = [
  "/",
  "/offline.html",
  "/manifest.json",
  "/icons/icon-192.png",
  "/icons/icon-512.png",
  "/icons/icon-maskable-192.png",
  "/icons/icon-maskable-512.png",
  "/icons/apple-touch-icon.png",
];

// ------------------------------------------------------------
// INSTALL — pre-cache the app shell
// ------------------------------------------------------------
self.addEventListener("install", (event) => {
  event.waitUntil(
    caches
      .open(CACHE_STATIC)
      .then((cache) =>
        // Use addAll with {cache: "reload"} so we don't serve stale on first install
        cache.addAll(
          PRECACHE_URLS.map((url) => new Request(url, { cache: "reload" }))
        )
      )
      .then(() => self.skipWaiting())
  );
});

// ------------------------------------------------------------
// ACTIVATE — clean up old caches
// ------------------------------------------------------------
self.addEventListener("activate", (event) => {
  event.waitUntil(
    (async () => {
      const keys = await caches.keys();
      await Promise.all(
        keys
          .filter((k) => k !== CACHE_RUNTIME && k !== CACHE_STATIC)
          .map((k) => caches.delete(k))
      );
      await self.clients.claim();
    })()
  );
});

// ------------------------------------------------------------
// FETCH — routing strategy
// ------------------------------------------------------------
self.addEventListener("fetch", (event) => {
  const { request } = event;

  // ngrok free tier injects an interstitial warning page on first visit.
  // We bypass it by adding the skip header to every outgoing request —
  // ngrok reads it and serves the real response. Safe outside ngrok.
  const bypassNgrok = new Request(request, {
    headers: new Headers({
      ...Object.fromEntries(request.headers.entries()),
      "ngrok-skip-browser-warning": "true",
    }),
  });

  // Only handle GET
  if (bypassNgrok.method !== "GET") return;

  const url = new URL(bypassNgrok.url);

  // Skip cross-origin requests
  if (url.origin !== self.location.origin) return;

  // Skip Rails auth & live-update endpoints to avoid serving stale
  if (
    url.pathname.startsWith("/login") ||
    url.pathname.startsWith("/logout") ||
    url.pathname.startsWith("/admin/login") ||
    url.pathname.startsWith("/vendor/login") ||
    url.pathname.startsWith("/admin/logout") ||
    url.pathname.startsWith("/vendor/logout") ||
    url.pathname.startsWith("/cable") ||
    url.pathname.includes("/rails/")
  ) {
    return;
  }

  // HTML navigations — network-first, fall back to cache, then offline page
  if (bypassNgrok.mode === "navigate" || bypassNgrok.headers.get("accept")?.includes("text/html")) {
    event.respondWith(networkFirstNavigation(bypassNgrok));
    return;
  }

  // Static assets — cache-first
  if (isStaticAsset(url.pathname)) {
    event.respondWith(cacheFirstStatic(bypassNgrok));
    return;
  }

  // Everything else — try network, fall back to cache
  event.respondWith(networkFirstWithCache(bypassNgrok));
});

// ------------------------------------------------------------
// Strategies
// ------------------------------------------------------------

async function networkFirstNavigation(request) {
  try {
    const response = await fetch(request);
    if (response && response.ok) {
      const cache = await caches.open(CACHE_RUNTIME);
      cache.put(request, response.clone());
    }
    return response;
  } catch (err) {
    // Network failed — try cache
    const cached = await caches.match(request);
    if (cached) return cached;

    // Last resort: offline page
    const offline = await caches.match("/offline.html");
    if (offline) return offline;

    return new Response("Offline", {
      status: 503,
      statusText: "Offline",
      headers: { "Content-Type": "text/plain" },
    });
  }
}

async function cacheFirstStatic(request) {
  const cached = await caches.match(request);
  if (cached) {
    // Re-validate in background
    fetch(request)
      .then((response) => {
        if (response && response.ok) {
          caches.open(CACHE_STATIC).then((c) => c.put(request, response));
        }
      })
      .catch(() => {});
    return cached;
  }
  // Not in cache — fetch and store
  try {
    const response = await fetch(request);
    if (response && response.ok) {
      const cache = await caches.open(CACHE_STATIC);
      cache.put(request, response.clone());
    }
    return response;
  } catch (err) {
    return new Response("Asset unavailable", { status: 503 });
  }
}

async function networkFirstWithCache(request) {
  try {
    const response = await fetch(request);
    if (response && response.ok) {
      const cache = await caches.open(CACHE_RUNTIME);
      cache.put(request, response.clone());
    }
    return response;
  } catch (err) {
    const cached = await caches.match(request);
    return cached || new Response("Unavailable", { status: 503 });
  }
}

function isStaticAsset(pathname) {
  return (
    pathname.startsWith("/assets/") ||
    pathname.startsWith("/icons/") ||
    /\.(?:js|css|png|jpg|jpeg|svg|webp|ico|woff2?|ttf|eot)$/.test(pathname)
  );
}

// ------------------------------------------------------------
// Message handler — allow client to skipWaiting on update
// ------------------------------------------------------------
self.addEventListener("message", (event) => {
  if (event.data?.type === "SKIP_WAITING") {
    self.skipWaiting();
  }
});
