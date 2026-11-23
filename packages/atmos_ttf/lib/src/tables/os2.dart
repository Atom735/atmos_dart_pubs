import 'dart:typed_data';

import 'package:atmos_binary_buffer/atmos_binary_buffer.dart';

/// OS/2 and Windows metrics table (`OS/2`) — version 0 subset for builders.
///
/// Таблица метрик OS/2 (`OS/2`) — подмножество version 0 для билдера.
class TtfOs2 {
  /// Creates an `OS/2` table.
  ///
  /// Создаёт таблицу `OS/2`.
  TtfOs2({
    this.version = 4,
    this.xAvgCharWidth = 500,
    this.usWeightClass = 400,
    this.usWidthClass = 5,
    this.fsType = 0,
    this.ySubscriptXSize = 650,
    this.ySubscriptYSize = 700,
    this.ySubscriptXOffset = 0,
    this.ySubscriptYOffset = 140,
    this.ySuperscriptXSize = 650,
    this.ySuperscriptYSize = 700,
    this.ySuperscriptXOffset = 0,
    this.ySuperscriptYOffset = 480,
    this.yStrikeoutSize = 50,
    this.yStrikeoutPosition = 300,
    this.sFamilyClass = 0,
    List<int>? panose,
    this.ulUnicodeRange1 = 0,
    this.ulUnicodeRange2 = 0,
    this.ulUnicodeRange3 = 0,
    this.ulUnicodeRange4 = 0,
    this.achVendId = 'ATMS',
    this.fsSelection = 0x40,
    this.usFirstCharIndex = 0,
    this.usLastCharIndex = 0,
    required this.sTypoAscender,
    required this.sTypoDescender,
    this.sTypoLineGap = 0,
    required this.usWinAscent,
    required this.usWinDescent,
    this.ulCodePageRange1 = 0,
    this.ulCodePageRange2 = 0,
    this.sxHeight = 0,
    this.sCapHeight = 0,
    this.usDefaultChar = 0,
    this.usBreakChar = 0x20,
    this.usMaxContext = 0,
  }) : panose = List<int>.unmodifiable(panose ?? List<int>.filled(10, 0));

  /// Parses an `OS/2` table (reads fields present for the version).
  ///
  /// Разбирает таблицу `OS/2` (поля по версии).
  factory TtfOs2.parse(Uint8List data) {
    final r = BinaryReader(data);
    final version = r.readUint16();
    final xAvgCharWidth = r.readInt16();
    final usWeightClass = r.readUint16();
    final usWidthClass = r.readUint16();
    final fsType = r.readUint16();
    final ySubscriptXSize = r.readInt16();
    final ySubscriptYSize = r.readInt16();
    final ySubscriptXOffset = r.readInt16();
    final ySubscriptYOffset = r.readInt16();
    final ySuperscriptXSize = r.readInt16();
    final ySuperscriptYSize = r.readInt16();
    final ySuperscriptXOffset = r.readInt16();
    final ySuperscriptYOffset = r.readInt16();
    final yStrikeoutSize = r.readInt16();
    final yStrikeoutPosition = r.readInt16();
    final sFamilyClass = r.readInt16();
    final panose = List<int>.generate(10, (_) => r.readUint8());
    final ulUnicodeRange1 = r.readUint32();
    final ulUnicodeRange2 = r.readUint32();
    final ulUnicodeRange3 = r.readUint32();
    final ulUnicodeRange4 = r.readUint32();
    final vend = String.fromCharCodes([
      r.readUint8(),
      r.readUint8(),
      r.readUint8(),
      r.readUint8(),
    ]);
    final fsSelection = r.readUint16();
    final usFirstCharIndex = r.readUint16();
    final usLastCharIndex = r.readUint16();
    final sTypoAscender = r.readInt16();
    final sTypoDescender = r.readInt16();
    final sTypoLineGap = r.readInt16();
    final usWinAscent = r.readUint16();
    final usWinDescent = r.readUint16();
    var ulCodePageRange1 = 0;
    var ulCodePageRange2 = 0;
    var sxHeight = 0;
    var sCapHeight = 0;
    var usDefaultChar = 0;
    var usBreakChar = 0x20;
    var usMaxContext = 0;
    if (version >= 1 && r.offset + 8 <= data.length) {
      ulCodePageRange1 = r.readUint32();
      ulCodePageRange2 = r.readUint32();
    }
    if (version >= 2 && r.offset + 10 <= data.length) {
      sxHeight = r.readInt16();
      sCapHeight = r.readInt16();
      usDefaultChar = r.readUint16();
      usBreakChar = r.readUint16();
      usMaxContext = r.readUint16();
    }
    return TtfOs2(
      version: version,
      xAvgCharWidth: xAvgCharWidth,
      usWeightClass: usWeightClass,
      usWidthClass: usWidthClass,
      fsType: fsType,
      ySubscriptXSize: ySubscriptXSize,
      ySubscriptYSize: ySubscriptYSize,
      ySubscriptXOffset: ySubscriptXOffset,
      ySubscriptYOffset: ySubscriptYOffset,
      ySuperscriptXSize: ySuperscriptXSize,
      ySuperscriptYSize: ySuperscriptYSize,
      ySuperscriptXOffset: ySuperscriptXOffset,
      ySuperscriptYOffset: ySuperscriptYOffset,
      yStrikeoutSize: yStrikeoutSize,
      yStrikeoutPosition: yStrikeoutPosition,
      sFamilyClass: sFamilyClass,
      panose: panose,
      ulUnicodeRange1: ulUnicodeRange1,
      ulUnicodeRange2: ulUnicodeRange2,
      ulUnicodeRange3: ulUnicodeRange3,
      ulUnicodeRange4: ulUnicodeRange4,
      achVendId: vend,
      fsSelection: fsSelection,
      usFirstCharIndex: usFirstCharIndex,
      usLastCharIndex: usLastCharIndex,
      sTypoAscender: sTypoAscender,
      sTypoDescender: sTypoDescender,
      sTypoLineGap: sTypoLineGap,
      usWinAscent: usWinAscent,
      usWinDescent: usWinDescent,
      ulCodePageRange1: ulCodePageRange1,
      ulCodePageRange2: ulCodePageRange2,
      sxHeight: sxHeight,
      sCapHeight: sCapHeight,
      usDefaultChar: usDefaultChar,
      usBreakChar: usBreakChar,
      usMaxContext: usMaxContext,
    );
  }

