import 'package:atmos_local_fonts/atmos_local_fonts.dart';
import 'package:flutter/foundation.dart';

import 'register.dart';

/// Queries a [LocalFontSource] and registers faces with Flutter.
///
/// [isLoading] is the in-progress flag. [isLoaded] is the per-face flag
/// after the font files are registered. Calls are serialized, so
/// [loadAll] and [loadFamily] see an earlier [query] that was not awaited.
///
/// Запрашивает [LocalFontSource] и регистрирует начертания во Flutter.
/// [isLoading] — флаг «идёт загрузка». [isLoaded] — флаг начертания
/// после регистрации файлов.
/// Вызовы идут очередью: [loadAll] и [loadFamily] видят предыдущий [query].
class FlutterLocalFonts extends ChangeNotifier {
  /// Creates a session for [source].
  ///
  /// [loadFiles] defaults to [loadLocalFontFiles].
  ///
  /// Создаёт сессию для [source].
  /// [loadFiles] по умолчанию — [loadLocalFontFiles].
  FlutterLocalFonts(
    this.source, {
    LocalFontFileLoader? loadFiles,
  }) : _loadFiles = loadFiles ?? loadLocalFontFiles;

  /// Face provider.
  ///
  /// Источник начертаний.
  final LocalFontSource source;

  final LocalFontFileLoader _loadFiles;

  int _depth = 0;
  var _disposed = false;
  Future<void> _chain = Future<void>.value();
  List<LocalFontFace> _faces = const <LocalFontFace>[];
  final Set<String> _loaded = <String>{};

  /// True while a query or a Flutter load is running.
  ///
  /// `true`, пока идёт запрос списка или загрузка во Flutter.
  bool get isLoading => _depth > 0;

  /// Whether [source] can list fonts in this runtime.
  ///
  /// Может ли [source] перечислить шрифты в этом окружении.
  bool get isSupported => source.isSupported;

  /// Faces from the last successful [query]. Empty before that.
  ///
  /// Начертания последнего успешного [query].
  List<LocalFontFace> get faces => _faces;

  /// Family names from [faces], in first-seen order.
  ///
  /// Имена семейств из [faces] в порядке первого появления.
  List<String> get families {
    final seen = <String>{};
    final out = <String>[];
    for (final face in _faces) {
      if (seen.add(face.family)) out.add(face.family);
    }
    return List<String>.unmodifiable(out);
  }

  /// Faces in [faces] whose family equals [family].
  ///
  /// Начертания из [faces] с семейством [family].
  List<LocalFontFace> facesOf(String family) {
    return List<LocalFontFace>.unmodifiable(
      _faces.where((face) => face.family == family),
    );
  }

  /// Whether [face] was registered in this session.
  ///
  /// Зарегистрировано ли [face] в этой сессии.
  bool isLoaded(LocalFontFace face) => _loaded.contains(face.postscriptName);

  /// Whether every face of [family] in [faces] is registered.
  ///
  /// False when [family] is absent.
  ///
  /// Зарегистрированы ли все начертания [family] из [faces].
  /// False, если семейства нет.
  bool isFamilyLoaded(String family) {
    final matched = facesOf(family);
    if (matched.isEmpty) return false;
    for (final face in matched) {
      if (!isLoaded(face)) return false;
    }
    return true;
  }

  /// Lists faces and stores them in [faces].
  ///
  /// [isLoading] becomes true before this future yields.
  /// Already registered PostScript names stay [isLoaded].
  ///
  /// Запрашивает начертания и записывает их в [faces].
  /// [isLoading] становится true до первого ожидания.
  /// Уже зарегистрированные PostScript-имена остаются [isLoaded].
  Future<List<LocalFontFace>> query({
    List<String>? postscriptNames,
  }) {
    _beginLoading();
    return _enqueue(() async {
      try {
        final list = await source.query(postscriptNames: postscriptNames);
        return _faces = List<LocalFontFace>.unmodifiable(list);
      } finally {
        _endLoading();
      }
    });
  }

  /// Loads every not-yet-loaded face currently in [faces].
  ///
  /// Загружает все ещё не загруженные начертания из [faces].
  Future<void> loadAll() {
    return _enqueue(() => _loadPending(_faces));
  }

  /// Loads faces in [faces] whose family is [family].
  ///
  /// [fontFamily] overrides the Flutter family name.
  /// Throws [LocalFontsException] when [family] is not in [faces].
  ///
  /// Загружает начертания семейства [family].
  /// [fontFamily] задаёт имя семейства во Flutter.
  Future<void> loadFamily(
    String family, {
    String? fontFamily,
  }) {
    return _enqueue(() {
      final matched = facesOf(family);
      if (matched.isEmpty) {
        throw LocalFontsException(
          'No local font faces for family "$family"',
        );
      }
      return _loadPending(matched, fontFamily: fontFamily);
    });
  }

  /// Registers [faces].
  ///
  /// No-op when every face is already loaded. [fontFamily] overrides the
  /// Flutter family name for this call.
  ///
  /// Регистрирует [faces].
  /// [fontFamily] задаёт имя семейства во Flutter для этого вызова.
  Future<void> loadFaces(
    Iterable<LocalFontFace> faces, {
    String? fontFamily,
  }) {
    final snapshot = faces.toList();
    return _enqueue(
      () => _loadPending(snapshot, fontFamily: fontFamily),
    );
  }

  Future<void> _loadPending(
    Iterable<LocalFontFace> faces, {
    String? fontFamily,
  }) async {
    final pending = <LocalFontFace>[
      for (final face in faces)
        if (!_loaded.contains(face.postscriptName)) face,
    ];
    if (pending.isEmpty) return;

    _beginLoading();
    try {
      if (fontFamily != null) {
        await _loadGroup(fontFamily, pending);
        return;
      }
      final groups = <String, List<LocalFontFace>>{};
      for (final face in pending) {
        (groups[face.family] ??= <LocalFontFace>[]).add(face);
      }
      for (final entry in groups.entries) {
        await _loadGroup(entry.key, entry.value);
      }
    } finally {
      _endLoading();
    }
  }

  Future<void> _loadGroup(
    String family,
    List<LocalFontFace> faces,
  ) async {
    final files = <Uint8List>[];
    for (final face in faces) {
      files.add(await face.readBytes());
    }
    await _loadFiles(family, files);
    for (final face in faces) {
      _loaded.add(face.postscriptName);
    }
  }

  Future<T> _enqueue<T>(Future<T> Function() action) {
    final result = _chain.then((_) => action());
    _chain = result.then<void>((_) {}, onError: _ignoreQueueError);
    return result;
  }

  static void _ignoreQueueError(Object _, StackTrace __) {
    // The returned future reports the failure. The queue keeps going.
  }

  void _beginLoading() {
    _depth++;
    if (_depth == 1) _notify();
  }

  void _endLoading() {
    if (_depth == 0) return;
    _depth--;
    _notify();
  }

  void _notify() {
    if (_disposed) return;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
