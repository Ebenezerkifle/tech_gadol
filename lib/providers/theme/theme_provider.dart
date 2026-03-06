import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/legacy.dart';
import 'package:tech_gadol/providers/theme/theme_state.dart';
import 'package:tech_gadol/services/hive_service/box.dart';
import 'package:tech_gadol/services/hive_service/offline_service.dart';

class ThemeNotifier extends StateNotifier<ThemeState> {
  final Ref ref;
  ThemeNotifier(this.ref) : super(const ThemeState()) {
    _init();
  }

  final _offlineService = OfflineService(boxName: themeBox);

  Future<void> _init() async {
    // set current theme
    bool isDark = await _offlineService.getDataStored(defaultValue: false);
    _setState(
      state.copyWith(themeMode: isDark ? ThemeMode.dark : ThemeMode.light),
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (state.themeMode == mode) return;
    bool isDark = mode == ThemeMode.dark;

    // let's store it now.
    _offlineService.storeDate(isDark);
    // change a state now
    _setState(
      state.copyWith(themeMode: isDark ? ThemeMode.dark : ThemeMode.light),
    );
  }

  ThemeState _setState(ThemeState newState) => state = newState;

  ThemeMode toggleTheme() {
    final current = state.themeMode;
    final next = current == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    setThemeMode(next);
    return next;
  }
}

final StateNotifierProvider<ThemeNotifier, ThemeState> themeProvider =
    StateNotifierProvider(ThemeNotifier.new);
