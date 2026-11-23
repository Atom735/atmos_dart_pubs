part of 'vector_graphics_core.dart';

extension VgContainerX on VgContainer {
  int addPath(VgPath path) {
    for (var i = 0; i < paths.length; i++) {
      if (paths[i].isEquals(path, 0.5)) {
        return i;
      }
    }
    paths.add(path);
    return paths.length - 1;
  }

  int addPaint(VgPaint paint) {
    for (var i = 0; i < paints.length; i++) {
      if (paints[i].isEquals(paint, 0.5)) {
        return i;
      }
    }
    paints.add(paint);
    return paints.length - 1;
  }

  int addFrame(VgContainerFrame frame) {
    frames.add(frame);
    return frames.length - 1;
  }

  /// Слияние с другой контейнером.
  /// Возвращает индекс начала нового кадра.
  int mergeWith(VgContainer other) {
    var resultFrameIndex = 0;
    for (final frame in other.frames) {
      if (resultFrameIndex == 0) {
        resultFrameIndex = frames.length;
      }
      final resultDrawCalls = <VgDrawCall>[];
      for (final drawCall in frame.drawCalls) {
        switch (drawCall.type) {
          case VgDrawCallType.paint:
            final paint = drawCall as VgDrawCallPaint;
            final pathId = paint.pathId;
            var resultPathId = pathId;
            if (pathId != null) {
              resultPathId = addPath(other.paths[pathId]);
            }
            final paintId = paint.paintId;
            final resultPaintId = addPaint(other.paints[paintId]);
            resultDrawCalls.add(
              VgDrawCallPaint(
                pathId: resultPathId,
                paintId: resultPaintId,
              ),
            );
          case VgDrawCallType.groupBegin:
            resultDrawCalls.add(drawCall);
          case VgDrawCallType.groupEnd:
            resultDrawCalls.add(drawCall);
          case VgDrawCallType.clipPath:
            final clipPath = drawCall as VgDrawCallClipPath;
            final pathId = clipPath.pathId;
            final resultPathId = addPath(other.paths[pathId]);
            resultDrawCalls.add(
              VgDrawCallClipPath(
                pathId: resultPathId,
              ),
            );
        }
      }
      final resultFrame = VgContainerFrame(
        width: frame.width,
        height: frame.height,
        drawCalls: resultDrawCalls,
      );
      frames.add(resultFrame);
    }
    return resultFrameIndex;
  }
}
