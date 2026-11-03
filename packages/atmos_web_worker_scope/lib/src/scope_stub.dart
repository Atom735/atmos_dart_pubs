import 'host.dart';

/// VM and other non-browser runtimes are not a worker.
bool get isDedicatedWorkerScope => false;

/// No worker global off the browser.
WorkerHost? tryAttach() => null;
