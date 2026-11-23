import 'element.dart';

/// Base node in an SVG tree (element or text).
///
/// Базовый узел дерева SVG (элемент или текст).
abstract class SvgNode {
  /// Creates a node.
  ///
  /// Создаёт узел.
  SvgNode();

  /// Parent element, or `null` for the document root.
  ///
  /// Родительский элемент или `null` для корня документа.
  SvgElement? get parent;

  /// Deep clone of this node (no parent).
  ///
  /// Глубокий клон узла (без родителя).
  SvgNode clone();

  /// Removes this node from its [parent], if any.
  ///
  /// Удаляет узел из [parent], если он есть.
  void remove();
}

/// Text content inside an element.
///
/// Текстовое содержимое внутри элемента.
class SvgText extends SvgNode {
  /// Creates a text node.
  ///
  /// Создаёт текстовый узел.
  SvgText(this.text);

  /// Character data.
  ///
  /// Текстовые данные.
  String text;

  SvgElement? _parent;

  @override
  SvgElement? get parent => _parent;

  /// Internal: attach to [parent].
  // ignore: use_setters_to_change_properties
  void attach(SvgElement? parent) => _parent = parent;

  @override
  SvgText clone() => SvgText(text);

  @override
  void remove() {
    _parent?.removeChild(this);
  }

  @override
  String toString() => 'SvgText($text)';
}
