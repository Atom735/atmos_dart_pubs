/// Build flavor used to pick a frame from multi-frame VG assets.
///
/// Set with `--dart-define=ATMOS_VG_FLAVOR=<name>` (default `gostelemed`).
///
/// Флейвор сборки для выбора кадра в multi-frame VG-ассетах.
/// Задаётся через `--dart-define=ATMOS_VG_FLAVOR=<name>` (по умолчанию
/// `gostelemed`).
enum AtmosVgFlavor {
  gostelemed,
  altai,
  buryatia,
  dagestan,
  moscowregion,
  rthealth,
  ryazan,
  vladimir,
  nino,
  perm,
  krym,
  fmba,
  sverdlovsk,
  yamalmed,
}

/// Active flavor name from dart-define.
///
/// Имя активного флейвора из dart-define.
abstract final class AtmosVgFlavorFlags {
  /// Current flavor id (lowercase).
  // ignore: do_not_use_environment
  static const current = String.fromEnvironment(
    'ATMOS_VG_FLAVOR',
    defaultValue: 'gostelemed',
  );
}

// Compile-time switches used by generated assets (tree-shake friendly).
// ignore_for_file: camel_case_types, type_annotate_public_apis

abstract final class AtmosVgFlavor$gostelemed {
  static const isCurrent = AtmosVgFlavorFlags.current == 'gostelemed';
}

abstract final class AtmosVgFlavor$altai {
  static const isCurrent = AtmosVgFlavorFlags.current == 'altai';
}

abstract final class AtmosVgFlavor$buryatia {
  static const isCurrent = AtmosVgFlavorFlags.current == 'buryatia';
}

abstract final class AtmosVgFlavor$dagestan {
  static const isCurrent = AtmosVgFlavorFlags.current == 'dagestan';
}

abstract final class AtmosVgFlavor$moscowregion {
  static const isCurrent = AtmosVgFlavorFlags.current == 'moscowregion';
}

abstract final class AtmosVgFlavor$rthealth {
  static const isCurrent = AtmosVgFlavorFlags.current == 'rthealth';
}

abstract final class AtmosVgFlavor$ryazan {
  static const isCurrent = AtmosVgFlavorFlags.current == 'ryazan';
}

abstract final class AtmosVgFlavor$vladimir {
  static const isCurrent = AtmosVgFlavorFlags.current == 'vladimir';
}

abstract final class AtmosVgFlavor$nino {
  static const isCurrent = AtmosVgFlavorFlags.current == 'nino';
}

abstract final class AtmosVgFlavor$perm {
  static const isCurrent = AtmosVgFlavorFlags.current == 'perm';
}

abstract final class AtmosVgFlavor$krym {
  static const isCurrent = AtmosVgFlavorFlags.current == 'krym';
}

abstract final class AtmosVgFlavor$fmba {
  static const isCurrent = AtmosVgFlavorFlags.current == 'fmba';
}

abstract final class AtmosVgFlavor$sverdlovsk {
  static const isCurrent = AtmosVgFlavorFlags.current == 'sverdlovsk';
}

abstract final class AtmosVgFlavor$yamalmed {
  static const isCurrent = AtmosVgFlavorFlags.current == 'yamalmed';
}
