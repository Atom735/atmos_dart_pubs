import 'dart:convert';

import 'package:atmos_jsonc/atmos_jsonc.dart';
import 'package:test/test.dart';

void main() {
  group('jsoncDecode', () {
    test('plain JSON matches jsonDecode', () {
      const src = r'{"a":1,"b":[true,false,null],"s":"x\ny"}';
      expect(jsoncDecode(src), jsonDecode(src));
    });

    test('line comments', () {
      expect(
        jsoncDecode('{"a": 1, // comment\n"b": 2}'),
        {'a': 1, 'b': 2},
      );
    });

    test('block comments', () {
      expect(
        jsoncDecode('{"a": 1, /* x */ "b": 2}'),
        {'a': 1, 'b': 2},
      );
    });

    test('keeps comment-like text inside strings', () {
      expect(
        jsoncDecode('{"a": "http://x", "b": "/*no*/"}'),
        {'a': 'http://x', 'b': '/*no*/'},
      );
    });

    test('trailing commas', () {
      expect(
        jsoncDecode('{"a": [1, 2,], "b": {"c": 3,},}'),
        {
          'a': [1, 2],
          'b': {'c': 3},
        },
      );
    });

    test('numbers and escapes', () {
      expect(
        jsoncDecode(r'{"n":-1.5e2,"u":"\u0041"}'),
        {'n': -150.0, 'u': 'A'},
      );
    });

    test('chunked conversion', () {
      final sink = <Object?>[];
      final out = jsonc.decoder.startChunkedConversion(
        ChunkedConversionSink.withCallback(sink.addAll),
      );
      out
        ..add('{"a":')
        ..add('1, // c\n')
        ..add('"b":2}')
        ..close();
      expect(sink, [
        {'a': 1, 'b': 2},
      ]);
    });
  });

  group('stripJsonc', () {
    test('produces jsonDecode-compatible text', () {
      final cleaned = stripJsonc('{"a":1, //x\n"b":[2,],}');
      expect(jsonDecode(cleaned), {
        'a': 1,
        'b': [2],
      });
    });
  });
}
