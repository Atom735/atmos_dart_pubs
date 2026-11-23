import 'spec.dart';

/// Builds a simple HTML gallery of the original SVGs (side-by-side preview).
///
/// Собирает простой HTML-галерею исходных SVG (превью рядом).
String buildSvgPreviewHtml({
  required VgGenSpec spec,
  required List<VgCompiledAsset> assets,
  Map<String, String>? svgByName,
}) {
  final cards = StringBuffer();
  for (final a in assets) {
    final svg = svgByName?[a.name] ?? '';
    final frame = a.container.frames.isEmpty
        ? null
        : a.container.frames.first;
    final sizeLabel = frame == null
        ? '—'
        : '${frame.width.toStringAsFixed(0)}×${frame.height.toStringAsFixed(0)}';
    cards.writeln('''
    <figure class="card">
      <figcaption>
        <strong>${_esc(a.identifier)}</strong>
        <span>$sizeLabel · ${a.bytes.length} B GVG3</span>
      </figcaption>
      <div class="preview">$svg</div>
      <p class="meta">${_esc(a.sourceLabel)}</p>
    </figure>
''');
  }

  return '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8"/>
  <title>${_esc(spec.className)} — atmos_vg_gen preview</title>
  <style>
    :root { color-scheme: light dark; font-family: ui-sans-serif, system-ui, sans-serif; }
    body { margin: 1.5rem; background: #111; color: #eee; }
    h1 { font-size: 1.25rem; font-weight: 600; }
    .grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(180px, 1fr)); gap: 1rem; }
    .card { margin: 0; padding: 0.75rem; border-radius: 8px; background: #1c1c1c; border: 1px solid #333; }
    .card figcaption { display: flex; flex-direction: column; gap: 0.15rem; margin-bottom: 0.5rem; font-size: 0.85rem; }
    .card figcaption span { opacity: 0.65; font-size: 0.75rem; }
    .preview { display: grid; place-items: center; min-height: 96px; background: #0a0a0a; border-radius: 6px; padding: 0.5rem; }
    .preview svg { max-width: 96px; max-height: 96px; }
    .meta { margin: 0.5rem 0 0; font-size: 0.7rem; opacity: 0.5; word-break: break-all; }
  </style>
</head>
<body>
  <h1>${_esc(spec.className)} <small style="opacity:.5">(${assets.length} assets)</small></h1>
  <div class="grid">
${cards.toString().trimRight()}
  </div>
</body>
</html>
''';
}

String _esc(String s) => s
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;');
