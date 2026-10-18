import 'package:atmos_binary_buffer/atmos_binary_buffer.dart';
import 'package:test/test.dart';

void main() {
  group('bool / bytes / fourcc', () {
    test('bool roundtrip', () {
      final w = BinaryWriter()
        ..writeBool(true)
        ..writeBool(false);
      final r = BinaryReader(w.takeBytes());
      expect(r.readBool(), isTrue);
      expect(r.readBool(), isFalse);
    });

    test('bytes and bytesSized', () {
      final payload = <int>[1, 2, 3, 4, 5];
      final w = BinaryWriter()
        ..writeBytes(payload)
        ..writeBytesSized(payload);
      final bytes = w.takeBytes();
      final r = BinaryReader(bytes);
      expect(r.readBytes(5), payload);
      expect(r.readBytesSized(), payload);
    });

    test('fourcc', () {
      final w = BinaryWriter()..writeFourCC('RIFF');
      expect(BinaryReader(w.takeBytes()).readFourCC(), 'RIFF');
    });
  });

  group('uuid', () {
    test('parse and wire roundtrip', () {
      final id = Uuid.parse('550e8400-e29b-41d4-a716-446655440000');
      expect(id.toString(), '550e8400-e29b-41d4-a716-446655440000');
      final w = BinaryWriter()..writeUuid(id);
      final got = BinaryReader(w.takeBytes()).readUuid();
      expect(got, id);
      expect(got.bytes.length, 16);
    });
  });

  group('time', () {
    test('datetime milliseconds compat', () {
      final t = DateTime.utc(2024, 1, 2, 3, 4, 5, 6);
      final w = BinaryWriter()..writeDateTime(t);
      final got = BinaryReader(w.takeBytes()).readDateTime();
      expect(got.millisecondsSinceEpoch, t.millisecondsSinceEpoch);
    });

    test('datetime seconds / microseconds', () {
      final t = DateTime.utc(2020, 5, 6, 7, 8, 9);
      final w = BinaryWriter()
        ..writeDateTime(t, EpochUnit.seconds)
        ..writeDateTime(t, EpochUnit.microseconds);
      final r = BinaryReader(w.takeBytes());
      expect(
        r.readDateTime(EpochUnit.seconds).millisecondsSinceEpoch,
        t.millisecondsSinceEpoch ~/ 1000 * 1000,
      );
      expect(
        r.readDateTime(EpochUnit.microseconds).microsecondsSinceEpoch,
        t.microsecondsSinceEpoch,
      );
    });

    test('duration', () {
      const d = Duration(days: 1, hours: 2, minutes: 3, microseconds: 4);
      final w = BinaryWriter()
        ..writeDuration(d)
        ..writeDuration(d, EpochUnit.milliseconds);
      final r = BinaryReader(w.takeBytes());
      expect(r.readDuration(), d);
      expect(
        r.readDuration(EpochUnit.milliseconds).inMilliseconds,
        d.inMilliseconds,
      );
    });
  });

  group('cstring', () {
    test('roundtrip', () {
      final w = BinaryWriter()..writeCString('hello');
      expect(BinaryReader(w.takeBytes()).readCString(), 'hello');
    });
  });

  group('leb128', () {
    test('uleb128', () {
      for (final v in [0, 1, 127, 128, 255, 300, 0x3FFF, 0x1FFFFF]) {
        final w = BinaryWriter()..writeUleb128(v);
        expect(BinaryReader(w.takeBytes()).readUleb128(), v, reason: '$v');
      }
    });

    test('sleb128', () {
      for (final v in [0, 1, -1, 63, -64, 64, -65, 127, -128, 1000, -1000]) {
        final w = BinaryWriter()..writeSleb128(v);
        expect(BinaryReader(w.takeBytes()).readSleb128(), v, reason: '$v');
      }
    });
  });
}
