import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tech_gadol/app/route.dart';
import 'package:tech_gadol/providers/theme/theme_provider.dart';
import 'package:tech_gadol/ui/common/app_theme.dart';

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await _initHive();
      _initErrorHandler();
      runApp(ProviderScope(child: MainApp()));
    },
    (error, stack) {
      if (error is NetworkException) {
        debugPrint('Network issue: ${error.message}');
      } else if (error is CacheException) {
        debugPrint('Cache issue: ${error.message}');
      } else {
        debugPrint('Unhandled error: $error');
      }
    },
  );
}

Future<void> _initHive() async {
  await Hive.initFlutter();
}

void _initErrorHandler() {
  // catches framework-level errors (UI-related, widget tree, build/render issues).
  FlutterError.onError = (details) {
    FlutterError.dumpErrorToConsole(details);
  };
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final router = ref.watch(goRouterProvider);
    return ScreenUtilInit(
      designSize: const Size(428, 926),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (BuildContext context, Widget? child) {
        final MediaQueryData mq = MediaQuery.of(context);
        const double maxScale = 1.2;
        final double currentFactor = mq.textScaler.scale(1.0);
        final double clampedFactor = currentFactor > maxScale
            ? maxScale
            : currentFactor;
        final TextScaler clampedScaler = TextScaler.linear(clampedFactor);
        final MediaQueryData cappedMq = mq.copyWith(textScaler: clampedScaler);
        return MediaQuery(data: cappedMq, child: child!);
      },
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Tech Gadol',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        routerConfig: router,
        themeMode: themeState.themeMode,
      ),
    );
  }
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
}

class CacheException implements Exception {
  final String message;
  CacheException(this.message);
}
