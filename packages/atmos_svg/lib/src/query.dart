import 'element.dart';
import 'errors.dart';

/// Walks [root] and its descendants in document order, yielding elements
/// that match the optional filters.
///
/// Обходит [root] и потомков в порядке документа, отдавая элементы по фильтрам.
Iterable<SvgElement> queryElements(
  SvgElement root, {
  String? tag,
  String? idSelector,
  String? attrName,
  String? attrValue,
  bool includeRoot = true,
}) sync* {
  for (final el in _walk(root, includeRoot: includeRoot)) {
    if (tag != null && el.name != tag) continue;
    if (idSelector != null && el.id != idSelector) continue;
    if (attrName != null) {
      final v = el.getAttribute(attrName);
      if (v == null) continue;
      if (attrValue != null && v != attrValue) continue;
    }
    yield el;
  }
}

Iterable<SvgElement> _walk(SvgElement root, {required bool includeRoot}) sync* {
  if (includeRoot) yield root;
  for (final child in root.childElements) {
    yield* _walk(child, includeRoot: true);
  }
}

/// Matches a small CSS subset: `#id`, `tag`, `[attr]`, `[attr=value]`,
/// `tag[attr]`, `tag[attr=value]`, and descendant `a b`.
///
/// Поддерживает небольшой CSS-поднабор: `#id`, `tag`, `[attr]`, …
Iterable<SvgElement> queryBySelector(SvgElement root, String selector) {
  final parts = selector.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty || parts.first.isEmpty) {
    throw SvgFormatException('Empty selector');
  }

  var candidates = <SvgElement>[root];
  for (var i = 0; i < parts.length; i++) {
    final parsed = _parseSimple(parts[i]);
    final next = <SvgElement>[];
    final seen = <SvgElement>{};
    for (final el in candidates) {
      final matches = queryElements(
        el,
        tag: parsed.tag,
        idSelector: parsed.id,
        attrName: parsed.attrName,
        attrValue: parsed.attrValue,
        includeRoot: i == 0,
      );
      for (final m in matches) {
        if (seen.add(m)) next.add(m);
      }
    }
    candidates = next;
  }
  return candidates;
}

class _SimpleSelector {
  _SimpleSelector({
    this.tag,
    this.id,
    this.attrName,
    this.attrValue,
  });

  final String? tag;
  final String? id;
  final String? attrName;
  final String? attrValue;
}

_SimpleSelector _parseSimple(String raw) {
  var s = raw.trim();
  if (s.isEmpty) throw SvgFormatException('Empty selector part');

  String? id;
  String? tag;
  String? attrName;
  String? attrValue;

  final attrMatch = RegExp(r'\[([^\]]+)\]$').firstMatch(s);
  if (attrMatch != null) {
    final inside = attrMatch.group(1)!;
    s = s.substring(0, attrMatch.start);
    final eq = inside.indexOf('=');
    if (eq < 0) {
      attrName = inside.trim();
    } else {
      attrName = inside.substring(0, eq).trim();
      attrValue = inside.substring(eq + 1).trim();
      if ((attrValue.startsWith('"') && attrValue.endsWith('"')) ||
          (attrValue.startsWith("'") && attrValue.endsWith("'"))) {
        attrValue = attrValue.substring(1, attrValue.length - 1);
      }
    }
  }

  if (s.startsWith('#')) {
    id = s.substring(1);
    if (id.isEmpty) throw SvgFormatException('Empty id selector');
  } else if (s.isNotEmpty) {
    if (!RegExp(r'^[A-Za-z_][\w:.-]*$').hasMatch(s)) {
      throw SvgFormatException('Unsupported selector "$raw"');
    }
    tag = s.contains(':') ? s.split(':').last : s;
  }

  return _SimpleSelector(
    tag: tag,
    id: id,
    attrName: attrName,
    attrValue: attrValue,
  );
}
