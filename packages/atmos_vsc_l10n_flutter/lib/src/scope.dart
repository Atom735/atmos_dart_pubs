import 'package:atmos_vsc_l10n/atmos_vsc_l10n.dart';
import 'package:flutter/widgets.dart';

/// Provides [VscL10n] to descendants and rebuilds when locale/bundle changes.
///
/// ## ENG
/// Place above the UI that calls `VscL10nScope.of(context).t(...)`.
/// Does not use Material.
///
/// ## RU
/// Оберните UI; перевод — `VscL10nScope.of(context).t(...)`. Без Material.
class VscL10nScope extends StatefulWidget {
  /// Creates a scope for [l10n].
  const VscL10nScope({
    required this.l10n,
    required this.child,
    super.key,
  });

  /// Shared localization hub.
  final VscL10n l10n;

  /// Subtree.
  final Widget child;

  /// The [VscL10n] from the nearest enclosing [VscL10nScope].
  static VscL10n of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<_VscL10nInherited>();
    assert(scope != null, 'No VscL10nScope found in context');
    return scope!.l10n;
  }

  /// Like [of], or `null` if missing.
  static VscL10n? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<_VscL10nInherited>()
      ?.l10n;

  @override
  State<VscL10nScope> createState() => _VscL10nScopeState();
}

class _VscL10nScopeState extends State<VscL10nScope> {
  @override
  void initState() {
    super.initState();
    widget.l10n.addListener(_onL10nChanged);
  }

  @override
  void didUpdateWidget(covariant VscL10nScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.l10n, widget.l10n)) {
      oldWidget.l10n.removeListener(_onL10nChanged);
      widget.l10n.addListener(_onL10nChanged);
    }
  }

  @override
  void dispose() {
    widget.l10n.removeListener(_onL10nChanged);
    super.dispose();
  }

  void _onL10nChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) => _VscL10nInherited(
        l10n: widget.l10n,
        locale: widget.l10n.locale,
        bundleIdentity: identityHashCode(widget.l10n.bundle),
        child: widget.child,
      );
}

class _VscL10nInherited extends InheritedWidget {
  const _VscL10nInherited({
    required this.l10n,
    required this.locale,
    required this.bundleIdentity,
    required super.child,
  });

  final VscL10n l10n;
  final VscLocale locale;
  final int bundleIdentity;

  @override
  bool updateShouldNotify(covariant _VscL10nInherited oldWidget) =>
      locale != oldWidget.locale ||
      bundleIdentity != oldWidget.bundleIdentity ||
      !identical(l10n, oldWidget.l10n);
}
