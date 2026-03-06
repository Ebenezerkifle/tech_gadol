import 'package:hive/hive.dart';

const String themeBox = 'theme';

class HiveBox {
  static Future<Box<T>> open<T>(String name) async {
    if (Hive.isBoxOpen(name)) {
      return Hive.box<T>(name);
    } else {
      return await Hive.openBox(name);
    }
  }
}
