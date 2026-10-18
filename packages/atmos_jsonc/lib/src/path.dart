/// Read-only view of the current JSON path (object keys + array indices).
///
/// ## ENG
/// Backed by a mutable stack owned by the parser — do not store the instance
/// across callbacks without `toList` / `toString`. [length] changes in place
/// (no per-push allocation).
///
/// ## RU
/// Смотрит на мутабельный стек парсера — не сохраняйте экземпляр между
/// колбэками без `toList` / `toString`. [length] меняется in-place
/// (без аллокации на каждый push).
class JsoncPath {
  /// Creates an empty path with a reusable segment buffer.
  JsoncPath([List<Object>? segments])
      : _segments = segments ?? <Object>[],
        length = segments?.length ?? 0;

  final List<Object> _segments;

  /// Number of active segments.
  int length;

  /// Whether the path is the document root.
  bool get isEmpty => length == 0;

  /// Last segment, or `null` if empty.
  Object? get last => length == 0 ? null : _segments[length - 1];

  /// Segment at [index] (`0 … length-1`).
  Object operator [](int index) {
    if (index < 0 || index >= length) {
      throw RangeError.range(index, 0, length - 1, 'index');
    }
    return _segments[index];
  }

  /// Pushes [segment] (reuses list capacity when possible).
  void push(Object segment) {
    if (length < _segments.length) {
      _segments[length] = segment;
    } else {
      _segments.add(segment);
    }
    length++;
  }

  /// Pops the last segment.
  void pop() {
    if (length == 0) {
      throw StateError('JsoncPath.pop on empty path');
    }
    length--;
  }

  /// `true` if the last segment equals [segment].
  bool endsWith(Object segment) => last == segment;

  /// Copies active segments into a new list.
  List<Object> toList() => _segments.sublist(0, length);

  /// Joins segments with [separator] (`String` keys / `int` indices).
  String join([String separator = '/']) {
    if (length == 0) return '';
    final buf = StringBuffer();
    for (var i = 0; i < length; i++) {
      if (i > 0) buf.write(separator);
      buf.write(_segments[i]);
    }
    return buf.toString();
  }

  @override
  String toString() => join();

  @override
  bool operator ==(Object other) {
    if (other is! JsoncPath || other.length != length) return false;
    for (var i = 0; i < length; i++) {
      if (_segments[i] != other._segments[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode {
    var h = 0;
    for (var i = 0; i < length; i++) {
      h = Object.hash(h, _segments[i]);
    }
    return h;
  }
}

/// Bottom-up reviver with a full [JsoncPath] (not only the immediate key).
///
/// ## ENG
/// Called for every completed value. Return a replacement (e.g. a Dart class)
/// or [value] unchanged. Root uses an empty path.
///
/// ## RU
/// Вызывается для каждого готового значения. Верните замену (класс) или
/// [value] без изменений. У корня путь пустой.
typedef JsoncReviver = Object? Function(JsoncPath path, Object? value);
