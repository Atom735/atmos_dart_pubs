import 'package:atmos_vsc_theme/atmos_vsc_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'color_convert.dart';

/// Maps a resolved [VscColorTheme] to Flutter Material theming.
///
/// ## ENG
/// Curated key mapping — not every workbench color has a Material twin.
/// Prefer [toColorScheme] when you only need roles; [toThemeData] fills
/// common widget themes (AppBar, scaffold, input, selection, …).
///
/// ## RU
/// Кураторский маппинг ключей — не у каждого workbench-цвета есть пара
/// в Material. [toColorScheme] для ролей; [toThemeData] — виджеты.
extension VscColorThemeFlutter on VscColorTheme {
  /// Builds a [ColorScheme] from common workbench keys.
  ColorScheme toColorScheme() {
    final brightness = isDark ? Brightness.dark : Brightness.light;
    final fallbackBg =
        isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF);
    final fallbackFg =
        isDark ? const Color(0xFFCCCCCC) : const Color(0xFF333333);

    Color c(String key, [Color? or]) =>
        this[key]?.toFlutterColor() ?? or ?? fallbackFg;

    final surface = c('editor.background', fallbackBg);
    final onSurface = c('editor.foreground', fallbackFg);
    final primary = c(
      'button.background',
      c(
        'focusBorder',
        c('activityBarBadge.background', const Color(0xFF007ACC)),
      ),
    );
    final onPrimary = c('button.foreground', Colors.white);
    final secondary = c(
      'button.secondaryBackground',
      c('sideBar.background', surface),
    );
    final onSecondary = c('button.secondaryForeground', onSurface);
    final error = c(
      'errorForeground',
      c('inputValidation.errorBorder', const Color(0xFFF14C4C)),
    );
    final onError = c('button.foreground', Colors.white);
    final outline = c(
      'panel.border',
      c('contrastBorder', onSurface.withOpacity(0.3)),
    );
    final surfaceVariant = c(
      'sideBar.background',
      c('editorGroupHeader.tabsBackground', surface),
    );
    final onSurfaceVariant = c(
      'sideBar.foreground',
      c('descriptionForeground', onSurface),
    );
    final inverseSurface = c('terminal.ansiWhite', onSurface);
    final onInverseSurface = c('terminal.ansiBlack', surface);
    final inversePrimary = c('textLink.foreground', primary);
    final shadow = c('widget.shadow', Colors.black54);
    final background = c('editor.background', surface);
    final onBackground = onSurface;

    return ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      secondary: secondary,
      onSecondary: onSecondary,
      error: error,
      onError: onError,
      background: background,
      onBackground: onBackground,
      surface: surface,
      onSurface: onSurface,
      surfaceVariant: surfaceVariant,
      onSurfaceVariant: onSurfaceVariant,
      outline: outline,
      shadow: shadow,
      inverseSurface: inverseSurface,
      onInverseSurface: onInverseSurface,
      inversePrimary: inversePrimary,
    );
  }

  /// Builds [ThemeData] around [toColorScheme].
  ThemeData toThemeData({bool useMaterial3 = true}) {
    final scheme = toColorScheme();
    final scaffold = this['editor.background']?.toFlutterColor() ??
        scheme.surface;
    final card = this['sideBar.background']?.toFlutterColor() ??
        this['editorWidget.background']?.toFlutterColor() ??
        scheme.surface;
    final divider = this['panel.border']?.toFlutterColor() ??
        this['editorGroup.border']?.toFlutterColor() ??
        scheme.outline;
    final inputFill = this['input.background']?.toFlutterColor() ??
        this['dropdown.background']?.toFlutterColor();
    final inputBorder = this['input.border']?.toFlutterColor() ??
        this['dropdown.border']?.toFlutterColor() ??
        scheme.outline;
    final hint = this['input.placeholderForeground']?.toFlutterColor() ??
        scheme.onSurfaceVariant;
    final selection = this['editor.selectionBackground']?.toFlutterColor();
    final selectionHandle =
        this['editor.selectionHighlightBackground']?.toFlutterColor() ??
            scheme.primary;
    final cursor = this['editorCursor.foreground']?.toFlutterColor() ??
        scheme.primary;
    final checkboxFill = this['checkbox.background']?.toFlutterColor();
    final checkboxBorder = this['checkbox.border']?.toFlutterColor();
    final snackBg = this['notifications.background']?.toFlutterColor() ?? card;
    final snackFg =
        this['notifications.foreground']?.toFlutterColor() ?? scheme.onSurface;
    final dialogBg = this['editorWidget.background']?.toFlutterColor() ?? card;
    final fabBg =
        this['button.background']?.toFlutterColor() ?? scheme.primary;
    final fabFg =
        this['button.foreground']?.toFlutterColor() ?? scheme.onPrimary;

    return ThemeData(
      useMaterial3: useMaterial3,
      brightness: scheme.brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffold,
      canvasColor: scaffold,
      cardColor: card,
      dividerColor: divider,
      appBarTheme: AppBarTheme(
        backgroundColor: this['titleBar.activeBackground']?.toFlutterColor() ??
            this['editorGroupHeader.tabsBackground']?.toFlutterColor() ??
            scaffold,
        foregroundColor: this['titleBar.activeForeground']?.toFlutterColor() ??
            scheme.onSurface,
        elevation: 0,
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: inputFill != null,
        fillColor: inputFill,
        hintStyle: TextStyle(color: hint),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: this['focusBorder']?.toFlutterColor() ?? scheme.primary,
          ),
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: cursor,
        selectionColor: selection,
        selectionHandleColor: selectionHandle,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: checkboxFill == null
            ? null
            : MaterialStateProperty.resolveWith((_) => checkboxFill),
        side: checkboxBorder == null
            ? null
            : BorderSide(color: checkboxBorder),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: snackBg,
        contentTextStyle: TextStyle(color: snackFg),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: dialogBg,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: fabBg,
        foregroundColor: fabFg,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
        ),
      ),
      textTheme: ThemeData(
        brightness: scheme.brightness,
        useMaterial3: useMaterial3,
      ).textTheme.apply(
        bodyColor: scheme.onSurface,
        displayColor: scheme.onSurface,
      ),
    );
  }
}
