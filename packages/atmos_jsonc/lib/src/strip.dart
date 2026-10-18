/// Strips JSONC comments and trailing commas, leaving plain JSON text.
///
/// ## ENG
/// Prefer `jsoncDecode` for parsing — strip builds a second full string and
/// uses more peak memory. Kept for tooling / interoperability.
///
/// ## RU
/// Для парсинга лучше `jsoncDecode` — strip делает вторую полную строку и
/// увеличивает пиковую память. Оставлен для тулов / совместимости.
String stripJsonc(String source) {
  final out = StringBuffer();
  var i = 0;
  var inString = false;
  var escape = false;

  while (i < source.length) {
    final c = source.codeUnitAt(i);

    if (inString) {
      out.writeCharCode(c);
      if (escape) {
        escape = false;
      } else if (c == 0x5C /* \ */) {
        escape = true;
      } else if (c == 0x22 /* " */) {
        inString = false;
      }
      i++;
      continue;
    }

    if (c == 0x2F /* / */ && i + 1 < source.length) {
      final next = source.codeUnitAt(i + 1);
      if (next == 0x2F /* / */) {
        i += 2;
        while (i < source.length) {
          final ch = source.codeUnitAt(i);
          if (ch == 0x0A || ch == 0x0D) break;
          i++;
        }
        continue;
      }
      if (next == 0x2A /* * */) {
        i += 2;
        while (i + 1 < source.length) {
          if (source.codeUnitAt(i) == 0x2A &&
              source.codeUnitAt(i + 1) == 0x2F) {
            i += 2;
            break;
          }
          i++;
        }
        continue;
      }
    }

    if (c == 0x22 /* " */) {
      inString = true;
      out.writeCharCode(c);
      i++;
      continue;
    }

    if (c == 0x2C /* , */) {
      var j = i + 1;
      while (j < source.length) {
        final ch = source.codeUnitAt(j);
        if (ch == 0x20 || ch == 0x09 || ch == 0x0A || ch == 0x0D) {
          j++;
          continue;
        }
        if (ch == 0x2F /* / */ && j + 1 < source.length) {
          final n = source.codeUnitAt(j + 1);
          if (n == 0x2F) {
            j += 2;
            while (j < source.length) {
              final x = source.codeUnitAt(j);
              if (x == 0x0A || x == 0x0D) break;
              j++;
            }
            continue;
          }
          if (n == 0x2A) {
            j += 2;
            while (j + 1 < source.length) {
              if (source.codeUnitAt(j) == 0x2A &&
                  source.codeUnitAt(j + 1) == 0x2F) {
                j += 2;
                break;
              }
              j++;
            }
            continue;
          }
        }
        if (ch == 0x7D /* } */ || ch == 0x5D /* ] */) {
          i++;
          break;
        }
        out.writeCharCode(c);
        i++;
        break;
      }
      if (j >= source.length) {
        out.writeCharCode(c);
        i++;
      }
      continue;
    }

    out.writeCharCode(c);
    i++;
  }

  return out.toString();
}
