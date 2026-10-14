# Google Play Console — Production Upload Notes
App: **AUSC Alumni** · Package: `com.ausc.alumni` · Prepared: 2026-10-07

---

## 1. Current build state (verified)

| Item | Value | Status |
|---|---|---|
| `pubspec.yaml` version | `1.0.0+4` | versionCode **4** |
| applicationId / namespace | `com.ausc.alumni` | OK |
| `android:label` | `AUSC Alumni` | OK |
| compileSdk / targetSdk | 36 / 36 | OK (Play requires 35+) |
| minSdk | 24 | OK |
| ABIs | armeabi-v7a, arm64-v8a, x86_64 | 64-bit present, OK |
| R8 minify + shrink | enabled | OK |
| Language split | disabled (ships all strings) | OK |
| Release signing | `android/key.properties` → `upload-keystore.jks`, alias `upload` | OK, key valid to 2054 |
| Built artifact | `build/app/outputs/bundle/release/app-release.aab` (61.2 MB, signed) | OK |
| Permissions in manifest | `INTERNET` only | OK (no media perms — good for photo/video policy) |
| `.env` in bundle | `SUPABASE_URL` + `SUPABASE_ANON_KEY` only | OK (anon key is public by design) |
| CI build | `.github/workflows/release.yml` builds + uploads artifact on `v*` tags | Needs secrets configured |

---

## 2. Blockers to fix before upload

### B1. Bump `versionCode`
Play rejects any upload whose `versionCode` is not strictly greater than the highest
already published. Current is `+4`.

```yaml
# pubspec.yaml
version: 1.0.0+5
```

Also note `android/local.properties` has a stale `flutter.versionCode=1`; that file is
gitignored and overridden by `--build-number`, so it is harmless — but do not let it
confuse you during upload.

### B2. Host the Privacy Policy on a public URL
`docs/index.html` is the privacy policy and `docs/delete-account.html` is the account
deletion page. Play requires **both** to be reachable over public HTTPS. There is no
deploy workflow for `docs/` yet — `.nojekyll` is present so GitHub Pages is the intended
target.

```powershell
# one-time: serve docs/ from the gh-pages branch, or add a workflow
# simplest: Settings > Pages > Deploy from a branch > main /docs
```
Resulting URLs (fill in after publishing):
- Privacy policy: `https://<user>.github.io/AUSC-ALUMNi-ASSOCIATION/`
- Account deletion: `https://<user>.github.io/AUSC-ALUMNi-ASSOCIATION/delete-account.html`

### B3. Add an in-app link to Privacy Policy + Account Deletion
Play's Account Deletion policy requires a web URL *or* an in-app path, and reviewers
check for it. The app has a `/signup` route (`auth_provider.dart` `signUp`), so account
deletion is mandatory. Add both entries to `SettingsScreen` next to the existing
"About the school" tile (`lib/presentation/screens/settings/settings_screen.dart:131`),
launching with `url_launcher` in `LaunchMode.externalApplication`:

```dart
final privacyUri = Uri.parse('https://<user>.github.io/AUSC-ALUMNi-ASSOCIATION/');
final deleteUri  = Uri.parse('https://<user>.github.io/AUSC-ALUMNi-ASSOCIATION/delete-account.html');
```

### B4. Configure GitHub secrets for `release.yml`
The workflow hard-fails without these four:

| Secret | Value |
|---|---|
| `KEYSTORE_BASE64` | `base64 -w0 upload-keystore.jks` (PowerShell: `[Convert]::ToBase64String([IO.File]::ReadAllBytes("upload-keystore.jks"))`) |
| `KEYSTORE_PASSWORD` | matches `key.properties` `storePassword` |
| `KEY_PASSWORD` | matches `key.properties` `keyPassword` |
| `KEY_ALIAS` | `upload` |
| `ENV_FILE` | full contents of `.env` |

Note the CI writes the keystore to `android/app/upload-keystore.jks` with
`storeFile=upload-keystore.jks` because `storeFile` resolves relative to the app module;
your local `key.properties` uses `../../upload-keystore.jks` for the repo-root copy.
Both are correct — don't unify them, the CI value is intentional.

---

## 3. Recommended build command

```powershell
flutter clean
flutter pub get
flutter analyze                 # must be clean
flutter build appbundle --release `
  --build-number=5 `
  --obfuscate `
  --split-debug-info=build/symbols
