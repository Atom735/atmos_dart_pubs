import 'package:flutter/widgets.dart';

import 'font_preview_app.dart';

/// System-font preview for Chrome and Edge.
///
/// Просмотр системных шрифтов в Chrome и Edge.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FontPreviewApp());
}
