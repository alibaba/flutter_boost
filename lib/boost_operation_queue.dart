import 'dart:collection';

/// The operation queue for flutter boost to store operation and execute the opeation
/// This queue is to solve issue:https://github.com/alibaba/flutter_boost/issues/1414
class BoostOperationQueue {
  static BoostOperationQueue instance = BoostOperationQueue._();

  BoostOperationQueue._();

  /// All operations
  final Queue<Function> _queue = DoubleLinkedQueue<Function>();

  /// Add an [operation] in queue
  void addPendingOperation(Function operation) {
    assert(operation != null);
    _queue.add(operation);
  }

  /// Run all operation in queue
  void runPendingOperations() {
    while (_queue.isNotEmpty) {
      final Function operation = _queue.removeFirst();
      operation.call();
    }
  }
}
