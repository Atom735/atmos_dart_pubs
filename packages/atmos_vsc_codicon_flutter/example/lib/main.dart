import 'package:flutter/widgets.dart';

import 'codicon_gallery.dart';

/// Codicon gallery (WidgetsApp, no Material).
///
/// Галерея Codicon (WidgetsApp, без Material).
///
/// ```bash
/// cd packages/atmos_vsc_codicon_flutter/example
/// flutter run -d chrome
/// ```
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CodiconGalleryApp());
}
