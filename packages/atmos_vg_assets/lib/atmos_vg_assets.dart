// ignore_for_file: constant_identifier_names

library atmos_vg_assets;

export 'src/flavors.dart';

import 'dart:ui';

import 'package:atmos_vector_graphics_core/atmos_vector_graphics_core.dart';
import 'package:atmos_vector_graphics_flutter/atmos_vector_graphics_flutter.dart';
import 'package:flutter/widgets.dart';

import 'atmos_vg_icons.dart';
import 'atmos_vg_pictures.dart';
import 'src/flavors.dart';

part 'src/ic_account_menu_item_app_version.g.dart';
part 'src/ic_account_menu_item_documents.g.dart';
// ### GENERATED_START_PARTS ###
// Сгенерировано с помощью <configs/cfg_gvg.dart>
// Не редактируйте эту секцию вручную.
part 'src/ic_account_menu_item_logout.g.dart';
part 'src/ic_account_menu_item_profile.g.dart';
part 'src/ic_auth_app_logo.g.dart';
part 'src/ic_illustration_consultation_canceled.g.dart';
part 'src/ic_illustration_consultation_new.g.dart';
part 'src/ic_illustration_empty.g.dart';
part 'src/ic_illustration_error.g.dart';
part 'src/ic_main_navigation_account.g.dart';
part 'src/ic_main_navigation_appointment.g.dart';
part 'src/ic_main_navigation_events.g.dart';
part 'src/ic_main_navigation_support_chat.g.dart';
part 'src/ic_illustration_free.g.dart';
part 'src/ic_illustration_login.g.dart';
part 'src/ic_illustration_phone.g.dart';
part 'src/ic_illustration_protection.g.dart';
part 'src/ic_illustration_update.g.dart';
part 'src/ic_monitorings_empty.g.dart';
part 'src/ic_profile_snils.g.dart';
part 'src/ic_profile_passport.g.dart';
part 'src/ic_profile_insurance_policy.g.dart';
// ### GENERATED_END_PARTS ###

typedef AssetsVg = AtmosAssetsVgBase;
typedef IconsVg = AtmosIconsVgBase;
typedef PicturesVg = AtmosPicturesVgBase;

/// Базовый класс для векторных графиков.
abstract class AtmosAssetsVgBase {
  const AtmosAssetsVgBase();

  /// Контейнер векторной графики.
  VgContainer get vgContainer;

  /// Кадр для текущего билда.
  int get flavorFrame;

  /// Картинка для текущего билда.
  Picture? get flavorPicture;

  /// Размер для текущего билда.
  Size get flavorSize;

  /// Картинки для всех билдов.
  Map<AtmosVgFlavor, int> get frameIndexes;

  /// Получает картинку для заданного кадра.
  Picture? getPicture(int frameIndex) {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    vgContainer.renderToCanvas(
      canvas,
      getSize(frameIndex),
      frameIndex: frameIndex,
    );
    return recorder.endRecording();
  }

  /// Получает размер для заданного кадра.
  Size getSize(int frameIndex) {
    final frame = vgContainer.frames[frameIndex];
    return Size(frame.width, frame.height);
  }

  // ### GENERATED_START_STATICS ###
  // Сгенерировано с помощью <configs/cfg_gvg.dart>
  // Не редактируйте эту секцию вручную.
  static const ic_account_menu_item_documents =
      _ic_account_menu_item_documents.$class;
  static const ic_account_menu_item_app_version =
      _ic_account_menu_item_app_version.$class;
  static const ic_account_menu_item_logout =
      _ic_account_menu_item_logout.$class;
  static const ic_account_menu_item_profile =
      _ic_account_menu_item_profile.$class;
  static const ic_auth_app_logo = _ic_auth_app_logo.$class;
  static const ic_illustration_consultation_canceled =
      _ic_illustration_consultation_canceled.$class;
  static const ic_illustration_consultation_new =
      _ic_illustration_consultation_new.$class;
  static const ic_illustration_empty = _ic_illustration_empty.$class;
  static const ic_illustration_error = _ic_illustration_error.$class;
  static const ic_main_navigation_account = _ic_main_navigation_account.$class;
  static const ic_main_navigation_appointment =
      _ic_main_navigation_appointment.$class;
  static const ic_main_navigation_events = _ic_main_navigation_events.$class;
  static const ic_main_navigation_support_chat =
      _ic_main_navigation_support_chat.$class;
  static const ic_illustration_free = _ic_illustration_free.$class;
  static const ic_illustration_login = _ic_illustration_login.$class;
  static const ic_illustration_phone = _ic_illustration_phone.$class;
  static const ic_illustration_protection = _ic_illustration_protection.$class;
  static const ic_illustration_update = _ic_illustration_update.$class;
  static const ic_monitorings_empty = _ic_monitorings_empty.$class;
  static const ic_profile_snils = _ic_profile_snils.$class;
  static const ic_profile_passport = _ic_profile_passport.$class;
  static const ic_profile_insurance_policy =
      _ic_profile_insurance_policy.$class;
  // ### GENERATED_END_STATICS ###

  Widget getWidget({
    required AtmosVgFlavor? flavor,
  }) {
    return CustomPaint(
      size: getSizeFlavor(flavor),
      painter: GvgCustomPainter(vgContainer: this, flavor: flavor),
    );
  }

  Size getSizeFlavor(AtmosVgFlavor? flavor) {
    final frameIndex = flavor == null ? 0 : frameIndexes[flavor] ?? 0;
    return getSize(frameIndex);
  }

  Widget getWidgetWithAspectRatio({
    required AtmosVgFlavor? flavor,
  }) {
    final frameIndex = flavor == null ? 0 : frameIndexes[flavor] ?? 0;
    final size = getSize(frameIndex);
    return AspectRatio(
      aspectRatio: size.aspectRatio,
      child: getWidget(flavor: flavor),
    );
  }
}

class GvgCustomPainter extends CustomPainter {
  const GvgCustomPainter({
    required this.vgContainer,
    this.flavor,
  });

  final AtmosVgFlavor? flavor;

  final AtmosAssetsVgBase vgContainer;

  @override
  void paint(Canvas canvas, Size size) {
    if (flavor == null) {
      canvas.save();
      canvas.translate(size.width / 2, size.height / 2);
      canvas.translate(
        -vgContainer.flavorSize.width / 2,
        -vgContainer.flavorSize.height / 2,
      );
      canvas.scale(size.shortestSide / vgContainer.flavorSize.shortestSide);
      canvas.drawPicture(vgContainer.flavorPicture!);
      canvas.restore();
    } else {
      final frameIndex = vgContainer.frameIndexes[flavor] ?? 0;
      final picture = vgContainer.getPicture(frameIndex);
      canvas.drawPicture(picture!);
    }
  }

  @override
  bool shouldRepaint(covariant GvgCustomPainter oldDelegate) =>
      flavor != oldDelegate.flavor || vgContainer != oldDelegate.vgContainer;
}
