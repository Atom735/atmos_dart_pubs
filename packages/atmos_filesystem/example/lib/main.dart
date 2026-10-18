import 'dart:convert';
import 'dart:typed_data';

import 'package:atmos_filesystem/atmos_filesystem.dart';
import 'package:atmos_filesystem_web/atmos_filesystem_web.dart';
import 'package:atmos_web_files_system_access_api/atmos_web_files_system_access_api.dart';
import 'package:flutter/material.dart';

/// Flutter **web** demo: File System Access pickers + `atmos_filesystem`.
///
/// Run (Chromium recommended):
/// ```bash
/// cd packages/atmos_filesystem/example
/// flutter run -d chrome
/// ```
void main() {
  runApp(const AtmosFilesystemDemoApp());
}

class AtmosFilesystemDemoApp extends StatelessWidget {
  const AtmosFilesystemDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'atmos_filesystem',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1B6CA8)),
        useMaterial3: true,
      ),
      home: const _DemoPage(),
    );
  }
}

class _DemoPage extends StatefulWidget {
  const _DemoPage();

  @override
  State<_DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<_DemoPage> {
  final _fs = AtmosFileSystem();
  final _log = <String>[];
  final _editor = TextEditingController(
    text: 'Hello from atmos_filesystem\n',
  );
  final _relPath = TextEditingController(text: 'demo.txt');

  String? _rootName;
  List<(String name, int type)> _entries = const [];
  var _busy = false;

  bool get _fsaOk => isFileSystemAccessApiSupported;

  @override
  void dispose() {
    _editor.dispose();
    _relPath.dispose();
    super.dispose();
  }

  void _append(String line) {
    setState(() {
      _log.insert(0, '${TimeOfDay.now().format(context)}  $line');
      if (_log.length > 80) {
        _log.removeLast();
      }
    });
  }

  Future<void> _run(String label, Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      _append('→ $label');
      await action();
    } on FileSystemAccessAbortException {
      _append('cancelled');
    } on Object catch (e) {
      _append('error: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pickDirectory() async {
    await _run('directory picker', () async {
      final provider = await registerPickedDirectory(
        _fs,
        options: const DirectoryPickerOptions(mode: 'readwrite'),
      );
      _rootName = provider.root.name;
      await _refreshListing();
      _append('root="${provider.root.name}" scheme=${provider.scheme}');
    });
  }

  Future<void> _refreshListing() async {
    final entries = await _fs.readDirectory(Uri.parse('fsa:///'));
    setState(() => _entries = entries);
  }

  Future<void> _openFiles() async {
    await _run('open file picker', () async {
      final handles = await showOpenFilePicker(
        const OpenFilePickerOptions(multiple: true),
      );
      if (handles.isEmpty) {
        _append('no files');
        return;
      }
      final parts = <String>[];
      for (final handle in handles) {
        final bytes = await handle.readAsBytes();
        parts.add(
          '--- ${handle.name} (${bytes.length} B) ---\n'
          '${utf8.decode(bytes, allowMalformed: true)}',
        );
      }
      setState(() => _editor.text = parts.join('\n\n'));
      _append('opened ${handles.length} file(s)');
    });
  }

  Future<void> _saveFile() async {
    await _run('save file picker', () async {
      final suggested = _relPath.text.trim().isEmpty
          ? 'demo.txt'
          : _relPath.text.trim();
      final handle = await showSaveFilePicker(
        SaveFilePickerOptions(
          suggestedName: suggested,
          types: const [
            FilePickerAcceptType(
              description: 'Text',
              accept: {
                'text/plain': ['.txt', '.md'],
              },
            ),
          ],
        ),
      );
      final bytes = Uint8List.fromList(utf8.encode(_editor.text));
      final writable = await handle.createWritable();
      await writable.writeBytes(bytes);
      await writable.close();
      _append('saved "${handle.name}" (${bytes.length} B)');
    });
  }

  Future<void> _writeViaFs() async {
    await _run('write via AtmosFileSystem (fsa://)', () async {
      final name = _relPath.text.trim();
      if (name.isEmpty) {
        throw StateError('Relative path is empty');
      }
      if (!_fs.schemes.contains('fsa')) {
        throw StateError('Pick a directory first');
      }
      final uri = Uri.parse('fsa:///$name');
      final bytes = Uint8List.fromList(utf8.encode(_editor.text));
      await _fs.writeFile(uri, bytes);
      await _refreshListing();
      _append('wrote $uri (${bytes.length} B)');
    });
  }

  Future<void> _readViaFs() async {
    await _run('read via AtmosFileSystem (fsa://)', () async {
      final name = _relPath.text.trim();
      if (name.isEmpty) {
        throw StateError('Relative path is empty');
      }
      if (!_fs.schemes.contains('fsa')) {
        throw StateError('Pick a directory first');
      }
      final uri = Uri.parse('fsa:///$name');
      final bytes = await _fs.readFile(uri);
      setState(() {
        _editor.text = utf8.decode(bytes, allowMalformed: true);
      });
      _append('read $uri (${bytes.length} B)');
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('atmos_filesystem · web'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                _fsaOk ? 'FSA: ok' : 'FSA: unsupported',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: _fsaOk
                      ? theme.colorScheme.primary
                      : theme.colorScheme.error,
                ),
              ),
            ),
          ),
        ],
      ),
      body: AbsorbPointer(
        absorbing: _busy,
        child: Row(
          children: [
            SizedBox(
              width: 320,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text('Pickers', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: _fsaOk ? _pickDirectory : null,
                    icon: const Icon(Icons.folder_open),
                    label: const Text('Directory'),
                  ),
                  const SizedBox(height: 8),
                  FilledButton.tonalIcon(
                    onPressed: _fsaOk ? _openFiles : null,
                    icon: const Icon(Icons.file_open),
                    label: const Text('Open file(s)'),
                  ),
                  const SizedBox(height: 8),
                  FilledButton.tonalIcon(
                    onPressed: _fsaOk ? _saveFile : null,
                    icon: const Icon(Icons.save_alt),
                    label: const Text('Save file'),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Via AtmosFileSystem',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _rootName == null
                        ? 'No directory root yet'
                        : 'Root: $_rootName',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _relPath,
                    decoration: const InputDecoration(
                      labelText: 'Relative path under root',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _readViaFs,
                          child: const Text('Read'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _writeViaFs,
                          child: const Text('Write'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('Listing fsa:///', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  if (_entries.isEmpty)
                    Text('— empty —', style: theme.textTheme.bodySmall)
                  else
                    ..._entries.map((e) {
                      final (name, type) = e;
                      final isDir = (type & FileType.directory) != 0;
                      return ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          isDir ? Icons.folder : Icons.insert_drive_file,
                          size: 20,
                        ),
                        title: Text(name),
                        onTap: isDir
                            ? null
                            : () {
                                _relPath.text = name;
                                _readViaFs();
                              },
                      );
                    }),
                ],
              ),
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Editor / preview',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _editor,
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'File contents…',
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text('Log', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Expanded(
                      flex: 2,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          border: Border.all(color: theme.dividerColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: _log.length,
                          itemBuilder: (context, i) => Text(
                            _log[i],
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
