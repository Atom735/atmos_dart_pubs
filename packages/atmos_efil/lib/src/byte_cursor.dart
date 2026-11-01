import 'dart:typed_data';

import 'package:atmos_binary_buffer/atmos_binary_buffer.dart';

/// Cursor over an executable image.
///
/// Multi-byte reads and writes use the endian passed to the constructor.
class ByteCursor {
  /// Wraps [bytes]. The list is mutated in place by the setters.
  ByteCursor(this.bytes, Endian endian)
      : data = ByteData.sublistView(bytes),
        reader = BinaryReader(bytes, endian);

  /// Backing image.
  final Uint8List bytes;

  /// Endian-aware view of [bytes].
  final ByteData data;

  /// Sequential reader from `atmos_binary_buffer`.
  final BinaryReader reader;

  /// Current read position.
  int get offset => reader.offset;

  set offset(int value) => reader.offset = value;

  /// Reads `uint8`.
  int u8() => reader.readUint8();

  /// Reads `uint16`.
  int u16() => reader.readUint16();

  /// Reads `uint32`.
  int u32() => reader.readUint32();

  /// Reads `uint64`.
  int u64() => reader.readUint64();

  /// Skips [count] bytes.
  void skip(int count) => reader.skip(count);

  /// Writes `uint16` at [at].
  void setU16(int at, int value) => data.setUint16(at, value, reader.endian);

  /// Writes `uint32` at [at].
  void setU32(int at, int value) => data.setUint32(at, value, reader.endian);

  /// Writes `uint64` at [at].
  void setU64(int at, int value) => data.setUint64(at, value, reader.endian);
}
