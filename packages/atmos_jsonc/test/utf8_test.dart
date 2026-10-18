import 'dart:convert';

import 'package:atmos_jsonc/atmos_jsonc.dart';
import 'package:test/test.dart';

void main() {
  group('jsoncDecodeUtf8', () {
    test('matches jsoncDecode on plain JSONC', () {
      const src = '''
      {
        // c
        "a": 1,
        "b": ["x", true,],
        "n": -1.5e2,
      }
      ''';
      expect(jsoncDecodeUtf8(utf8.encode(src)), jsoncDecode(src));
    });

    test('utf-8 string values', () {
      final bytes = utf8.encode('{"msg":"привет","e":"café"}');
      expect(jsoncDecodeUtf8(bytes), {
        'msg': 'привет',
        'e': 'café',
      });
    });

    test('escapes and path reviver', () {
      final value = jsoncDecodeUtf8(
        utf8.encode(r'{"s":"a\nb","u":"\u0041"}'),
        reviver: (path, v) {
          if (path.endsWith('u')) return 'U:$v';
          return v;
        },
      );
      expect(value, {
        's': 'a\nb',
        'u': 'U:A',
      });
    });

    test('JsoncUtf8Decoder chunked', () {
      final sink = <Object?>[];
      final out = const JsoncUtf8Decoder().startChunkedConversion(
        ChunkedConversionSink.withCallback(sink.addAll),
      );
      out
        ..add(utf8.encode('{"a":'))
        ..add(utf8.encode('1, // x\n'))
        ..add(utf8.encode('"b":2}'))
        ..close();
      expect(sink, [
        {'a': 1, 'b': 2},
      ]);
    });

    test('jsoncUtf8 codec round-trip encode', () {
      final encoded = jsoncUtf8.encode({'a': 1, 'b': 'x'});
      expect(jsoncDecodeUtf8(encoded), {'a': 1, 'b': 'x'});
    });
  });
}
