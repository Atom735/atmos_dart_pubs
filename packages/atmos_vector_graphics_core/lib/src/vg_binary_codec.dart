part of 'vector_graphics_core.dart';

typedef VgBinaryReader = BinaryReader;
typedef VgBinaryWriter = BinaryWriter;

extension VgBinaryReaderX on BinaryReader {
  double readFloat16() {
    return _fp16ToDouble(readUint16());
  }

  List<double> readListFloat16({
    int csz = 0,
    int? size,
  }) {
    return readList((i, reader) => reader.readFloat16(), csz: csz, size: size);
  }
}

extension VgBinaryWriterX on BinaryWriter {
  void writeFloat16(double d) {
    writeUint16(_doubleToFP16(d));
  }

  void writeListFloat16(
    List<double> list, {
    int csz = 0,
    int? size,
  }) {
    writeList(
      list,
      (e, i, writer) => writer.writeFloat16(e),
      csz: csz,
      size: size,
    );
  }
}

/// Конвертирует double в FP16 (16-битное число с плавающей точкой)
int _doubleToFP16(double value) {
  // Получаем битовое представление double
  final bytes = ByteData(8)..setFloat64(0, value);
  final bits = bytes.getInt64(0);

  // Извлекаем компоненты
  final sign = (bits >> 63) & 0x1;
  final exponent = ((bits >> 52) & 0x7FF) - 1023; // Смещение для double
  final mantissa = bits & 0xFFFFFFFFFFFFF;

  // Преобразуем в формат FP16
  var fp16Exponent = exponent + 15; // Смещение для FP16
  var fp16Mantissa = (mantissa >> 42) & 0x3FF; // Округляем до 10 бит

  // Обработка специальных случаев
  if (exponent == 1024) {
    // Бесконечность или NaN
    fp16Exponent = 31;
    fp16Mantissa = 0;
  } else if (exponent < -14) {
    // Денормализованное число
    fp16Exponent = 0;
    fp16Mantissa = 1;
  } else if (exponent > 15) {
    // Переполнение
    fp16Exponent = 31;
    fp16Mantissa = 0;
  }

  // Собираем FP16
  return (sign << 15) | (fp16Exponent << 10) | fp16Mantissa;
}

/// Конвертирует FP16 обратно в double
double _fp16ToDouble(int fp16) {
  // Извлекаем компоненты FP16
  final sign = (fp16 >> 15) & 0x1;
  final exponent = ((fp16 >> 10) & 0x1F) - 15;
  final mantissa = fp16 & 0x3FF;

  // Обработка специальных случаев
  if (exponent == 31) {
    if (mantissa == 0) {
      return sign == 0 ? double.infinity : double.negativeInfinity;
    } else {
      return double.nan;
    }
  }

  // Собираем double
  final doubleBits =
      (sign << 63) | ((exponent + 1023) << 52) | (mantissa << 42);

  final bytes = ByteData(8);
  bytes.setInt64(0, doubleBits);
  return bytes.getFloat64(0);
}
