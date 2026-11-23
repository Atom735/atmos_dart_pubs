// ignore_for_file: constant_identifier_names

library atmos_vg_icons;

import 'dart:ui';

import 'package:atmos_vector_graphics_core/atmos_vector_graphics_core.dart';
import 'package:atmos_vector_graphics_flutter/atmos_vector_graphics_flutter.dart';
import 'package:flutter/widgets.dart';
// ### GENERATED_START_PARTS ###
// Сгенерировано с помощью <bin/atmos_vg_regenerate.dart>
// Не редактируйте эту секцию вручную.
part 'src/icons/_ic.allert_triangle.svg.g.dart';
part 'src/icons/_ic.arrow_left_chevron.svg.g.dart';
part 'src/icons/_ic.arrow_right_chevron.svg.g.dart';
part 'src/icons/_ic.arrows_exchange.svg.g.dart';
part 'src/icons/_ic.bluetooth_small.svg.g.dart';
part 'src/icons/_ic.calendar.svg.g.dart';
part 'src/icons/_ic.circle_check.svg.g.dart';
part 'src/icons/_ic.clock_thin.svg.g.dart';
part 'src/icons/_ic.cross.svg.g.dart';
part 'src/icons/_ic.filter.svg.g.dart';
part 'src/icons/_ic.flash_filled.svg.g.dart';
part 'src/icons/_ic.mood_confused.svg.g.dart';
part 'src/icons/_ic.no_wifi.svg.g.dart';
part 'src/icons/_ic.timeline.svg.g.dart';
// ### GENERATED_END_PARTS ###


/// Базовый класс для векторных графиков.
abstract class AtmosIconsVgBase {
  const AtmosIconsVgBase();

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
    vgContainer.renderToCanvas(
      canvas,
      size,
    );
    return recorder.endRecording();
  }

  // ### GENERATED_START_STATICS ###
  // Сгенерировано с помощью <bin/atmos_vg_regenerate.dart>
  // Не редактируйте эту секцию вручную.
  static const ic_allert_triangle = //
      _allert_triangle.$class;
  static const ic_arrow_left_chevron = //
      _arrow_left_chevron.$class;
  static const ic_arrow_right_chevron = //
      _arrow_right_chevron.$class;
  static const ic_arrows_exchange = //
      _arrows_exchange.$class;
  static const ic_bluetooth_small = //
      _bluetooth_small.$class;
  static const ic_calendar = //
      _calendar.$class;
  static const ic_circle_check = //
      _circle_check.$class;
  static const ic_clock_thin = //
      _clock_thin.$class;
  static const ic_cross = //
      _cross.$class;
  static const ic_filter = //
      _filter.$class;
  static const ic_flash_filled = //
      _flash_filled.$class;
  static const ic_mood_confused = //
      _mood_confused.$class;
  static const ic_no_wifi = //
      _no_wifi.$class;
  static const ic_timeline = //
      _timeline.$class;
  // ### GENERATED_END_STATICS ###


  CustomPainter getCustomPainter() {
    return _IconCustomPainter(vgContainer: this);
  }

  Widget getWidget() {
    return CustomPaint(
      size: size,
      painter: _IconCustomPainter(vgContainer: this),
    );
  }

  Widget getWidgetWithAspectRatio() {
    return AspectRatio(
      aspectRatio: size.aspectRatio,
      child: getWidget(),
    );
  }
}

class _IconCustomPainter extends CustomPainter {
  const _IconCustomPainter({
    required this.vgContainer,
  });

  final AtmosIconsVgBase vgContainer;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPicture(vgContainer.picture);
  }

  @override
  bool shouldRepaint(covariant _IconCustomPainter oldDelegate) =>
      vgContainer != oldDelegate.vgContainer;
}
