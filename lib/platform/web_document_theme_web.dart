import 'dart:js_interop';

@JS('sorokunSetDocumentTheme')
external void _setDocumentTheme(JSString brightness, JSString backgroundColor);

void synchronizeDocumentTheme({
  required String brightness,
  required String backgroundColor,
}) {
  _setDocumentTheme(brightness.toJS, backgroundColor.toJS);
}