```

Why:
- `--obfuscate` + `--split-debug-info` keeps `app.aab.map.json` out of the upload and
  lets you de-obfuscate crash reports later. The current AAB ships a **8.95 MB**
  `proguard.map` inside `BUNDLE-METADATA`.
- Without `--split-debug-info`, the AAB also carries **~48 MB of `.sym` files** for the
  three ABIs. Play discards them, so a plain `flutter build appbundle --release`
  (61 MB) uploads far more than it needs to.

Optional size trim (not required): drop `x86_64` from
`abiFilters` in `android/app/build.gradle.kts:46` and `armeabi-v7a` if you no longer
support older 32-bit devices. Play only requires `arm64-v8a`.

Signed local build also works via
`flutter build appbundle --release`, which reads `android/key.properties` automatically.

---

## 4. Store listing assets you still need to produce

| Asset | Spec |
|---|---|
| App icon | 512 × 512 PNG, 32-bit, no alpha, no rounded corners. `assets/images/logo.png` is the source. |
| Feature graphic | 1024 × 500 PNG/JPG |
| Phone screenshots | min 2, 16:9 or 9:16, 320–3840 px per side. Suggested: Home (alumni list), School, Photo Gallery, Settings. `assets/images/banners/` has usable shots. |
| Short description | ≤ 80 chars |
| Full description | ≤ 4000 chars |

Short description draft:
> The official directory and community app for AUSC alumni. Find batchmates, teachers and campus photos.

---

## 5. Console forms — answers to expect

**App category:** Education (or Social). **Contains ads:** No.

**Content rating questionnaire:** expect *Everyone* provided there is no violence,
gambling, profanity or user-generated chat. If alumni can post photos that contain
recognisable people, tick the "user-generated content / sharing" box — it changes the
rating but is still publishable.

**Data safety** — declare all of the following (mirrors `docs/index.html` §2):

| Data type | Collected | Shared | Purpose | Optional? |
|---|---|---|---|---|
| Phone number | Yes | No | App functionality, Account management | Required for sign-in |
| Name | Yes | Yes (with other signed-in members) | App functionality | Yes |
| Photos / videos | Yes | Yes (gallery is visible to members) | App functionality | Yes |
| Address (current + permanent) | Yes | Yes | App functionality | Yes |
| Blood group | Yes | Yes | App functionality | Yes |
| Occupation / designation / batch year | Yes | Yes | App functionality | No |
| Password | Yes (hashed by Supabase Auth, never leaves it) | No | Account management | Required |

Also declare: data is **not** encrypted in transit beyond standard HTTPS (it is HTTPS,
so mark "Encrypted in transit"), and **not** deleted on uninstall — which is exactly
why the account-deletion page exists.

**Target audience & content:** 18+ unless you want under-13s. Selecting an age band
below 13 pulls in Families Policy requirements you almost certainly do not want for an
alumni directory. Pick **18 and over** if in doubt.

**Government / financial / health apps:** all No.

**Ads:** No. **App access:** if any screen requires sign-in, provide reviewer
instructions plus a test account. Note `/add-alumni` is behind `_protectedPaths` in
`lib/core/router.dart:123`; every other tab is public, so reviewers can browse without
credentials.

**Privacy policy:** URL from B2. Must be non-redirecting, HTTPS, and reachable without
a login.

---

## 6. Pre-flight smoke test on the release AAB

```powershell
# install the release build (not debug) on a device or emulator
adb install -r build\app\outputs\bundle\release\*.apk   # or use `flutter install --release`

flutter build apk --release   # quick sideload APK if you don't want bundletool
```

Check, in this order:
1. App launches to Home with the splash screen not sticking (dark splash, `Theme.Black.NoTitleBar`).
2. Alumni list loads from Supabase — if it hangs or shows "Connection Error", the `.env` did not get baked in.
3. R8 did not strip anything: test the image picker (camera/gallery), share sheet, phone/SMS deep links (`alumni_detail_screen.dart:41`), external browser links, and cached images after restart.
4. Sign-up with a phone number works end to end.
5. Font rendering: `google_fonts` fetches Plus Jakarta Sans over the network at runtime. First launch offline shows fallback fonts. Acceptable, but if you want deterministic rendering, bundle the `.ttf` under `assets/fonts/` and set `GoogleFonts.config.allowRuntimeFetching = false` in `lib/core/theme/app_theme.dart`.

---

## 7. Optional cleanups (safe to defer)

- `test.html`, `test-supabase.html`, `temp.txt` at repo root — scratch files. `temp.txt`
  is gitignored; the two HTML files are tracked. Delete them.
- `/test-connection` route (`lib/core/router.dart:192`) is reachable in the production
  build. It exposes no secrets, but consider guarding it behind `kDebugMode` before
  public launch.
- `local.properties` holds `flutter.buildMode=debug`; harmless, but it will make
  Android Studio default to debug builds.
- `android/key.properties` uses a weak, guessable password. Fine for a local file that
  is gitignored, but set strong distinct values in the GitHub secrets, and keep an
  offline backup of `upload-keystore.jks` — losing it means losing the ability to ship
  updates to an existing Play listing without a key reset request to Google.

---

## 8. Release notes (paste into the console)

```
First release of the AUSC Alumni Association app.

• Browse and search the alumni directory by name, batch or occupation
• View alumni profiles with photo, contact and batch details
• Tap to call or message an alumnus directly
• School information: campus, departments and contact details
• Teacher directory with profile links
• Campus photo gallery with full-screen viewing
• Sign in with your mobile number to add or edit directory entries
• Dark theme throughout, sized for accessibility
```