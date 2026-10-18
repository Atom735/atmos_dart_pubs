import 'package:atmos_jsonc/atmos_jsonc.dart';
import 'package:test/test.dart';

class _Point {
  _Point(this.x, this.y);
  final int x;
  final int y;
}

void main() {
  group('path reviver', () {
    test('identity matches tree decode', () {
      const src = '{"a":[1,2,],"b":{"c":3}}';
      final withReviver = jsoncDecode(src, reviver: (path, value) => value);
      expect(withReviver, jsoncDecode(src));
    });

    test('full path on nested values', () {
      final paths = <String>[];
      jsoncDecode(
        '{"user":{"name":"Ada","tags":["a",]}}',
        reviver: (path, value) {
          paths.add(path.join());
          return value;
        },
      );
      expect(paths, contains('user/name'));
      expect(paths, contains('user/tags/0'));
      expect(paths, contains('user/tags'));
      expect(paths, contains('user'));
      expect(paths, contains(''));
    });

    test('can replace map with class', () {
      final value = jsoncDecode(
        '{"x":1,"y":2}',
        reviver: (path, value) {
          if (path.isEmpty && value is Map) {
            return _Point(value['x'] as int, value['y'] as int);
          }
          return value;
        },
      );
      expect(value, isA<_Point>());
      final point = value! as _Point;
      expect(point.x, 1);
      expect(point.y, 2);
    });
  });

  group('visitor', () {
    test('emits begin/end without requiring maps', () {
      final log = <String>[];
      jsoncVisit(
        '{"a":1}',
        _LoggingVisitor(log),
      );
      expect(log, [
        'beginObject:',
        'key:a',
        'number:a=1',
        'endObject:',
      ]);
    });
  });

  group('binder', () {
    test('builds class without intermediate map', () {
      final point = jsoncBind(
        '{"x":10,"y":20,}',
        const _PointBinder(),
      );
      expect(point.x, 10);
      expect(point.y, 20);
    });

    test('nested bind with path', () {
      final user = jsoncBind(
        '{"name":"Ada","point":{"x":1,"y":2}}',
        const _UserBinder(),
      );
      expect(user.name, 'Ada');
      expect(user.point.x, 1);
      expect(user.pathDuringPoint, 'point');
    });
  });
}

class _LoggingVisitor extends JsoncVisitor {
  _LoggingVisitor(this.log);
  final List<String> log;

  @override
  void beginObject(JsoncPath path) => log.add('beginObject:${path.join()}');

  @override
  void endObject(JsoncPath path) => log.add('endObject:${path.join()}');

  @override
  void propertyKey(JsoncPath path, String key) => log.add('key:$key');

  @override
  void numberValue(JsoncPath path, num value) =>
      log.add('number:${path.join()}=$value');
}

class _PointBinder implements JsoncBinder<_Point> {
  const _PointBinder();

  @override
  _Point fromJsonc(JsoncReader reader) {
    reader.expectObject();
    var x = 0;
    var y = 0;
    while (reader.nextField()) {
      switch (reader.key) {
        case 'x':
          x = reader.readInt();
        case 'y':
          y = reader.readInt();
        default:
          reader.skip();
      }
      reader.endField();
    }
    return _Point(x, y);
  }
}

class _User {
  _User(this.name, this.point, this.pathDuringPoint);
  final String name;
  final _Point point;
  final String pathDuringPoint;
}

class _UserBinder implements JsoncBinder<_User> {
  const _UserBinder();

  @override
  _User fromJsonc(JsoncReader reader) {
    reader.expectObject();
    var name = '';
    _Point? point;
    var pathDuringPoint = '';
    while (reader.nextField()) {
      switch (reader.key) {
        case 'name':
          name = reader.readString();
        case 'point':
          pathDuringPoint = reader.path.join();
          point = reader.readObject(const _PointBinder());
        default:
          reader.skip();
      }
      reader.endField();
    }
    return _User(name, point!, pathDuringPoint);
  }
}
