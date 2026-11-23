# Changelog

Русский: [CHANGELOG_RU.md](CHANGELOG_RU.md).

## 0.1.0

- Initial release: `WebWorkerParallelExecutor` pool over dedicated workers
- `addWorker`, `runOn`, `mapAll`, `workerCount` (pool may start empty)
- Wire protocol via `ParallelMessage` maps
- `shareCounterBuffer` / `broadcastSharedBuffer` — SAB shared by reference
  (raw JS property, not `jsify` / not transfer list)
