import 'dart:async';

import 'package:atmos_web_js_utils/atmos_web_js_utils.dart';

import 'dom_list.dart';
import 'errors.dart';
import 'key_range.dart';
import 'request.dart';
import 'support.dart';
import 'values.dart';

/// Cursor walk order (`IDBCursor.direction`).
enum IdbCursorDirection {
  /// `"next"`.
  next('next'),

  /// `"nextunique"`.
  nextUnique('nextunique'),

  /// `"prev"`.
  prev('prev'),

  /// `"prevunique"`.
  prevUnique('prevunique');

  /// Wire value stored by IndexedDB.
  const IdbCursorDirection(this.jsName);

  /// JS direction string.
  final String jsName;
}

/// Transaction mode (`IDBTransaction.mode`).
enum IdbTransactionMode {
  /// `"readonly"`.
  readonly('readonly'),

  /// `"readwrite"`.
  readwrite('readwrite'),

  /// `"versionchange"` (upgrade transactions only).
  versionchange('versionchange');

  /// Wire value stored by IndexedDB.
  const IdbTransactionMode(this.jsName);

  /// JS mode string.
  final String jsName;
}

/// Commit durability (`IDBTransaction.durability`).
enum IdbDurability {
  /// `"default"`.
  browserDefault('default'),

  /// `"strict"`.
  strict('strict'),

  /// `"relaxed"`.
  relaxed('relaxed');

  /// Wire value stored by IndexedDB.
  const IdbDurability(this.jsName);

  /// JS durability string.
  final String jsName;
}

/// `indexedDB.databases()` entry.
class IdbDatabaseInfo {
  /// Creates an entry.
  const IdbDatabaseInfo({required this.name, required this.version});

  /// Database name.
  final String name;

  /// Schema version.
  final int version;
}

/// `IDBFactory` (`globalThis.indexedDB`, including workers).
class IdbFactory {
  /// Wraps a JS `IDBFactory`.
  IdbFactory(this.jsObject);

  /// Underlying JS factory.
  final Object jsObject;

  /// Opens [name].
  ///
  /// [version] must be `>= 1` when set. [onUpgradeNeeded] runs inside the
  /// `versionchange` transaction: create stores there, and only `await`
  /// IndexedDB requests (not timers or network).
  Future<IdbDatabase> open(
    String name, {
    int? version,
    FutureOr<void> Function(IdbUpgradeChange change)? onUpgradeNeeded,
    void Function(IdbVersionChange change)? onBlocked,
  }) {
    _ensureSupported();
    final upgradeError = _UpgradeFailure();
    final request = version == null
        ? jsCallMethod<Object>(jsObject, 'open', <Object?>[name])
        : jsCallMethod<Object>(jsObject, 'open', <Object?>[name, version]);
    if (onBlocked != null) {
      jsSetProperty(
        request,
        'onblocked',
        jsAllowInterop((Object event) {
          onBlocked(_versionChange(event, database: null));
        }),
      );
    }
    if (onUpgradeNeeded != null) {
      _bindUpgrade(request, onUpgradeNeeded, upgradeError);
    }
    final opened = completeRequest(request, (result) {
      if (result == null) {
        throw const IndexedDbException('Open succeeded without a database');
      }
      return IdbDatabase(result);
    });
    return opened.onError((Object error, StackTrace stack) {
      final cause = upgradeError.error;
      if (cause != null) {
        Error.throwWithStackTrace(cause, upgradeError.stack ?? stack);
      }
      Error.throwWithStackTrace(error, stack);
    });
  }

  /// Deletes [name]. Resolves when the database is gone.
  Future<void> deleteDatabase(
    String name, {
    void Function(IdbVersionChange change)? onBlocked,
  }) {
    _ensureSupported();
    final request = jsCallMethod<Object>(
      jsObject,
      'deleteDatabase',
      <Object?>[name],
    );
    if (onBlocked != null) {
      jsSetProperty(
        request,
        'onblocked',
        jsAllowInterop((Object event) {
          onBlocked(_versionChange(event, database: null));
        }),
      );
    }
    return completeRequest<void>(request, (Object? _) {});
  }

