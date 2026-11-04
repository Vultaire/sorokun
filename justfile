pub-get:
    flutter pub get

analyze:
    flutter analyze

test:
    flutter test

check: pub-get analyze test

build-local:
    flutter build web --release --base-href /

build-production:
    flutter build web --release --base-href /sorokun/
