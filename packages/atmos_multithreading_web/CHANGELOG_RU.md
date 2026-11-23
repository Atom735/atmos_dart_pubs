# Changelog

English: [CHANGELOG.md](CHANGELOG.md).

## 0.1.0

- Первый релиз: пул `WebWorkerParallelExecutor` на dedicated workers
- `addWorker`, `runOn`, `mapAll`, `workerCount` (пул может стартовать пустым)
- Протокол через карты `ParallelMessage`
- `shareCounterBuffer` / `broadcastSharedBuffer` — SAB по ссылке
  (сырое JS-свойство, без `jsify` / без transfer list)
