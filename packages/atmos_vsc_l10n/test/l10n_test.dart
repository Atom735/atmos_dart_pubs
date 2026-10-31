import 'dart:io';

import 'package:atmos_vsc_l10n/atmos_vsc_l10n.dart';
import 'package:atmos_vsc_l10n/atmos_vsc_l10n_io.dart';
import 'package:test/test.dart';

void main() {
  group('VscLocale', () {
    test('fallback chain', () {
      expect(
        VscLocale('ru-RU').fallbackChain.map((e) => e.tag).toList(),
        ['ru-ru', 'ru', ''],
      );
      expect(VscLocale('en').isDefault, isTrue);
      expect(VscLocale.pseudo.isPseudo, isTrue);
      expect(
        VscLocale('ru').packageNlsFileName(),
        'package.nls.ru.json',
      );
    });
  });

  group('format', () {
    test('indexed and named placeholders', () {
      expect(
        vscFormatMessage('A {0} B {1}', indexed: ['x', 'y']),
        'A x B y',
      );
      expect(
        vscFormatMessage('Hi {name}', named: {'name': 'Ada'}),
        'Hi Ada',
      );
      expect(
        vscL10nBundleKey('Hello {0}', ['c1', 'c2']),
        'Hello {0}/c1c2',
      );
      expect(vscPseudoLocalize('Hi'), '[Hii]');
    });
  });

  group('VscNls', () {
    late VscNlsBundle bundle;

    setUp(() {
      bundle = VscNlsBundle(
        defaults: VscNlsLoader.parseTable('''
        {
          "ext.hello.title": "Hello",
          "ext.hello.cat": "Demo"
        }
        '''),
      )..addTable(
          VscNlsLoader.parseTable(
            '{ "ext.hello.title": "Привет" }',
            locale: VscLocale('ru'),
          ),
        );
    });

    test('resolveString splits value/original', () {
      final s = VscNls.resolveString(
        '%ext.hello.title%',
        bundle: bundle,
        locale: VscLocale('ru'),
      );
      expect(s.value, 'Привет');
      expect(s.original, 'Hello');
    });

    test('resolveJsonDetailed reports unresolved', () {
      final result = VscNls.resolveJsonDetailed(
        {'title': '%missing.key%', 'ok': '%ext.hello.cat%'},
        bundle: bundle,
      );
      expect(result.unresolvedKeys, ['missing.key']);
      final map = result.json! as Map;
      expect(map['ok'], 'Demo');
    });
  });

  group('VscL10n', () {
    test('comment-aware key and named args', () {
      final bundle = VscNlsBundle(
        defaults: VscNlsLoader.parseTableDecoded({
          'Hello {0}/who': {
            'message': 'Hello {0}',
            'comment': ['who'],
          },
          'Hi {name}': 'Hi {name}',
        }),
      )..addTable(
          VscNlsTable(
            const {
              'Hello {0}/who': 'Bonjour {0}',
              'Hi {name}': 'Salut {name}',
            },
            locale: VscLocale('fr'),
          ),
        );

      final l10n = VscL10n(bundle: bundle, locale: VscLocale('fr'));
      expect(
        l10n.t('Hello {0}', args: ['Ada'], comment: ['who']),
        'Bonjour Ada',
      );
      expect(l10n.tNamed('Hi {name}', {'name': 'Ada'}), 'Salut Ada');
      expect(
        l10n.tMessage(
          const VscL10nMessage(
            message: 'Hello {0}',
            args: ['Ada'],
            comment: ['who'],
          ),
        ),
        'Bonjour Ada',
      );
    });

    test('pseudo locale and listeners', () {
      final l10n = VscL10n(
        bundle: VscNlsBundle(
          defaults: const VscNlsTable({'Hi': 'Hi'}),
        ),
      );
      var ticks = 0;
      l10n.addListener(() => ticks++);
      l10n.locale = VscLocale.pseudo;
      expect(ticks, 1);
      expect(l10n.t('Hi'), '[Hii]');
    });

    test('trackMissing', () {
      final l10n = VscL10n(
        bundle: VscNlsBundle(),
        locale: VscLocale('ru'),
      )..trackMissing = true;
      expect(l10n.t('Nope'), 'Nope');
      expect(l10n.missingLookups, contains('Nope'));
    });
  });

  group('bundle merge / missingKeys', () {
    test('merge and missingKeys', () {
      final a = VscNlsBundle(
        defaults: const VscNlsTable({'a': 'A', 'b': 'B'}),
      );
      final b = VscNlsBundle()
        ..addTable(
          VscNlsTable(const {'a': 'А'}, locale: VscLocale('ru')),
        );
      a.merge(b);
      expect(a.lookup('a', locale: VscLocale('ru')), 'А');
      expect(a.missingKeys(VscLocale('ru')), ['b']);
    });
  });

  group('VscNlsFileLoader', () {
    test('loadPackageNls and loadAllPackageNls', () {
      final dir = Directory.systemTemp.createTempSync('atmos_vsc_l10n_');
      addTearDown(() => dir.deleteSync(recursive: true));

      File('${dir.path}${Platform.pathSeparator}package.nls.json')
          .writeAsStringSync('{"a.b": "EN"}');
      File('${dir.path}${Platform.pathSeparator}package.nls.ru.json')
          .writeAsStringSync('{"a.b": "RU"}');
      File('${dir.path}${Platform.pathSeparator}package.nls.de.json')
          .writeAsStringSync('{"a.b": "DE"}');

      final one = VscNlsFileLoader.loadPackageNls(
        dir,
        locale: VscLocale('ru'),
      );
      expect(one.lookup('a.b', locale: VscLocale('ru')), 'RU');

      final all = VscNlsFileLoader.loadAllPackageNls(dir);
      expect(all.lookup('a.b', locale: VscLocale('de')), 'DE');
      expect(
        all.tables.keys.map((e) => e.tag).toSet(),
        containsAll(['', 'ru', 'de']),
      );
    });
  });

  group('VscLocalizedString', () {
    test('fromJson pair', () {
      final s = VscLocalizedString.fromJson({
        'value': 'Привет',
        'original': 'Hello',
      });
      expect(s.text, 'Привет');
      expect(s.toJson(), {
        'value': 'Привет',
        'original': 'Hello',
      });
    });
  });
}