  /// Lists databases (`indexedDB.databases()`).
  ///
  /// Not implemented in every browser; throws [IndexedDbException] then.
  Future<List<IdbDatabaseInfo>> databases() async {
    _ensureSupported();
    if (!jsHasProperty(jsObject, 'databases')) {
      throw const IndexedDbException('indexedDB.databases() is not supported');
    }
    final result = jsCallMethod<Object>(jsObject, 'databases');
    final raw = await jsPromiseToFuture<Object>(result);
    final dart = fromJs(raw);
    if (dart is! List) return const <IdbDatabaseInfo>[];
    return <IdbDatabaseInfo>[
      for (final item in dart) _databaseInfo(item),
    ];
  }

  /// Compares two keys (`indexedDB.cmp`). `-1`, `0`, or `1`.
  int cmp(Object first, Object second) {
    _ensureSupported();
    final value = jsCallMethod<num>(
      jsObject,
      'cmp',
      <Object?>[toJs(first), toJs(second)],
    );
    return value.toInt();
  }
}

/// Open connection (`IDBDatabase`).
class IdbDatabase {
  /// Wraps a JS `IDBDatabase`.
  IdbDatabase(this.jsObject);

  /// Underlying JS database.
  final Object jsObject;

  /// Database name.
  String get name => jsGetProperty<String>(jsObject, 'name');

  /// Schema version.
  int get version => jsGetProperty<num>(jsObject, 'version').toInt();

  /// Store names in this database.
  List<String> get objectStoreNames {
    return readDomStringList(
      jsGetProperty<Object>(jsObject, 'objectStoreNames'),
    );
  }

  /// Closes the connection.
  void close() {
    jsCallMethod<Object?>(jsObject, 'close');
  }

  /// Called when another connection asks for a higher version.
  ///
  /// Close this connection so the other open can proceed.
  void handleVersionChange(void Function(IdbVersionChange change) handler) {
    jsSetProperty(
      jsObject,
      'onversionchange',
      jsAllowInterop((Object event) {
        handler(_versionChange(event, database: this));
      }),
    );
  }

  /// Called after [close] or an unexpected close.
  void handleClose(void Function() handler) {
    jsSetProperty(
      jsObject,
      'onclose',
      jsAllowInterop((Object event) {
        handler();
      }),
    );
  }

  /// Starts a transaction over [storeNames] (`String` or `Iterable<String>`).
  IdbTransaction transaction(
    Object storeNames, {
    IdbTransactionMode mode = IdbTransactionMode.readonly,
    IdbDurability? durability,
  }) {
    final names = _storeNames(storeNames);
    final args = <Object?>[names, mode.jsName];
    if (durability != null) {
      final options = jsNewObject();
      jsSetProperty(options, 'durability', durability.jsName);
      args.add(options);
    }
    try {
      final js = jsCallMethod<Object>(jsObject, 'transaction', args);
      return IdbTransaction(js);
    } on IndexedDbException {
      rethrow;
    } on Object catch (error) {
      throw wrapIndexedDbError(error, 'transaction failed');
    }
  }

  /// Creates a store. Only valid inside `onUpgradeNeeded`.
  IdbObjectStore createObjectStore(
    String name, {
    Object? keyPath,
    bool autoIncrement = false,
  }) {
    final args = <Object?>[name];
    if (keyPath != null || autoIncrement) {
      final options = jsNewObject();
      if (keyPath != null) {
        jsSetProperty(options, 'keyPath', _keyPathJs(keyPath));
      }
      if (autoIncrement) {
        jsSetProperty(options, 'autoIncrement', true);
      }
      args.add(options);
    }
    try {
      final store = jsCallMethod<Object>(
        jsObject,
        'createObjectStore',
        args,
      );
      return IdbObjectStore(store);
    } on Object catch (error) {
      throw wrapIndexedDbError(error, 'createObjectStore failed');
    }
  }

  /// Deletes a store. Only valid inside `onUpgradeNeeded`.
  void deleteObjectStore(String name) {
    try {
      jsCallMethod<Object?>(
        jsObject,
        'deleteObjectStore',
        <Object?>[name],
      );
    } on Object catch (error) {
      throw wrapIndexedDbError(error, 'deleteObjectStore failed');
    }
  }
}

/// Version-change transaction passed to `onUpgradeNeeded`.
class IdbUpgradeChange {
  /// Creates an upgrade view.
  IdbUpgradeChange({
    required this.database,
    required this.transaction,
    required this.oldVersion,
    required this.newVersion,
  });

