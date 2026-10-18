# atmos_binary_buffer benchmarks

Microbenchmarks for reader/writer hot paths.

```bash
cd packages/atmos_binary_buffer
dart pub get
dart run benchmark/run.dart
```

Compare before/after optimization changes on the same machine and Dart SDK.
