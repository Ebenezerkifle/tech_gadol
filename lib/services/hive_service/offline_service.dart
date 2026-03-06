import 'dart:async';

import 'package:hive/hive.dart';
import 'package:tech_gadol/services/hive_service/box.dart';

class OfflineService {
  late Box box;
  String boxName;

  OfflineService({required this.boxName}) {
    _openBox();
  }

  final _initialized = Completer();

  void _compelete() =>
      _initialized.isCompleted ? null : _initialized.complete();

  Future<void> ensureInitialized() async => _initialized.future;

  // open box.
  Future<void> _openBox<T>() async {
    _initialized.future;
    box = await HiveBox.open<T>(boxName);
    _compelete();
  }

  // store data
  Future<void> storeDate(dynamic data) async {
    await ensureInitialized();
    await box.put(boxName, data);
  }

  // get data.
  Future<dynamic> getDataStored({dynamic defaultValue}) async {
    await ensureInitialized();
    var data = await box.get(boxName, defaultValue: defaultValue);
    return data;
  }

  // clear data
  Future<void> clearStoredData() async {
    await ensureInitialized();
    await box.clear();
  }
}