  /// Database being upgraded.
  final IdbDatabase database;

  /// `versionchange` transaction.
  final IdbTransaction transaction;

  /// Version before this open. `0` when the database is new.
  final int oldVersion;

  /// Version requested by `open`.
  final int newVersion;
}

/// `versionchange` / `blocked` details.
class IdbVersionChange {
  /// Creates a version-change notice.
  IdbVersionChange({
    required this.oldVersion,
    required this.newVersion,
    this.database,
  });

  /// Previous version.
  final int oldVersion;

  /// Requested version, or null when the database is being deleted.
  final int? newVersion;

  /// Connection this notice belongs to, when there is one.
  final IdbDatabase? database;
}

/// `IDBTransaction`.
class IdbTransaction {
  /// Wraps a JS `IDBTransaction`.
  IdbTransaction(this.jsObject) : completed = _bindCompleted(jsObject) {
    unawaited(completed.catchError((Object _) {}));
  }

  /// Underlying JS transaction.
  final Object jsObject;

  /// Completes on `complete`, or with [IndexedDbException] on `abort`.
  ///
  /// The error is marked handled so ignoring this future does not become an
  /// uncaught async error. `await` still surfaces the abort.
  final Future<void> completed;

  /// Database that owns this transaction.
  IdbDatabase get database {
    return IdbDatabase(jsGetProperty<Object>(jsObject, 'db'));
  }

  /// `readonly`, `readwrite`, or `versionchange`.
  IdbTransactionMode get mode {
    final name = jsGetProperty<String>(jsObject, 'mode');
    for (final item in IdbTransactionMode.values) {
      if (item.jsName == name) return item;
    }
    return IdbTransactionMode.readonly;
  }

  /// Commit durability.
  IdbDurability get durability {
    final name = jsGetProperty<String>(jsObject, 'durability');
    for (final item in IdbDurability.values) {
      if (item.jsName == name) return item;
    }
    return IdbDurability.browserDefault;
  }

  /// Stores locked by this transaction.
  List<String> get objectStoreNames {
    return readDomStringList(
      jsGetProperty<Object>(jsObject, 'objectStoreNames'),
    );
  }

  /// Transaction error, or null.
  IndexedDbException? get error {
    final raw = jsGetProperty<Object?>(jsObject, 'error');
    if (raw == null) return null;
    return wrapIndexedDbError(raw, 'Transaction error');
  }

  /// Store locked by this transaction.
  IdbObjectStore objectStore(String name) {
    final store = jsCallMethod<Object>(
      jsObject,
      'objectStore',
      <Object?>[name],
    );
    return IdbObjectStore(store);
  }

  /// Rolls the transaction back.
  void abort() {
    jsCallMethod<Object?>(jsObject, 'abort');
  }

  /// Commits before the automatic commit.
  void commit() {
    jsCallMethod<Object?>(jsObject, 'commit');
  }

  static Future<void> _bindCompleted(Object js) {
    final completer = Completer<void>();
    listenJs(js, 'complete', (Object event) {
      if (!completer.isCompleted) completer.complete();
    });
    listenJs(js, 'abort', (Object event) {
      if (completer.isCompleted) return;
      final error = jsGetProperty<Object?>(js, 'error');
      completer.completeError(
        wrapIndexedDbError(error, 'Transaction aborted'),
      );
    });
    return completer.future;
  }
}

/// `IDBObjectStore`.
class IdbObjectStore with _Query {
  /// Wraps a JS `IDBObjectStore`.
  IdbObjectStore(this.jsObject);

  @override
  final Object jsObject;

  /// Store name.
  String get name => jsGetProperty<String>(jsObject, 'name');

  /// In-line key path, or null for out-of-line keys.
  Object? get keyPath => fromJs(jsGetProperty<Object?>(jsObject, 'keyPath'));

  /// Whether the store generates keys.
  bool get autoIncrement => jsGetProperty<bool>(jsObject, 'autoIncrement');

  /// Index names on this store.
  List<String> get indexNames {
    return readDomStringList(jsGetProperty<Object>(jsObject, 'indexNames'));
  }

  /// Transaction that produced this store.
  IdbTransaction get transaction {
    return IdbTransaction(jsGetProperty<Object>(jsObject, 'transaction'));
  }

