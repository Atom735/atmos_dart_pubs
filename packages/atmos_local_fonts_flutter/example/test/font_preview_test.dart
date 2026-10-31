import 'dart:typed_data';

import 'package:atmos_local_fonts/atmos_local_fonts.dart';
import 'package:atmos_local_fonts_flutter_example/font_preview_app.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Future<Uint8List> _byte() async => Uint8List.fromList(<int>[0]);

LocalFontFace _face(String family, String postscriptName) {
  return LocalFontFace(
    family: family,
    fullName: family,
    postscriptName: postscriptName,
    style: 'Regular',
    readBytes: _byte,
  );
}

void main() {
  testWidgets('loads families and previews the selected font', (tester) async {
    await tester.pumpWidget(
      FontPreviewApp(
        source: MemoryLocalFontSource(<LocalFontFace>[
          _face('Arial', 'ArialMT'),
          _face('Georgia', 'Georgia'),
        ]),
        loadFiles: (String family, List<Uint8List> files) async {},
      ),
    );

    expect(find.text('Lorem'), findsOneWidget);
    expect(find.textContaining('Lorem ipsum'), findsWidgets);
    expect(find.text('Загрузить список'), findsOneWidget);

    await tester.tap(find.byKey(const Key('load-fonts')));
    await tester.pumpAndSettle();

    expect(find.text('Arial'), findsOneWidget);
    expect(find.text('Georgia'), findsOneWidget);
    expect(find.text('Обновить список'), findsOneWidget);

    await tester.tap(find.byKey(const Key('family-Arial')));
    await tester.pumpAndSettle();

    final preview = tester.widget<Text>(find.byKey(const Key('font-preview')));
    expect(preview.style?.fontFamily, 'Arial');
    expect(find.textContaining('Arial · Regular'), findsOneWidget);

    await tester.tap(find.text('Панграмма'));
    await tester.pump();

    expect(find.textContaining('Съешь ещё'), findsWidgets);
    expect(
      tester.widget<Text>(find.byKey(const Key('font-preview'))).data,
      contains('французских булок'),
    );

    await tester.tap(find.text('Жирный'));
    await tester.pump();
    final bold = tester.widget<Text>(find.byKey(const Key('font-preview')));
    expect(bold.style?.fontWeight, FontWeight.w700);

    await tester.enterText(find.byKey(const Key('font-filter')), 'geo');
    await tester.pump();

    expect(find.byKey(const Key('family-Arial')), findsNothing);
    expect(find.byKey(const Key('family-Georgia')), findsOneWidget);
  });
}
