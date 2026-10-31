import 'package:atmos_vsc_l10n/atmos_vsc_l10n.dart';
import 'package:flutter/services.dart';

/// Loads `package.nls` / `bundle.l10n` JSON from a Flutter [AssetBundle].
///
/// ## ENG
/// Declare asset paths in the **app** (or host package) `pubspec.yaml`.
/// This helper only parses via [VscNlsLoader].
///
/// ## RU
/// Пути ассетов объявляет приложение; здесь только парсинг.
abstract final class VscNlsAssetLoader {
  /// Loads one table from [assetPath].
  static Future<VscNlsTable> loadTable(
    String assetPath, {
    AssetBundle? bundle,
    VscLocale locale = VscLocale.defaultLocale,
  }) async {
    final source = await (bundle ?? rootBundle).loadString(assetPath);
    return VscNlsLoader.parseTable(source, locale: locale);
  }

  /// Loads default + locale overlay tables into a [VscNlsBundle].
  ///
  /// [defaultAsset] is `package.nls.json` / `bundle.l10n.json`.
  /// [localeAssets] maps locales to their asset paths.
  static Future<VscNlsBundle> loadBundle({
    required String defaultAsset,
    Map<VscLocale, String> localeAssets = const {},
    AssetBundle? bundle,
    VscLocale? preferredLocale,
  }) async {
    final assets = bundle ?? rootBundle;
    final out = VscNlsBundle(
      defaults: await loadTable(
        defaultAsset,
        bundle: assets,
      ),
    );

    final locales = <VscLocale>{
      ...localeAssets.keys,
      if (preferredLocale != null) ...preferredLocale.fallbackChain,
    };

    for (final locale in locales) {
      if (locale.isDefault || locale.isPseudo) continue;
      final path = localeAssets[locale];
      if (path == null) continue;
      try {
        out.addTable(
          await loadTable(path, bundle: assets, locale: locale),
        );
      } on Object {
        // Missing optional locale asset — skip.
      }
    }
    return out;
  }

  /// Convenience: load `package.nls` style assets.
  static Future<VscNlsBundle> loadPackageNls({
    required String defaultAsset,
    Map<VscLocale, String> localeAssets = const {},
    AssetBundle? bundle,
    VscLocale? preferredLocale,
  }) =>
      loadBundle(
        defaultAsset: defaultAsset,
        localeAssets: localeAssets,
        bundle: bundle,
        preferredLocale: preferredLocale,
      );

  /// Convenience: load `bundle.l10n` style assets.
  static Future<VscNlsBundle> loadBundleL10n({
    required String defaultAsset,
    Map<VscLocale, String> localeAssets = const {},
    AssetBundle? bundle,
    VscLocale? preferredLocale,
  }) =>
      loadBundle(
        defaultAsset: defaultAsset,
        localeAssets: localeAssets,
        bundle: bundle,
        preferredLocale: preferredLocale,
      );
}