  /// Inserts [value]. Fails if the key already exists (`add`).
  Future<Object?> add(Object? value, [Object? key]) {
    return _mutate('add', value, key);
  }

  /// Inserts or replaces [value] (`put`).
  Future<Object?> put(Object? value, [Object? key]) {
    return _mutate('put', value, key);
  }

  /// Deletes every record.
  Future<void> clear() {
    return _voidRequest(jsObject, 'clear', const <Object?>[]);
  }

  /// Creates an index. Only valid inside `onUpgradeNeeded`.
  IdbIndex createIndex(
    String name,
    Object keyPath, {
    bool unique = false,
    bool multiEntry = false,
  }) {
    final options = jsNewObject();
    jsSetProperty(options, 'unique', unique);
    jsSetProperty(options, 'multiEntry', multiEntry);
    try {
      final index = jsCallMethod<Object>(
        jsObject,
        'createIndex',
        <Object?>[name, _keyPathJs(keyPath), options],
      );
      return IdbIndex(index);
    } on Object catch (error) {
      throw wrapIndexedDbError(error, 'createIndex failed');
    }
  }

  /// Deletes an index. Only valid inside `onUpgradeNeeded`.
  void deleteIndex(String name) {
    try {
      jsCallMethod<Object?>(jsObject, 'deleteIndex', <Object?>[name]);
    } on Object catch (error) {
      throw wrapIndexedDbError(error, 'deleteIndex failed');
    }
  }

  /// Existing index named [name].
  IdbIndex index(String name) {
    final index = jsCallMethod<Object>(jsObject, 'index', <Object?>[name]);
    return IdbIndex(index);
  }

  Future<Object?> _mutate(String method, Object? value, Object? key) {
    final args = <Object?>[toJs(value)];
    if (key != null) args.add(toJs(key));
    return _request(jsObject, method, args, fromJs);
  }
}

/// `IDBIndex`.
class IdbIndex with _Query {
  /// Wraps a JS `IDBIndex`.
  IdbIndex(this.jsObject);

  @override
  final Object jsObject;

  /// Index name.
  String get name => jsGetProperty<String>(jsObject, 'name');

  /// Indexed key path.
  Object? get keyPath => fromJs(jsGetProperty<Object?>(jsObject, 'keyPath'));

  /// Whether keys must be unique.
  bool get unique => jsGetProperty<bool>(jsObject, 'unique');

  /// Whether array values are indexed per element.
  bool get multiEntry => jsGetProperty<bool>(jsObject, 'multiEntry');

  /// Store this index belongs to.
  IdbObjectStore get objectStore {
    return IdbObjectStore(jsGetProperty<Object>(jsObject, 'objectStore'));
  }
}

/// Shared `get` / cursor methods of a store and an index.
mixin _Query {
  /// Underlying JS store or index.
  Object get jsObject;

  /// One value (`get`). Null when nothing matches.
  Future<Object?> get(Object? query) {
    return _request(jsObject, 'get', <Object?>[_queryArg(query)], fromJs);
  }

  /// Key of one record (`getKey`).
  Future<Object?> getKey(Object? query) {
    return _request(jsObject, 'getKey', <Object?>[_queryArg(query)], fromJs);
  }

  /// Values (`getAll`). [count] limits the page size.
  Future<List<Object?>> getAll([Object? query, int? count]) {
    return _request(
      jsObject,
      'getAll',
      _queryCount(query, count),
      _asList,
    );
  }

  /// Keys (`getAllKeys`). [count] limits the page size.
  Future<List<Object?>> getAllKeys([Object? query, int? count]) {
    return _request(
      jsObject,
      'getAllKeys',
      _queryCount(query, count),
      _asList,
    );
  }

  /// Deletes one key or every key in a range.
  Future<void> delete(Object? query) {
    return _voidRequest(jsObject, 'delete', <Object?>[_queryArg(query)]);
  }

  /// How many records match [query] (all of them when omitted).
  Future<int> count([Object? query]) {
    final args =
        query == null ? const <Object?>[] : <Object?>[_queryArg(query)];
    return _request(jsObject, 'count', args, (result) {
      if (result is num) return result.toInt();
      return 0;
    });
  }

  /// Value cursor (`openCursor`). Null when nothing matches.
  Future<IdbCursor?> openCursor({
    Object? query,
    IdbCursorDirection? direction,
  }) {
    return _request(
      jsObject,
      'openCursor',
      _cursorArgs(query, direction),
      _cursorOrNull,
    );
  }

  /// Key cursor (`openKeyCursor`). [IdbCursor.value] is null.
  Future<IdbCursor?> openKeyCursor({
    Object? query,
    IdbCursorDirection? direction,
  }) {
    return _request(
      jsObject,
      'openKeyCursor',
      _cursorArgs(query, direction),
      _cursorOrNull,
    );
  }
}

