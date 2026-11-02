> **Machine-generated translation notice:** This file is an English translation of the original Japanese [`README.md`](README.md). If the two versions differ, the Japanese README is authoritative.
>
> **Modified fork notice — 2026-11-01:** This is a modified version of Sorokun maintained by Vultaire at <https://github.com/Vultaire/sorokun>. The original project is by Chet Lin. This fork removes yomiagezan (spoken arithmetic) and VOICEVOX and adds web-build support. It remains licensed under GNU GPL v3.0; see `LICENSE.txt`.

## Sorokun!

Sorokun! is a Dart/Flutter app for practicing soroban and mental arithmetic. It provides two modes: comprehensive subjects and flash mental arithmetic.

## Comprehensive subjects

Practice core soroban competition and examination subjects—mitori-zan, multiplication, division, and their corresponding mental-arithmetic exercises—at a level suited to you. Answers are entered directly in the app. In practice mode, you see immediately whether an answer is correct. In examination mode, there is a time limit and results are hidden until you submit. Problems follow the grade systems of Zenshuren and Nisshuren.

## Flash mental arithmetic

Practice addition by calculating numbers that appear rapidly on screen. Choose examination mode, which follows the applicable grade system, or free mode, where you can set the number of numbers, digit range, and display time. Examination grades follow both the Zenshuren and Japan Flash Anzan Association systems.

## Build and self-host the web app

Install the Flutter SDK (this fork was built with Flutter 3.47.9 / Dart 3.13.7), then run these commands from the repository root:

```sh
flutter pub get
flutter analyze
flutter test
flutter build web --release --base-href /
```

The static site is generated in `build/web/`. To serve the app at `https://example.com/`, copy the **contents** of that directory to your web server's document root.

To serve the app from a subdirectory such as `https://example.com/sorokun/`, build with a matching base href:

```sh
flutter build web --release --base-href /sorokun/
```

Then copy the contents of `build/web/` into the server's `/sorokun/` directory. The `--base-href` must match the public path, including the trailing slash.

### Static web server configuration

The app currently uses hash-based GoRouter URLs (for example, `/#/home`), so refreshing an app route does not require an SPA fallback. If you later switch to path-based URLs, configure the host to return `index.html` for unknown app paths. For Nginx at the domain root, a typical rule is `try_files $uri $uri/ /index.html;`; for a subdirectory, use that subdirectory's `index.html` as the fallback.

Make sure the server:

1. Serves static files normally and uses the `application/wasm` MIME type for `.wasm` files.
2. Serves the public site over HTTPS.

The current SoLoud web plugin bundles its WebAssembly support and does not require cross-origin-isolation headers. The app's Credits page links to this fork's source and GPL v3.0 license; keep that source link available when publishing the compiled app.

Browsers restrict autoplay: sound effects become available after the visitor's first click or touch interaction.

For a quick local preview after building, run `python3 -m http.server 8000 --directory build/web` and open `http://localhost:8000/`. This simple server does not configure SPA fallbacks, so use the production server's fallback rule if testing deep links or page refreshes with path-based URLs.
