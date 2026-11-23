/// Библиотека векторной графики.
library atmos_vector_graphics_core;

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:atmos_binary_buffer/atmos_binary_buffer.dart';
import 'package:vector_graphics_compiler/vector_graphics_compiler.dart'
    show
        Color,
        Fill,
        Gradient,
        LinearGradient,
        Paint,
        PathFillType,
        Point,
        RadialGradient,
        Stroke,
        StrokeCap,
        StrokeJoin;

part 'vg_binary_codec.dart';
part 'vg_color.dart';
part 'vg_container.dart';
part 'vg_decoder.dart';
part 'vg_draw_call.dart';
part 'vg_group.dart';
part 'vg_merge.dart';
part 'vg_paint.dart';
part 'vg_path.dart';

typedef VgStrokeCap = StrokeCap;
typedef VgStrokeJoin = StrokeJoin;
typedef VgPathFillType = PathFillType;