/// `IDBCursor` / `IDBCursorWithValue`.
class IdbCursor {
  /// Wraps a JS cursor.
  IdbCursor(this.jsObject);

  /// Underlying JS cursor.
  final Object jsObject;

  /// Walk direction.
  IdbCursorDirection get direction {
    final name = jsGetProperty<String>(jsObject, 'direction');
    for (final item in IdbCursorDirection.values) {
      if (item.jsName == name) return item;
    }
    return IdbCursorDirection.next;
  }

  /// Key at the current position (index key when walking an index).
  Object? get key => fromJs(jsGetProperty<Object?>(jsObject, 'key'));

  /// Primary key at the current position.
  Object? get primaryKey {
    return fromJs(jsGetProperty<Object?>(jsObject, 'primaryKey'));
  }

  /// Record value. Null for a key cursor.
  Object? get value {
    if (!jsHasProperty(jsObject, 'value')) return null;
    return fromJs(jsGetProperty<Object?>(jsObject, 'value'));
  }

  /// Store or index this cursor walks.
  Object get source {
    final raw = jsGetProperty<Object>(jsObject, 'source');
    if (jsHasProperty(raw, 'multiEntry')) return IdbIndex(raw);
    return IdbObjectStore(raw);
  }

  /// JS `continue`. [key] skips to that key.
  ///
  /// Null when the cursor is exhausted.
  Future<IdbCursor?> next([Object? key]) {
    return _step(() {
      if (key == null) {
        jsCallMethod<Object?>(jsObject, 'continue');
        return;
      }
      jsCallMethod<Object?>(jsObject, 'continue', <Object?>[toJs(key)]);
    });
  }

  /// JS `advance`.
  Future<IdbCursor?> advance(int count) {
    return _step(() {
      jsCallMethod<Object?>(jsObject, 'advance', <Object?>[count]);
    });
  }

  /// JS `continuePrimaryKey`.
  Future<IdbCursor?> continuePrimaryKey(Object key, Object primaryKey) {
    return _step(() {
      jsCallMethod<Object?>(
        jsObject,
        'continuePrimaryKey',
        <Object?>[toJs(key), toJs(primaryKey)],
      );
    });
  }

  /// Replaces the current value (`update`). Returns the key.
  Future<Object?> update(Object? value) {
    final request = jsCallMethod<Object>(
      jsObject,
      'update',
      <Object?>[toJs(value)],
    );
    return completeRequest(request, fromJs);
  }

  /// Deletes the current record.
  Future<void> delete() {
    final request = jsCallMethod<Object>(jsObject, 'delete');
    return completeRequest<void>(request, (Object? _) {});
  }

  Future<IdbCursor?> _step(void Function() action) {
    final request = jsGetProperty<Object>(jsObject, 'request');
    final future = completeRequest<IdbCursor?>(request, _cursorOrNull);
    action();
    return future;
  }
}

/// Browser `indexedDB` factory.
///
/// Throws [IndexedDbUnsupportedException] on the VM and in browsers without
/// IndexedDB.
IdbFactory get indexedDb {
  if (!isIndexedDbSupported) throw const IndexedDbUnsupportedException();
  return IdbFactory(jsGlobal('indexedDB')!);
}

/// Opens a database. See [IdbFactory.open].
Future<IdbDatabase> openIndexedDb(
  String name, {
  int? version,
  FutureOr<void> Function(IdbUpgradeChange change)? onUpgradeNeeded,
  void Function(IdbVersionChange change)? onBlocked,
}) async {
  return indexedDb.open(
    name,
    version: version,
    onUpgradeNeeded: onUpgradeNeeded,
    onBlocked: onBlocked,
  );
}

