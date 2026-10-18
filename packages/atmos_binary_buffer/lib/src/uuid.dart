import 'dart:typed_data';

/// 16-byte RFC 4122 UUID / GUID value.
///
/// 16-байтовое значение UUID / GUID по RFC 4122.
class Uuid {
  /// Wire size in bytes.
  ///
  /// Размер на проводе в байтах.
  static const int length = 16;

  /// Raw 16 bytes (network / big-endian field order as in RFC 4122).
  ///
  /// Сырые 16 байт (порядок полей как в RFC 4122).
  final Uint8List bytes;

  /// Creates a UUID from [bytes] (must be length 16; not copied).
  ///
  /// Создаёт UUID из [bytes] (длина 16; без копирования).
  Uuid(this.bytes) {
    if (bytes.length != length) {
      throw ArgumentError.value(
        bytes.length,
        'bytes.length',
        'UUID must be $length bytes',
      );
    }
  }

  /// Copies [bytes] into a new UUID.
  ///
  /// Копирует [bytes] в новый UUID.
  factory Uuid.fromBytes(List<int> bytes) {
    if (bytes.length != length) {
      throw ArgumentError.value(
        bytes.length,
        'bytes.length',
        'UUID must be $length bytes',
      );
    }
    return Uuid(Uint8List.fromList(bytes));
  }

  /// Parses canonical `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`.
  ///
  /// Разбирает каноническую форму `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`.
  factory Uuid.parse(String input) {
    final hex = input.replaceAll('-', '');
    if (hex.length != 32) {
      throw FormatException('Invalid UUID string', input);
    }
    final out = Uint8List(length);
    for (var i = 0; i < length; i++) {
      out[i] = int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16);
    }
    return Uuid(out);
  }

  /// Nil UUID (all zeros).
  ///
  /// Nil UUID (все нули).
  static final Uuid nil = Uuid(Uint8List(length));

  @override
  String toString() {
    final h = StringBuffer();
    for (var i = 0; i < length; i++) {
      h.write(bytes[i].toRadixString(16).padLeft(2, '0'));
      if (i == 3 || i == 5 || i == 7 || i == 9) h.write('-');
    }
    return h.toString();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Uuid) return false;
    for (var i = 0; i < length; i++) {
      if (bytes[i] != other.bytes[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(bytes);
}
