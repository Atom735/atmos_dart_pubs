import 'package:atmos_tiled_text_renderer/atmos_tiled_text_renderer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'code_card.dart';
import 'hello_world_lines.dart';

void main() {
  runApp(const HelloWorldGalleryApp());
}

class HelloWorldGalleryApp extends StatelessWidget {
  const HelloWorldGalleryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hello world',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF12141A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF569CD6),
          surface: Color(0xFF12141A),
        ),
      ),
      home: const HelloWorldGallery(),
    );
  }
}

class HelloWorldGallery extends StatefulWidget {
  const HelloWorldGallery({super.key});

  @override
  State<HelloWorldGallery> createState() => _HelloWorldGalleryState();
}

class _ReadyFace {
  _ReadyFace({
    required this.face,
    required this.manager,
    required this.lines,
  });

  final CodeFace face;
  final AtlasManager manager;
  final List<FlattenedLineCache> lines;
}

class _HelloWorldGalleryState extends State<HelloWorldGallery> {
  final List<_ReadyFace> _faces = <_ReadyFace>[];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _prepare();
    });
  }

  @override
  void dispose() {
    for (final face in _faces) {
      face.manager.dispose();
    }
    super.dispose();
  }

  Future<void> _prepare() async {
    if (!mounted) {
      return;
    }
    final ready = <_ReadyFace>[];
    try {
      final pixelRatio =
          View.of(context).devicePixelRatio.clamp(1, 4).toDouble();
      final lines = flattenHelloWorld();
      for (final face in codeFaces) {
        await _loadFace(face);
        final manager = AtlasManager(
          fontFamily: face.family,
          logicalFontSize: codeFontSize,
        );
        await manager.updateDpr(pixelRatio, defaultCodeLigatures);
        ready.add(
          _ReadyFace(face: face, manager: manager, lines: lines),
        );
      }
    } on Object catch (error) {
      for (final face in ready) {
        face.manager.dispose();
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _error = 'Не удалось запечь атлас: $error';
      });
      return;
    }
    if (!mounted) {
      for (final face in ready) {
        face.manager.dispose();
      }
      return;
    }
    setState(() {
      _faces
        ..clear()
        ..addAll(ready);
      _loading = false;
    });
  }

  Future<void> _loadFace(CodeFace face) async {
    final data = await rootBundle.load(face.asset);
    final loader = FontLoader(face.family)
      ..addFont(Future<ByteData>.value(data));
    await loader.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _ErrorPane(message: _error!)
                : _GalleryBody(faces: _faces),
      ),
    );
  }
}

class _GalleryBody extends StatelessWidget {
  const _GalleryBody({required this.faces});

  final List<_ReadyFace> faces;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          children: <Widget>[
            const Text(
              'Hello, World!',
              style: TextStyle(
                fontSize: 28,
                height: 1.2,
                fontWeight: FontWeight.w600,
                color: Color(0xFFF0F3F8),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Один и тот же блок из четырёх строк. Consolas и Courier New '
              'в репозиторий не входят. Liberation Mono стоит на метрике '
              'Courier New.',
              style: TextStyle(
                fontSize: 14,
                height: 1.45,
                color: Color(0xFFB7C0CC),
              ),
            ),
            const SizedBox(height: 20),
            for (final _ReadyFace face in faces) ...<Widget>[
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: AtlasCodeCard(
                  family: face.face.family,
                  note: face.face.note,
                  manager: face.manager,
                  lines: face.lines,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }
}

class _ErrorPane extends StatelessWidget {
  const _ErrorPane({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFFFF8A80), height: 1.4),
        ),
      ),
    );
  }
}