/// Deletes a database. See [IdbFactory.deleteDatabase].
Future<void> deleteIndexedDb(
  String name, {
  void Function(IdbVersionChange change)? onBlocked,
}) async {
  return indexedDb.deleteDatabase(name, onBlocked: onBlocked);
}

void _ensureSupported() {
  if (!isIndexedDbSupported) throw const IndexedDbUnsupportedException();
}

Object _storeNames(Object storeNames) {
  if (storeNames is String) return storeNames;
  if (storeNames is Iterable<String>) return jsArray(storeNames);
  throw ArgumentError(
    'storeNames must be a String or Iterable<String>, got $storeNames',
  );
}

Object _keyPathJs(Object keyPath) {
  if (keyPath is String) return keyPath;
  if (keyPath is Iterable<String>) return jsArray(keyPath);
  return keyPath;
}

Object? _queryArg(Object? query) {
  if (query == null) return null;
  if (query is IdbKeyRange) return query.jsObject;
  return toJs(query);
}

List<Object?> _queryCount(Object? query, int? count) {
  if (query == null && count == null) return const <Object?>[];
  if (count == null) return <Object?>[_queryArg(query)];
  return <Object?>[_queryArg(query), count];
}

List<Object?> _cursorArgs(Object? query, IdbCursorDirection? direction) {
  if (query == null && direction == null) return const <Object?>[];
  if (direction == null) return <Object?>[_queryArg(query)];
  return <Object?>[_queryArg(query), direction.jsName];
}

List<Object?> _asList(Object? result) {
  final value = fromJs(result);
  if (value is List) return List<Object?>.from(value);
  return const <Object?>[];
}

IdbCursor? _cursorOrNull(Object? result) {
  if (result == null) return null;
  return IdbCursor(result);
}

Future<T> _request<T>(
  Object target,
  String method,
  List<Object?> args,
  T Function(Object? result) map,
) {
  try {
    final request = jsCallMethod<Object>(target, method, args);
    return completeRequest(request, map);
  } on IndexedDbException {
    rethrow;
  } on Object catch (error) {
    throw wrapIndexedDbError(error, '$method failed');
  }
}

Future<void> _voidRequest(
  Object target,
  String method,
  List<Object?> args,
) async {
  await _request<Object?>(
    target,
    method,
    args,
    (Object? result) => result,
  );
}

IdbDatabaseInfo _databaseInfo(Object? item) {
  if (item is! Map) {
    throw const IndexedDbException('Bad databases() entry');
  }
  final name = item['name'];
  final version = item['version'];
  return IdbDatabaseInfo(
    name: name is String ? name : '',
    version: version is num ? version.toInt() : 0,
  );
}

IdbVersionChange _versionChange(
  Object event, {
  required IdbDatabase? database,
}) {
  return IdbVersionChange(
    oldVersion: readInt(event, 'oldVersion'),
    newVersion: readIntOrNull(event, 'newVersion'),
    database: database,
  );
}

void _bindUpgrade(
  Object request,
  FutureOr<void> Function(IdbUpgradeChange change) onUpgradeNeeded,
  _UpgradeFailure failure,
) {
  jsSetProperty(
    request,
    'onupgradeneeded',
    jsAllowInterop((Object event) {
      try {
        final transactionJs = jsGetProperty<Object>(request, 'transaction');
        final change = IdbUpgradeChange(
          database: IdbDatabase(jsGetProperty<Object>(request, 'result')),
          transaction: IdbTransaction(transactionJs),
          oldVersion: readInt(event, 'oldVersion'),
          newVersion: readInt(event, 'newVersion'),
        );
        final result = onUpgradeNeeded(change);
        if (result is Future<void>) {
          unawaited(
            result.then<void>(
              (_) {},
              onError: (Object error, StackTrace stack) {
                failure.error = error;
                failure.stack = stack;
                try {
                  change.transaction.abort();
                } on Object {
                  // The versionchange transaction may already be finished.
                }
              },
            ),
          );
        }
      } on Object catch (error, stack) {
        failure.error = error;
        failure.stack = stack;
        try {
          final transaction = jsGetProperty<Object>(request, 'transaction');
          jsCallMethod<Object?>(transaction, 'abort');
        } on Object {
          // Ignore a second failure while aborting.
        }
      }
    }),
  );
}

class _UpgradeFailure {
  Object? error;
  StackTrace? stack;
}
