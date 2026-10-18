# Changelog

## 0.1.0

### EN

- Initial release: `WebWorkerParallelExecutor` pool over dedicated workers
- `addWorker`, `runOn`, `mapAll`, `workerCount` (pool may start empty)
- Wire protocol via `ParallelMessage` maps
- `shareCounterBuffer` / `broadcastSharedBuffer` — SAB shared by reference
  (raw JS property, not `jsify` / not transfer list)

### RU

- Первый релиз: пул `WebWorkerParallelExecutor` на dedicated workers
- `addWorker`, `runOn`, `mapAll`, `workerCount` (пул может стартовать пустым)
- Протокол через карты `ParallelMessage`
- `shareCounterBuffer` / `broadcastSharedBuffer` — SAB по ссылке
  (сырое JS-свойство, без `jsify` / без transfer list)
