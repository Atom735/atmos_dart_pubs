// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:atmos_jsonc/atmos_jsonc.dart';

/// Run from package root:
/// `dart run example/example.dart`
void main() {
  print('=== atmos_jsonc examples ===\n');
  basicDecodeExample();
  pathReviverExample();
  binderExample();
  visitorExample();
  utf8Example();
  stripExample();
}

/// 1. JSONC tree decode (comments + trailing commas).
void basicDecodeExample() {
  print('1. jsoncDecode (tree):');
  final value = jsoncDecode('''
  {
    // editor theme snippet
    "name": "Demo",
    "colors": {
      "editor.background": "#1e1e1e",
      "editor.foreground": "#d4d4d4",
    },
    "tokenColors": [
      {"scope": "comment", "settings": {"foreground": "#6a9955",},},
    ],
  }
  ''');
  print('  name: ${(value as Map)['name']}');
  print('  colors: ${value['colors']}');
  print('  tokens: ${(value['tokenColors'] as List).length}');
  print('');
}

/// 2. Path-aware reviver — full key/index stack, replace Map with a class.
void pathReviverExample() {
  print('2. path reviver → Dart class:');
  final user = jsoncDecode(
    '''
    {
      "user": {
        "name": "Ada",
        "tags": ["lang", "math",],
      }
    }
    ''',
    reviver: (path, value) {
      // Log a couple of interesting paths (live view — do not store `path`).
      if (path.join() == 'user/name' || path.join() == 'user/tags/0') {
        print('  reviver @ ${path.join()} => $value');
      }
      if (path.length == 1 && path[0] == 'user' && value is Map) {
        final tags = (value['tags'] as List).cast<String>();
        return User(value['name'] as String, tags);
      }
      return value;
    },
  ) as Map;
  final u = user['user'] as User;
  print('  User(${u.name}, tags=${u.tags})');
  print('');
}

/// 3. Pull binder — no intermediate Map for the bound type.
void binderExample() {
  print('3. jsoncBind (no Map for Point):');
  final point = jsoncBind(
    '{"x": 3, "y": 4, "extra": true,}',
    const PointBinder(),
  );
  print('  Point(${point.x}, ${point.y})');

  final team = jsoncBind(
    '''
    {
      "name": "Core",
      "members": [
        {"name": "Ada", "tags": ["lang"],},
        {"name": "Grace", "tags": ["cobol", "navy"],},
      ],
    }
    ''',
    const TeamBinder(),
  );
  print('  Team ${team.name}: ${team.members.map((m) => m.name).join(', ')}');
  print('');
}

/// 4. SAX visitor — walk events with path stack, never build a tree.
void visitorExample() {
  print('4. jsoncVisit (SAX):');
  final v = _CollectVisitor();
  jsoncVisit(
    '{"a": 1, "b": [true, null,],}',
    v,
  );
  for (final line in v.lines) {
    print('  $line');
  }
  print('');
}

/// 5. UTF-8 bytes — no full document String.
void utf8Example() {
  print('5. jsoncDecodeUtf8 / JsoncUtf8Decoder:');
  final bytes = utf8.encode('{"msg":"привет", "n":1,}');
  final value = jsoncDecodeUtf8(bytes) as Map;
  print('  $value');
  print('  via codec: ${jsoncUtf8.decode(bytes)}');
  print('');
}

/// 6. stripJsonc — only when you need plain JSON text for another tool.
void stripExample() {
  print('6. stripJsonc (prefer jsoncDecode for parsing):');
  final cleaned = stripJsonc('{"a": 1, // x\n"b": [2,],}');
  print('  $cleaned');
  print('');
}

// --- models / binders -------------------------------------------------------

class User {
  User(this.name, this.tags);
  final String name;
  final List<String> tags;
}

class Point {
  Point(this.x, this.y);
  final int x;
  final int y;
}

class PointBinder implements JsoncBinder<Point> {
  const PointBinder();

  @override
  Point fromJsonc(JsoncReader r) {
    r.expectObject();
    var x = 0;
    var y = 0;
    while (r.nextField()) {
      switch (r.key) {
        case 'x':
          x = r.readInt();
        case 'y':
          y = r.readInt();
        default:
          r.skip();
      }
      r.endField();
    }
    return Point(x, y);
  }
}

class Team {
  Team(this.name, this.members);
  final String name;
  final List<User> members;
}

class TeamBinder implements JsoncBinder<Team> {
  const TeamBinder();

  @override
  Team fromJsonc(JsoncReader r) {
    r.expectObject();
    var name = '';
    final members = <User>[];
    while (r.nextField()) {
      switch (r.key) {
        case 'name':
          name = r.readString();
        case 'members':
          r.expectArray();
          while (r.nextElement()) {
            members.add(r.readObject(const UserBinder()));
            r.endElement();
          }
        default:
          r.skip();
      }
      r.endField();
    }
    return Team(name, members);
  }
}

class UserBinder implements JsoncBinder<User> {
  const UserBinder();

  @override
  User fromJsonc(JsoncReader r) {
    r.expectObject();
    var name = '';
    final tags = <String>[];
    while (r.nextField()) {
      switch (r.key) {
        case 'name':
          name = r.readString();
        case 'tags':
          r.expectArray();
          while (r.nextElement()) {
            tags.add(r.readString());
            r.endElement();
          }
        default:
          r.skip();
      }
      r.endField();
    }
    return User(name, tags);
  }
}

class _CollectVisitor extends JsoncVisitor {
  final lines = <String>[];

  @override
  void beginObject(JsoncPath path) =>
      lines.add('beginObject @ ${path.join().ifEmpty('(root)')}');

  @override
  void endObject(JsoncPath path) =>
      lines.add('endObject   @ ${path.join().ifEmpty('(root)')}');

  @override
  void beginArray(JsoncPath path) => lines.add('beginArray  @ ${path.join()}');

  @override
  void endArray(JsoncPath path) => lines.add('endArray    @ ${path.join()}');

  @override
  void propertyKey(JsoncPath path, String key) => lines.add('key         $key');

  @override
  void stringValue(JsoncPath path, String value) =>
      lines.add('string      ${path.join()} = $value');

  @override
  void numberValue(JsoncPath path, num value) =>
      lines.add('number      ${path.join()} = $value');

  @override
  void boolValue(JsoncPath path, bool value) =>
      lines.add('bool        ${path.join()} = $value');

  @override
  void nullValue(JsoncPath path) =>
      lines.add('null        ${path.join()}');
}

extension on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}