  /// Table version.
  final int version;

  /// Average char width.
  final int xAvgCharWidth;

  /// Weight class.
  final int usWeightClass;

  /// Width class.
  final int usWidthClass;

  /// Embedding fsType.
  final int fsType;

  /// Subscript X size.
  final int ySubscriptXSize;

  /// Subscript Y size.
  final int ySubscriptYSize;

  /// Subscript X offset.
  final int ySubscriptXOffset;

  /// Subscript Y offset.
  final int ySubscriptYOffset;

  /// Superscript X size.
  final int ySuperscriptXSize;

  /// Superscript Y size.
  final int ySuperscriptYSize;

  /// Superscript X offset.
  final int ySuperscriptXOffset;

  /// Superscript Y offset.
  final int ySuperscriptYOffset;

  /// Strikeout size.
  final int yStrikeoutSize;

  /// Strikeout position.
  final int yStrikeoutPosition;

  /// Family class.
  final int sFamilyClass;

  /// PANOSE bytes (10).
  final List<int> panose;

  /// Unicode range bitfield 1.
  final int ulUnicodeRange1;

  /// Unicode range bitfield 2.
  final int ulUnicodeRange2;

  /// Unicode range bitfield 3.
  final int ulUnicodeRange3;

  /// Unicode range bitfield 4.
  final int ulUnicodeRange4;

  /// Vendor id (4 chars).
  final String achVendId;

  /// Font selection flags.
  final int fsSelection;

  /// First char index.
  final int usFirstCharIndex;

  /// Last char index.
  final int usLastCharIndex;

  /// Typographic ascender.
  final int sTypoAscender;

  /// Typographic descender.
  final int sTypoDescender;

  /// Typographic line gap.
  final int sTypoLineGap;

  /// Windows ascent.
  final int usWinAscent;

  /// Windows descent.
  final int usWinDescent;

  /// Code page range 1.
  final int ulCodePageRange1;

  /// Code page range 2.
  final int ulCodePageRange2;

  /// x-height.
  final int sxHeight;

  /// Cap height.
  final int sCapHeight;

  /// Default character.
  final int usDefaultChar;

  /// Break character.
  final int usBreakChar;

  /// Max context.
  final int usMaxContext;

  /// Encodes version 4 table.
  ///
  /// Кодирует таблицу version 4.
  Uint8List encode() {
    final vend = achVendId.padRight(4).substring(0, 4);
    final w = BinaryWriter()
      ..writeUint16(version)
      ..writeInt16(xAvgCharWidth)
      ..writeUint16(usWeightClass)
      ..writeUint16(usWidthClass)
      ..writeUint16(fsType)
      ..writeInt16(ySubscriptXSize)
      ..writeInt16(ySubscriptYSize)
      ..writeInt16(ySubscriptXOffset)
      ..writeInt16(ySubscriptYOffset)
      ..writeInt16(ySuperscriptXSize)
      ..writeInt16(ySuperscriptYSize)
      ..writeInt16(ySuperscriptXOffset)
      ..writeInt16(ySuperscriptYOffset)
      ..writeInt16(yStrikeoutSize)
      ..writeInt16(yStrikeoutPosition)
      ..writeInt16(sFamilyClass);
    for (var i = 0; i < 10; i++) {
      w.writeUint8(i < panose.length ? panose[i] : 0);
    }
    w
      ..writeUint32(ulUnicodeRange1)
      ..writeUint32(ulUnicodeRange2)
      ..writeUint32(ulUnicodeRange3)
      ..writeUint32(ulUnicodeRange4)
      ..writeUint8(vend.codeUnitAt(0))
      ..writeUint8(vend.codeUnitAt(1))
      ..writeUint8(vend.codeUnitAt(2))
      ..writeUint8(vend.codeUnitAt(3))
      ..writeUint16(fsSelection)
      ..writeUint16(usFirstCharIndex)
      ..writeUint16(usLastCharIndex)
      ..writeInt16(sTypoAscender)
      ..writeInt16(sTypoDescender)
      ..writeInt16(sTypoLineGap)
      ..writeUint16(usWinAscent)
      ..writeUint16(usWinDescent)
      ..writeUint32(ulCodePageRange1)
      ..writeUint32(ulCodePageRange2)
      ..writeInt16(sxHeight)
      ..writeInt16(sCapHeight)
      ..writeUint16(usDefaultChar)
      ..writeUint16(usBreakChar)
      ..writeUint16(usMaxContext);
    return w.toBytes();
  }
}
