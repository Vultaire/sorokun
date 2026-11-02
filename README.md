> **Modified fork notice — 2026-11-01:** This is a modified version of Sorokun maintained by Vultaire at <https://github.com/Vultaire/sorokun>. The original project is by Chet Lin. This fork removes yomiagezan and VOICEVOX and adds web-build support. It remains licensed under GPL-3.0; see `LICENSE.txt`.

## そろくん！

そろくん！は、そろばんや暗算を練習したい人向けにDart/Flutterで開発されたアプリです。総合種目とフラッシュ暗算の2つのモードを提供しています。

# 総合種目

珠算の大会や検定で出題される基本種目——みとり算・かけ算・わり算と、それぞれの暗算種目——を、自分のレベルに合わせて出題します。解答はアプリ内で直接記入できます。練習モードでは、答えが合っているか間違っているか、その場ですぐに分かります。検定モードでは時間制限が設けられ、提出するまで成否を確認することはできません。出題は全珠連式・日珠連式それぞれの級位に対応しています。

# フラッシュ暗算

画面に次々と表示される数字を暗算でひたすら足していくトレーニングです。級位に沿って挑戦する検定モードと、口数・桁数・表示時間を自由に設定できるフリーモードの2種類を用意しています。検定モードは全珠連式・日本フラッシュ暗算協会式のそれぞれの級位に対応しています。

## Build and self-host the web app

Install Flutter (the fork is built with Flutter 3.47.9 / Dart 3.13.7), then run these commands from the repository root:

```sh
flutter pub get
flutter analyze
flutter test
flutter build web --release --base-href /
```

The static site is written to `build/web/`. Copy the **contents** of that directory to the web server's document root to serve the app at `https://vultaire.net/`.

If you want to serve it from a subdirectory such as `https://vultaire.net/sorokun/`, build with a matching base href instead:

```sh
flutter build web --release --base-href /sorokun/
```

Then copy the contents of `build/web/` into the server's `/sorokun/` directory. The base href must match the public path, including the trailing slash.

### Static-host configuration

Configure the server to:

1. Serve static files normally and return `.wasm` files with the `application/wasm` MIME type.
2. The app currently uses hash-based GoRouter URLs (for example, `/#/home`), so refreshing an app route requests the root document and does not require an SPA route rewrite. If you later switch to path-based URLs, configure the static host to return `index.html` for unknown app paths. For Nginx at the domain root, the usual rule is `try_files $uri $uri/ /index.html;`; for a subdirectory, use that subdirectory's `index.html` as the fallback.
3. Serve the site over HTTPS for public use.

The current SoLoud web plugin version bundles its WebAssembly support and does not require cross-origin-isolation headers. The app's Credits page links to this fork and its GPLv3 license; keep that source link available when publishing the compiled site.

Browsers restrict autoplay: sound effects become available after the visitor's first click or touch interaction.

For a quick local static preview after building, run `python3 -m http.server 8000 --directory build/web` and open `http://localhost:8000/`. This simple server does not configure SPA route fallbacks, so use the production server's fallback rule when testing deep links or page refreshes.
