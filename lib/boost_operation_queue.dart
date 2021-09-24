import 'dart:collection';

/// The operation's Priority in [BoostOperationQueue]
enum BoostOperationPriority {
  /// common priority operation will be add in the last of [BoostOperationQueue]
  common,

  /// high priority operation will be added in the first of [BoostOperationQueue]
  high,
}

/// The operation queue for flutter boost to store operation and execute the opeation
/// This queue is to solve issue:https://github.com/alibaba/flutter_boost/issues/1414
class BoostOperationQueue {
  static BoostOperationQueue instance = BoostOperationQueue._();

  BoostOperationQueue._();

  /// All operations
  final Queue<Function> _queue = DoubleLinkedQueue<Function>();

  /// Add an [operation] in queue,if the [priority] is [BoostOperationPriority.high],
  /// the [operation] will be exec first
  void add(Function operation, {BoostOperationPriority priority = BoostOperationPriority.common}) {
    assert(operation != null);
    if (priority == BoostOperationPriority.common) {
      _queue.add(operation);
    } else {
      _queue.addFirst(operation);
    }
  }

  /// Run all operation in queue
  void runTask() {
    while (_queue.isNotEmpty) {
      final Function operation = _queue.removeFirst();
      operation.call();
    }
  }
}
