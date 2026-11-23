part of '../__all.dart';

/// Parser ожидаемых [Uri] (Ссылочных) данных.
///
/// {@category Core}
/// {@category Parser}
class AtmosParserUri extends AtmosParser<Uri> {
  const AtmosParserUri() : super(name: 'uri');

  Uri? resolve(Uri? uri) {
    if (uri == null) return null;
    final z = Zone.current[Uri] as Uri?;
    return z?.resolveUri(uri) ?? uri;
  }

  @override
  Uri? parse(Object? input) {
    if (input is Uri?) return resolve(input);

    if (input is String) {
      input = input.trim();
      final parts = input.split('://');
      if (parts.length > 2) {
        input = '${parts.first}://${parts.last}';
      }

      if (input.isEmpty) return null;
      return resolve(Uri.tryParse(input));
    }
    errorUnparsed();
    return null;
  }

  @override
  Object? serialize(Uri? input) {
    return input?.toString();
  }
}
