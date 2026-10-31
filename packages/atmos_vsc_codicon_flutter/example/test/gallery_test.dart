import 'package:atmos_vsc_codicon_flutter_example/codicon_gallery.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('gallery shows the codicon set', (tester) async {
    await tester.pumpWidget(const CodiconGalleryApp());
    expect(find.text('Codicons'), findsOneWidget);
    expect(find.text('search'), findsWidgets);
    expect(find.byType(CodiconGallery), findsOneWidget);
  });

  testWidgets('search and category filter the grid', (tester) async {
    await tester.pumpWidget(const CodiconGalleryApp());
    await tester.enterText(find.byType(EditableText), 'lightbulb');
    await tester.pump();
    expect(find.text('lightbulb'), findsWidgets);
    expect(find.text('add'), findsNothing);

    await tester.enterText(find.byType(EditableText), '');
    await tester.pump();
    await tester.tap(find.text('debug'));
    await tester.pump();
    expect(find.text('add'), findsNothing);
    expect(find.text('activate-breakpoints'), findsWidgets);
  });
}
