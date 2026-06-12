# Puroxa Water — PWA Setup

Your app is now a full Progressive Web App. Users can install it on Android,
iOS, and desktop — and it'll keep working offline.

---

## What's included

### Files added
| Path | Purpose |
|---|---|
| `public/manifest.json` | App metadata (name, icons, theme, scope) |
| `public/service-worker.js` | Offline cache + fetch routing |
| `public/offline.html` | Styled fallback shown when offline |
| `public/icons/icon-{16,32,180,192,512}.png` | Standard PWA icons |
| `public/icons/icon-maskable-{192,512}.png` | Maskable icons (Android adaptive) |
| `public/icons/icon-source.svg` | Source SVG (editable) |
| `app/javascript/controllers/service_worker_controller.js` | SW registration |
| `app/javascript/controllers/pwa_install_controller.js` | Install prompt banner |
| `app/views/shared/_pwa_head.html.erb` | Meta tags partial |
| `app/views/shared/_pwa_install_prompt.html.erb` | Install banner UI |

### Layouts updated
- `app/views/layouts/application.html.erb` (root + auth)
- `app/views/layouts/customer.html.erb`
- `app/views/layouts/vendor.html.erb`
- `app/views/layouts/admin.html.erb`

All four now include:
- `data-controller="service-worker"` on `<body>` → registers the SW once
- `link rel="manifest"` and theme-color/apple-mobile-web-app meta tags
- The slide-up install banner at end of body

---

## How to test

### 1. Local dev (HTTPS recommended)
PWA features (install prompt, service workers) need a secure context.
- `https://localhost:3000` works in most browsers
- `ngrok` or `cloudflared` tunnels can give you a public HTTPS URL
- Plain `http://127.0.0.1:3000` works for service workers on localhost in Chrome

```bash
bin/rails server
# Then visit http://localhost:3000 in Chrome
```

### 2. Verify in DevTools
1. Open Chrome DevTools → **Application** tab
2. **Manifest** panel — should show:
   - Name: Puroxa Water
   - Start URL: /
   - Theme color: #0d2c63
   - Icons: 4 (192, 512, maskable-192, maskable-512)
3. **Service Workers** panel — should show:
   - `service-worker.js` — Status: activated, running
4. **Storage → Cache Storage** — should show:
   - `puroxa-static-v1` and `puroxa-runtime-v1`
5. **Lighthouse** → Run "Progressive Web App" audit — should pass

### 3. Test offline mode
1. Visit a few pages (they get cached)
2. DevTools → **Network** tab → throttling dropdown → **Offline**
3. Try to navigate — pages that were cached load instantly
4. New pages show the styled `/offline.html` page

### 4. Test install prompt
On Android (Chrome) or desktop (Chrome/Edge):
1. Visit the site
2. Wait ~30s — install banner slides up at the bottom
3. Click **Install** → native install dialog appears
4. Click **Not now** → banner dismissed (won't reappear for 14 days)

On iOS (Safari) — no `beforeinstallprompt` event, so:
- Tap the **Share** button → **Add to Home Screen**
- The Puroxa icon + name appear on the home screen

### 5. Test on real mobile
1. Deploy to Render (`git push origin main`)
2. Visit the public URL on your phone
3. Android Chrome: banner should auto-appear
4. iOS Safari: use Share → Add to Home Screen

---

## Caching strategy

| Resource type | Strategy | Why |
|---|---|---|
| HTML navigations | Network-first → cache → offline page | Always show fresh content when online |
| JS/CSS/images/fonts | Cache-first (revalidate in background) | Fast repeat loads, offline-capable |
| `/login`, `/logout`, `/cable` | Bypass SW | Auth flows must always be live |
| Cross-origin requests | Bypass SW | Avoid CORS / cache weirdness |

---

## Updating the PWA

When you ship a major change, **bump the cache version** in `public/service-worker.js`:

```js
const VERSION = "v2";  // was "v1"
```

This forces the browser to discard old caches and re-fetch everything.

---

## Customizing

### Change theme color
Edit `theme_color` in `public/manifest.json` AND in `app/views/shared/_pwa_head.html.erb`.

### Change the install banner delay
In `_pwa_install_prompt.html.erb`:
```erb
data-pwa-install-delay-ms-value="30000"  <!-- 30s default -->
```

### Change the dismissal period
In `pwa_install_controller.js`:
```js
const DISMISS_DAYS = 14  // 14 days default
```

### Replace the icon
1. Edit `public/icons/icon-source.svg`
2. Re-render with inkscape:
   ```bash
   cd public/icons
   for size in 16 32 180 192 512; do
     inkscape -w $size -h $size icon-source.svg -o "icon-${size}.png"
   done
   for size in 192 512; do
     inkscape -w $size -h $size icon-maskable.svg -o "icon-maskable-${size}.png"
   done
   ```

---

## Deployment notes

- **Render / production**: HTTPS is automatic — full PWA features work
- **Custom domain**: HTTPS required for `beforeinstallprompt` to fire
- **iOS quirks**: PWA install on iOS uses the manual Share → Add to Home Screen flow
  - The `apple-mobile-web-app-capable` meta tag enables fullscreen mode after install
  - The apple-touch-icon must be 180x180 PNG with no transparency — already set

---

## Troubleshooting

**Install banner never shows?**
- Check DevTools console for `[PWA]` log messages
- Manifest must be valid — check Application → Manifest for errors
- Service worker must be activated — check Application → Service Workers
- Make sure you're on HTTPS (or localhost)
- iOS Safari doesn't support `beforeinstallprompt` — use Share button instead

**Offline page not showing?**
- Clear cache: DevTools → Application → Storage → "Clear site data"
- Hard reload (Ctrl+Shift+R) to fetch the new SW
- Verify the offline.html path is correct: `public/offline.html` → `/offline.html`

**Service worker not updating?**
- Bump the `VERSION` constant in `public/service-worker.js`
- Or send a `SKIP_WAITING` message from the client (the controller already listens for this)

---

## Lighthouse checklist (expected pass)

- ✅ Installable (manifest + SW + HTTPS)
- ✅ PWA optimized
- ✅ Registered service worker
- ✅ Manifest with icons (192 + 512 + maskable)
- ✅ Splash screen with background color
- ✅ Theme color set
- ✅ Apple touch icon
- ✅ Offline support
- ✅ Viewport meta tag
- ✅ Address bar theme color
