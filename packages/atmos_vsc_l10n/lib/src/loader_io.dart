import 'dart:io';

import 'bundle.dart';
import 'loader.dart';
import 'locale.dart';

final _packageNls = RegExp(r'^(.+)\.nls(?:\.([^.]+))?\.json$');
final _bundleL10n = RegExp(r'^(.+)\.l10n(?:\.([^.]+))?\.json$');

/// Filesystem loaders for NLS / l10n tables (`dart:io`).
///
/// ## ENG
/// Import `package:atmos_vsc_l10n/atmos_vsc_l10n_io.dart` on VM / desktop.
///
/// ## RU
/// Импортируйте `atmos_vsc_l10n_io.dart` на VM / desktop.
abstract final class VscNlsFileLoader {
  /// Loads a table from [file].
  static VscNlsTable loadTableFile(
    File file, {
    VscLocale locale = VscLocale.defaultLocale,
  }) =>
      VscNlsLoader.parseTable(file.readAsStringSync(), locale: locale);

  /// Loads a table from [path].
  static VscNlsTable loadTablePath(
    String path, {
    VscLocale locale = VscLocale.defaultLocale,
  }) =>
      loadTableFile(File(path), locale: locale);

  /// Loads `package.nls.json` and locale overlays for [locale]'s chain.
  static VscNlsBundle loadPackageNls(
    Directory directory, {
    VscLocale locale = VscLocale.defaultLocale,
    String baseName = 'package',
  }) {
    final bundle = VscNlsBundle();
    final locales = <VscLocale>{
      VscLocale.defaultLocale,
      ...locale.fallbackChain,
    };
    for (final step in locales) {
      if (step.isPseudo) continue;
      final name = step.packageNlsFileName(baseName: baseName);
      final file = File('${directory.path}${Platform.pathSeparator}$name');
      if (!file.existsSync()) continue;
      bundle.addTable(loadTableFile(file, locale: step));
    }
    return bundle;
  }

  /// Loads every `*.nls.json` / `*.nls.<locale>.json` under [directory].
  static VscNlsBundle loadAllPackageNls(
    Directory directory, {
    String baseName = 'package',
  }) {
    final bundle = VscNlsBundle();
    if (!directory.existsSync()) return bundle;
    for (final entity in directory.listSync()) {
      if (entity is! File) continue;
      final name = entity.uri.pathSegments.isEmpty
          ? entity.path.split(Platform.pathSeparator).last
          : entity.uri.pathSegments.last;
      final match = _packageNls.firstMatch(name);
      if (match == null || match.group(1) != baseName) continue;
      final tag = match.group(2);
      final locale =
          tag == null ? VscLocale.defaultLocale : VscLocale(tag);
      bundle.addTable(loadTableFile(entity, locale: locale));
    }
    return bundle;
  }

  /// Loads `bundle.l10n*.json` for [locale]'s fallback chain.
  static VscNlsBundle loadBundleL10n(
    Directory directory, {
    VscLocale locale = VscLocale.defaultLocale,
    String baseName = 'bundle',
  }) {
    final bundle = VscNlsBundle();
    final locales = <VscLocale>{
      VscLocale.defaultLocale,
      ...locale.fallbackChain,
    };
    for (final step in locales) {
      if (step.isPseudo) continue;
      final name = step.bundleL10nFileName(baseName: baseName);
      final file = File('${directory.path}${Platform.pathSeparator}$name');
      if (!file.existsSync()) continue;
      bundle.addTable(loadTableFile(file, locale: step));
    }
    return bundle;
  }

  /// Loads every `*.l10n.json` / `*.l10n.<locale>.json` under [directory].
  static VscNlsBundle loadAllBundleL10n(
    Directory directory, {
    String baseName = 'bundle',
  }) {
    final bundle = VscNlsBundle();
    if (!directory.existsSync()) return bundle;
    for (final entity in directory.listSync()) {
      if (entity is! File) continue;
      final name = entity.uri.pathSegments.isEmpty
          ? entity.path.split(Platform.pathSeparator).last
          : entity.uri.pathSegments.last;
      final match = _bundleL10n.firstMatch(name);
      if (match == null || match.group(1) != baseName) continue;
      final tag = match.group(2);
      final locale =
          tag == null ? VscLocale.defaultLocale : VscLocale(tag);
      bundle.addTable(loadTableFile(entity, locale: locale));
    }
    return bundle;
  }
}
