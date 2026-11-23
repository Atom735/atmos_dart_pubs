import 'package:atmos_vector_graphics_core/atmos_vector_graphics_core.dart';
import 'package:test/test.dart';

void main() {
  test('empty container roundtrips through bytes', () {
    final original = VgContainer.empty();
    final bytes = original.toBytes();
    final restored = VgContainer.fromBytes(bytes);
    expect(restored.paths, isEmpty);
    expect(restored.paints, isEmpty);
    expect(restored.frames, isEmpty);
    expect(bytes.sublist(0, 4), 'GVG3'.codeUnits);
  });

  test('base64 roundtrip keeps magic', () {
    const original = VgContainer(
      paths: [],
      paints: [],
      frames: [
        VgContainerFrame(width: 24, height: 24, drawCalls: []),
      ],
    );
    final again = VgContainer.fromBase64(original.toBase64());
    expect(again.frames.single.width, 24);
    expect(again.frames.single.height, 24);
  });
}
