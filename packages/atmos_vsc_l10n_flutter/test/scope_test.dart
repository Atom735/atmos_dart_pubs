import 'package:atmos_vsc_l10n_flutter/atmos_vsc_l10n_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('VscL10nScope rebuilds on locale change', (tester) async {
    final l10n = VscL10n(
      bundle: VscNlsBundle(
        defaults: const VscNlsTable({'Hi': 'Hi'}),
      )..addTable(
          VscNlsTable(
            const {'Hi': 'Привет'},
            locale: VscLocale('ru'),
          ),
        ),
    );

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: VscL10nScope(
          l10n: l10n,
          child: Builder(
            builder: (context) => Text(VscL10nScope.of(context).t('Hi')),
          ),
        ),
      ),
    );
    expect(find.text('Hi'), findsOneWidget);

    l10n.locale = VscLocale('ru');
    await tester.pump();
    expect(find.text('Привет'), findsOneWidget);
  });

  test('VscNlsAssetLoader parses via AssetBundle', () async {
    final bundle = TestAssetBundle({
      'assets/bundle.l10n.json': '{"Hello": "Hello"}',
      'assets/bundle.l10n.ru.json': '{"Hello": "Привет"}',
    });

    final nls = await VscNlsAssetLoader.loadBundleL10n(
      defaultAsset: 'assets/bundle.l10n.json',
      localeAssets: {
        VscLocale('ru'): 'assets/bundle.l10n.ru.json',
      },
      preferredLocale: VscLocale('ru'),
      bundle: bundle,
    );

    expect(nls.lookup('Hello', locale: VscLocale('ru')), 'Привет');
  });
}

/// Minimal [AssetBundle] for tests.
class TestAssetBundle extends CachingAssetBundle {
  TestAssetBundle(this._assets);

  final Map<String, String> _assets;

  @override
  Future<ByteData> load(String key) async {
    final source = _assets[key];
    if (source == null) {
      throw FlutterError('Unable to load asset: $key');
    }
    final bytes = source.codeUnits;
    final data = ByteData(bytes.length);
    for (var i = 0; i < bytes.length; i++) {
      data.setUint8(i, bytes[i]);
    }
    return data;
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    final source = _assets[key];
    if (source == null) {
      throw FlutterError('Unable to load asset: $key');
    }
    return source;
  }
}
