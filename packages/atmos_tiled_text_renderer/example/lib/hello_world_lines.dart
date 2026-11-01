import 'dart:ui';

import 'package:atmos_tiled_text_renderer/atmos_tiled_text_renderer.dart';

/// Block size in logical pixels. Golden frames are baked at the same size.
///
/// Кегль блока в логических пикселях. Золотые кадры запекаются с ним же.
const double codeFontSize = 16;

/// Colors close to a dark editor theme: keywords, types, calls, strings.
///
/// Цвета близки к тёмной теме редактора: ключевые слова, типы, вызовы, строки.
const Color codePlain = Color(0xFFD4D4D4);
const Color codeKeyword = Color(0xFF569CD6);
const Color codeType = Color(0xFF4EC9B0);
const Color codeCall = Color(0xFFDCDCAA);
const Color codeString = Color(0xFFCE9178);

/// Four lines of the same hello world.
///
/// `=>` sits in its own text node, so the tokenizer
/// merges it into one wide glyph.
///
/// Четыре строки одного и того же hello world.
///
/// `=>` лежит в собственном текстовом узле, поэтому токенизатор
/// склеивает его в один широкий глиф.
const List<AtlasTextSpan> helloWorldLines = <AtlasTextSpan>[
  AtlasTextSpan(
    children: <AtlasTextSpan>[
      AtlasTextSpan(text: 'void', style: AtlasTextStyle(color: codeKeyword)),
      AtlasTextSpan(text: ' ', style: AtlasTextStyle(color: codePlain)),
      AtlasTextSpan(text: 'main', style: AtlasTextStyle(color: codeCall)),
      AtlasTextSpan(text: '() {', style: AtlasTextStyle(color: codePlain)),
    ],
  ),
  AtlasTextSpan(
    children: <AtlasTextSpan>[
      AtlasTextSpan(
          text: '  const ', style: AtlasTextStyle(color: codeKeyword),),
      AtlasTextSpan(text: 'greet ', style: AtlasTextStyle(color: codePlain)),
      AtlasTextSpan(text: '= (', style: AtlasTextStyle(color: codePlain)),
      AtlasTextSpan(text: 'String', style: AtlasTextStyle(color: codeType)),
      AtlasTextSpan(text: ' name) ', style: AtlasTextStyle(color: codePlain)),
      AtlasTextSpan(text: '=>', style: AtlasTextStyle(color: codePlain)),
      AtlasTextSpan(text: ' ', style: AtlasTextStyle(color: codePlain)),
      AtlasTextSpan(
        text: r"'Hello, $name!'",
        style: AtlasTextStyle(color: codeString),
      ),
      AtlasTextSpan(text: ';', style: AtlasTextStyle(color: codePlain)),
    ],
  ),
  AtlasTextSpan(
    children: <AtlasTextSpan>[
      AtlasTextSpan(text: '  ', style: AtlasTextStyle(color: codePlain)),
      AtlasTextSpan(text: 'print', style: AtlasTextStyle(color: codeCall)),
      AtlasTextSpan(text: '(greet(', style: AtlasTextStyle(color: codePlain)),
      AtlasTextSpan(text: "'World'", style: AtlasTextStyle(color: codeString)),
      AtlasTextSpan(text: '));', style: AtlasTextStyle(color: codePlain)),
    ],
  ),
  AtlasTextSpan(
    text: '}',
    style: AtlasTextStyle(color: codePlain),
  ),
];

/// Faces used to draw the same block.
///
/// Consolas and Courier New are not shipped. Liberation Mono
/// matches Courier New metrics and is licensed under the OFL.
///
/// Лица, которыми рисуется один и тот же блок.
///
/// Consolas и Courier New в поставку не входят. Liberation Mono
/// совпадает с Courier New по метрике и лицензирован OFL.
const List<CodeFace> codeFaces = <CodeFace>[
  CodeFace(
    family: 'Fira Code',
    asset: 'fonts/FiraCode-Regular.ttf',
    note: 'Лигатуры для кода',
  ),
  CodeFace(
    family: 'JetBrains Mono',
    asset: 'fonts/JetBrainsMono-Regular.ttf',
    note: 'Шрифт IDE',
  ),
  CodeFace(
    family: 'Cascadia Mono',
    asset: 'fonts/CascadiaMono-Regular.ttf',
    note: 'Моноширинный Cascadia',
  ),
  CodeFace(
    family: 'Liberation Mono',
    asset: 'fonts/LiberationMono-Regular.ttf',
    note: 'Метрика Courier New',
  ),
];

/// One monospace face and the file the example loads it from.
///
/// Одно моноширинное лицо и файл, из которого его грузит пример.
class CodeFace {
  const CodeFace({
    required this.family,
    required this.asset,
    required this.note,
  });

  final String family;
  final String asset;
  final String note;
}

/// Flattened hello-world lines. Compute once per atlas bake.
///
/// Плоские строки hello world. Считать один раз на запекание атласа.
List<FlattenedLineCache> flattenHelloWorld() {
  return <FlattenedLineCache>[
    for (final AtlasTextSpan line in helloWorldLines)
      FlattenedLineCache.fromSpan(line, defaultCodeLigatures),
  ];
}
