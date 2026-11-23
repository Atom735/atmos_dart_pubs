import 'node.dart';
import 'query.dart';

/// An SVG element with a local name, attributes, and children.
///
/// Элемент SVG с локальным именем, атрибутами и детьми.
class SvgElement extends SvgNode {
  /// Creates an element named [name] (local name, for example `path`).
  ///
  /// Создаёт элемент с именем [name] (локальное имя, например `path`).
  SvgElement(
    this.name, {
    Map<String, String>? attributes,
    List<SvgNode>? children,
  })  : attributes = Map<String, String>.from(attributes ?? const {}),
        _children = <SvgNode>[] {
    if (children != null) {
      children.forEach(appendChild);
    }
  }

  /// Local tag name without namespace prefix (`svg`, `path`, `g`, …).
  ///
  /// Локальное имя тега без префикса пространства имён.
  String name;

  /// Mutable attribute map (keys without namespace, for example `viewBox`).
  ///
  /// Изменяемая карта атрибутов (ключи без namespace, например `viewBox`).
  final Map<String, String> attributes;

  final List<SvgNode> _children;

  SvgElement? _parent;

  @override
  SvgElement? get parent => _parent;

  /// Child nodes in document order.
  ///
  /// Дочерние узлы в порядке документа.
  List<SvgNode> get children => List<SvgNode>.unmodifiable(_children);

  /// Child elements only.
  ///
  /// Только дочерние элементы.
  Iterable<SvgElement> get childElements =>
      _children.whereType<SvgElement>();

  /// Concatenated text of direct [SvgText] children.
  ///
  /// Склеенный текст прямых дочерних [SvgText].
  String get textContent => _children
      .whereType<SvgText>()
      .map((t) => t.text)
      .join();

  /// Sets text by replacing all children with a single [SvgText].
  ///
  /// Задаёт текст, заменяя всех детей одним [SvgText].
  set textContent(String value) {
    clearChildren();
    if (value.isNotEmpty) appendChild(SvgText(value));
  }

  /// Returns attribute [name], or `null` if missing.
  ///
  /// Возвращает атрибут [name] или `null`, если его нет.
  String? getAttribute(String name) => attributes[name];

  /// Sets attribute [name] to [value].
  ///
  /// Устанавливает атрибут [name] в [value].
  void setAttribute(String name, String value) {
    attributes[name] = value;
  }

  /// Removes attribute [name]. Returns whether it existed.
  ///
  /// Удаляет атрибут [name]. Возвращает, был ли он.
  bool removeAttribute(String name) => attributes.remove(name) != null;

  /// Whether this element has attribute [name].
  ///
  /// Есть ли у элемента атрибут [name].
  bool hasAttribute(String name) => attributes.containsKey(name);

  /// `id` attribute shorthand.
  ///
  /// Сокращение для атрибута `id`.
  String? get id => getAttribute('id');

  set id(String? value) {
    if (value == null) {
      removeAttribute('id');
    } else {
      setAttribute('id', value);
    }
  }

  /// Appends [child], reparenting it if needed.
  ///
  /// Добавляет [child], при необходимости меняя родителя.
  void appendChild(SvgNode child) {
    child.remove();
    _children.add(child);
    _attach(child);
  }

  /// Inserts [child] before [reference], or appends if [reference] is null.
  ///
  /// Вставляет [child] перед [reference] или добавляет в конец.
  void insertBefore(SvgNode child, SvgNode? reference) {
    child.remove();
    if (reference == null) {
      appendChild(child);
      return;
    }
    final index = _children.indexOf(reference);
    if (index < 0) {
      throw ArgumentError.value(reference, 'reference', 'Not a child');
    }
    _children.insert(index, child);
    _attach(child);
  }

  /// Removes [child] if it is a direct child.
  ///
  /// Удаляет [child], если это прямой потомок.
  bool removeChild(SvgNode child) {
    final removed = _children.remove(child);
    if (removed) _detach(child);
    return removed;
  }

  /// Removes all children.
  ///
  /// Удаляет всех детей.
  void clearChildren() {
    List<SvgNode>.from(_children).forEach(removeChild);
  }

  /// Replaces [oldChild] with [newChild].
  ///
  /// Заменяет [oldChild] на [newChild].
  void replaceChild(SvgNode oldChild, SvgNode newChild) {
    final index = _children.indexOf(oldChild);
    if (index < 0) {
      throw ArgumentError.value(oldChild, 'oldChild', 'Not a child');
    }
    oldChild.remove();
    newChild.remove();
    _children.insert(index, newChild);
    _attach(newChild);
  }

  @override
  void remove() {
    _parent?.removeChild(this);
  }

  @override
  SvgElement clone() {
    final copy = SvgElement(name, attributes: attributes);
    for (final child in _children) {
      copy.appendChild(child.clone());
    }
    return copy;
  }

  /// First descendant element with [id], or `null`.
  ///
  /// Первый потомок с [id] или `null`.
  SvgElement? getElementById(String id) =>
      queryElements(this, idSelector: id).firstOrNull;

  /// Descendant elements with local name [name] (case-sensitive).
  ///
  /// Потомки с локальным именем [name] (с учётом регистра).
  List<SvgElement> getElementsByTagName(String name) =>
      queryElements(this, tag: name).toList();

  /// First match of a simple CSS [selector], or `null`.
  ///
  /// Первое совпадение простого CSS-[selector] или `null`.
  SvgElement? querySelector(String selector) =>
      querySelectorAll(selector).firstOrNull;

  /// All matches of a simple CSS [selector].
  ///
  /// Все совпадения простого CSS-[selector].
  List<SvgElement> querySelectorAll(String selector) =>
      queryBySelector(this, selector).toList();

  void _attach(SvgNode child) {
    if (child is SvgElement) {
      child._parent = this;
    } else if (child is SvgText) {
      child.attach(this);
    }
  }

  void _detach(SvgNode child) {
    if (child is SvgElement) {
      child._parent = null;
    } else if (child is SvgText) {
      child.attach(null);
    }
  }

  @override
  String toString() => 'SvgElement($name, attrs: $attributes)';
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final it = iterator;
    return it.moveNext() ? it.current : null;
  }
}
