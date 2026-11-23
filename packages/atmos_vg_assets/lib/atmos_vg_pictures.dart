// ignore_for_file: constant_identifier_names

library atmos_vg_pictures;

import 'dart:ui';

import 'package:atmos_vector_graphics_core/atmos_vector_graphics_core.dart';
import 'package:atmos_vector_graphics_flutter/atmos_vector_graphics_flutter.dart';
import 'package:flutter/widgets.dart';
// // // // // // // ### GENERATED_START_PARTS ###
// Сгенерировано с помощью <bin/atmos_vg_regenerate.dart>
// Не редактируйте эту секцию вручную.
part 'src/pictures/_pic.iomt_cgm_activate.svg.g.dart';
part 'src/pictures/_pic.iomt_cgm_install_1.svg.g.dart';
part 'src/pictures/_pic.iomt_cgm_install_1_child.svg.g.dart';
part 'src/pictures/_pic.iomt_cgm_install_1_full.svg.g.dart';
part 'src/pictures/_pic.iomt_cgm_install_2.svg.g.dart';
part 'src/pictures/_pic.iomt_cgm_install_3.svg.g.dart';
part 'src/pictures/_pic.iomt_cgm_install_4.svg.g.dart';
part 'src/pictures/_pic.iomt_cgm_install_5.svg.g.dart';
part 'src/pictures/_pic.iomt_cgm_new_pairing.svg.g.dart';
part 'src/pictures/_pic.iomt_cgm_refresh.svg.g.dart';
part 'src/pictures/_pic.iomt_cgm_serial_qr.svg.g.dart';
// ### GENERATED_END_PARTS ###


/// Базовый класс для векторных картинок (иллюстрации, не иконки).
abstract class AtmosPicturesVgBase {
  const AtmosPicturesVgBase();

  /// Контейнер векторной графики.
  VgContainer get vgContainer;

  /// Картинка для текущего билда.
  Picture get picture;

  /// Размер для текущего билда.
  Size get size => vgContainer.getSize(0);

  /// Получает картинку для заданного кадра.
  Picture getPicture() {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    vgContainer.renderToCanvas(canvas, size);
    return recorder.endRecording();
  }

  // ### GENERATED_START_STATICS ###
  // Сгенерировано с помощью <bin/atmos_vg_regenerate.dart>
  // Не редактируйте эту секцию вручную.
  static const pic_iomt_cgm_activate = //
      _pic_iomt_cgm_activate.$class;
  static const pic_iomt_cgm_install_1 = //
      _pic_iomt_cgm_install_1.$class;
  static const pic_iomt_cgm_install_1_child = //
      _pic_iomt_cgm_install_1_child.$class;
  static const pic_iomt_cgm_install_1_full = //
      _pic_iomt_cgm_install_1_full.$class;
  static const pic_iomt_cgm_install_2 = //
      _pic_iomt_cgm_install_2.$class;
  static const pic_iomt_cgm_install_3 = //
      _pic_iomt_cgm_install_3.$class;
  static const pic_iomt_cgm_install_4 = //
      _pic_iomt_cgm_install_4.$class;
  static const pic_iomt_cgm_install_5 = //
      _pic_iomt_cgm_install_5.$class;
  static const pic_iomt_cgm_new_pairing = //
      _pic_iomt_cgm_new_pairing.$class;
  static const pic_iomt_cgm_refresh = //
      _pic_iomt_cgm_refresh.$class;
  static const pic_iomt_cgm_serial_qr = //
      _pic_iomt_cgm_serial_qr.$class;
  // ### GENERATED_END_STATICS ###


  CustomPainter getCustomPainter() {
    return _PictureCustomPainter(vgContainer: this);
  }

  Widget getWidget() {
    return CustomPaint(
      size: size,
      painter: _PictureCustomPainter(vgContainer: this),
    );
  }

  Widget getWidgetWithAspectRatio() {
    return AspectRatio(
      aspectRatio: size.aspectRatio,
      child: getWidget(),
    );
  }
}

class _PictureCustomPainter extends CustomPainter {
  const _PictureCustomPainter({
    required this.vgContainer,
  });

  final AtmosPicturesVgBase vgContainer;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPicture(vgContainer.picture);
  }

  @override
  bool shouldRepaint(covariant _PictureCustomPainter oldDelegate) =>
      vgContainer != oldDelegate.vgContainer;
}
