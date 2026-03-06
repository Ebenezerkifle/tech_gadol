import 'dart:async';

class AsyncCompleter {
  /// --------- Compeletor -----------
  ///
  void initialize() {
    _initialized.future;
  }

  final _initialized = Completer();
  Future<void> ensureInitialized() async => _initialized.future;
  void compelete() => _initialized.isCompleted ? null : _initialized.complete();

  /// --------- ********** -----------
}
