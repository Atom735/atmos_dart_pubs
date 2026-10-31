import 'dart:io';

import 'package:atmos_vsc_codicon_flutter/atmos_vsc_codicon_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('add matches the Codicon private-use code point', () {
    expect(VscCodicons.add.codePoint, 0xEA60);
    expect(VscCodicons.plus.codePoint, VscCodicons.add.codePoint);
    expect(VscCodicons.fontFamily, 'codicon');
    expect(VscCodicons.fontPackage, 'atmos_vsc_codicon_flutter');
  });

  test('catalog lists every id once', () {
    expect(VscCodiconCatalog.all, hasLength(VscCodiconCatalog.iconCount));
    expect(VscCodiconCatalog.byId, hasLength(VscCodiconCatalog.iconCount));
    expect(
      VscCodiconCatalog.codepointCount,
      lessThan(VscCodiconCatalog.iconCount),
    );

    final ids = <String>{};
    final codepoints = <int>{};
    for (final info in VscCodiconCatalog.all) {
      expect(ids.add(info.id), isTrue, reason: info.id);
      codepoints.add(info.codePoint);
      expect(VscCodiconCatalog.byId[info.id], same(info.icon));
      expect(info.icon.fontFamily, 'codicon');
      expect(info.icon.fontPackage, 'atmos_vsc_codicon_flutter');
    }
    expect(codepoints, hasLength(VscCodiconCatalog.codepointCount));
  });

  test('resolve accepts product-icon syntax', () {
    expect(
      VscCodiconCatalog.resolve(r'$(git-pull-request)'),
      VscCodicons.gitPullRequest,
    );
    expect(
      VscCodiconCatalog.resolve('codicon-search'),
      VscCodicons.search,
    );
    expect(
      VscCodiconCatalog.resolve('gitPullRequest'),
      VscCodicons.gitPullRequest,
    );
    expect(VscCodiconCatalog.resolve('  book  '), VscCodicons.book);
    expect(VscCodiconCatalog.resolve(''), isNull);
    expect(VscCodiconCatalog.resolve(r'$()'), isNull);
    expect(VscCodiconCatalog.resolve('missing-icon'), isNull);
  });

  test('find returns the catalog row', () {
    final plus = VscCodiconCatalog.find(r'$(plus)');
    expect(plus?.id, 'plus');
    expect(plus?.dartName, 'plus');
    expect(plus?.primary, isFalse);

    final request = VscCodiconCatalog.find('gitPullRequest');
    expect(request?.id, 'git-pull-request');
    expect(request?.dartName, 'gitPullRequest');

    expect(VscCodiconCatalog.find('missing-icon'), isNull);
    expect(
      VscCodiconCatalog.namesFor(VscCodicons.add.codePoint).map((e) => e.id),
      containsAll(['add', 'plus']),
    );
    expect(
      VscCodiconCatalog.categoryByCodePoint[VscCodicons.add.codePoint],
      'action',
    );
    expect(VscCodiconCatalog.categories, contains('action'));
  });

  test('first alias of a code point is primary', () {
    expect(
      VscCodiconCatalog.all.firstWhere((info) => info.id == 'add').primary,
      isTrue,
    );
    expect(
      VscCodiconCatalog.all.firstWhere((info) => info.id == 'plus').primary,
      isFalse,
    );
  });

  test('bundled font is a TrueType file', () {
    final bytes = File('assets/codicon.ttf').readAsBytesSync();
    expect(bytes.length, greaterThan(1000));
    expect(bytes.sublist(0, 4), [0x00, 0x01, 0x00, 0x00]);
  });

  testWidgets('VscCodicon builds without Material', (tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: VscCodicon(VscCodicons.search, semanticLabel: 'Search'),
      ),
    );
    expect(find.byType(VscCodicon), findsOneWidget);
    expect(find.bySemanticsLabel('Search'), findsOneWidget);
  });

  testWidgets('fromRef resolves a product-icon token', (tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: VscCodicon.fromRef(r'$(book)'),
      ),
    );
    final icon = tester.widget<VscCodicon>(find.byType(VscCodicon));
    expect(icon.icon, VscCodicons.book);
    expect(icon.semanticLabel, 'book');
  });

  testWidgets('fromRef keeps space for an unknown id', (tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: VscCodicon.fromRef('missing-icon', size: 16),
      ),
    );
    expect(find.byType(SizedBox), findsOneWidget);
    final icon = tester.widget<VscCodicon>(find.byType(VscCodicon));
    expect(icon.icon, isNull);
  });
}
