part of 'vector_graphics_core.dart';

/// Цвет.
///
/// Используется для хранения цвета в формате ARGB.
typedef VgColor = Color;

extension VgColorX on VgColor {
  /// Смешивание с альфа-каналом.
  VgColor blendOpacity(double opacity) => VgColor(
        value & 0x00FFFFFF | ((opacity * a).toInt() & 0xFF) << 24,
      );

  /// Сравнение с другим цветом.
  bool isEquals(VgColor other, [double delta = 1e-6]) => value == other.value;
}

extension VgListColorX on List<VgColor> {
  bool isEquals(List<VgColor> other, [double delta = 1e-6]) {
    if (length != other.length) return false;
    for (var i = 0; i < length; i++) {
      if (!this[i].isEquals(other[i], delta)) return false;
    }
    return true;
  }
}

extension VgColorXBinaryReader on VgBinaryReader {
  /// Чтение цвета.
  VgColor readVgColor() => VgColor(readUint32());
}

extension VgColorXBinaryWriter on VgBinaryWriter {
  /// Запись цвета.
  void writeVgColor(VgColor color) => writeUint32(color.value);
}
