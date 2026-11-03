import 'message.dart';

/// JS operations of one worker global. Implemented in the browser file.
abstract class WorkerHost {
  /// `self`.
  Object get jsObject;

  /// `message` events.
  Stream<WorkerScopeMessage> get messages;

  /// `self.name`.
  String get name;

  /// `self.postMessage`.
  void postMessage(Object? message, [List<Object>? transfer]);

  /// `self.importScripts`.
  void importScripts(Iterable<String> urls);

  /// `self.close`.
  void close();
}
