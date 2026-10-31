/// A canned string for judging a typeface.
///
/// Готовый текст, чтобы смотреть рисунок шрифта.
class PreviewSample {
  /// Creates a labeled sample.
  ///
  /// Создаёт образец с подписью.
  const PreviewSample({
    required this.id,
    required this.label,
    required this.text,
  });

  /// Stable id.
  ///
  /// Стабильный идентификатор.
  final String id;

  /// Short chip label.
  ///
  /// Короткая подпись кнопки.
  final String label;

  /// Text placed into the editor and the preview.
  ///
  /// Текст для поля и для просмотра.
  final String text;
}

/// Samples offered by the preview.
///
/// Образцы, которые предлагает просмотр.
const List<PreviewSample> previewSamples = <PreviewSample>[
  PreviewSample(
    id: 'lorem',
    label: 'Lorem',
    text: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, '
        'sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. '
        'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris.',
  ),
  PreviewSample(
    id: 'pangram-en',
    label: 'Pangram',
    text: 'The quick brown fox jumps over the lazy dog. '
        'Pack my box with five dozen liquor jugs. 0123456789',
  ),
  PreviewSample(
    id: 'pangram-ru',
    label: 'Панграмма',
    text: 'Съешь ещё этих мягких французских булок, да выпей чаю. '
        'В чащах юга жил бы цитрус? Да, но фальшивый экземпляр!',
  ),
  PreviewSample(
    id: 'alphabet',
    label: 'Алфавит',
    text: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ\n'
        'abcdefghijklmnopqrstuvwxyz\n'
        'АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ\n'
        'абвгдеёжзийклмнопрстуфхцчшщъыьэюя\n'
        '0123456789  !?.,;:— «» “” ()[]{}',
  ),
  PreviewSample(
    id: 'hamburgefonstiv',
    label: 'Набор',
    text: 'Hamburgefonstiv\n'
        'Ragged letters: a c e g m n o r s u\n'
        '0123456789',
  ),
];

/// Sample shown when the preview opens.
///
/// Образец, который открывается сразу.
final PreviewSample defaultPreviewSample = previewSamples.first;
