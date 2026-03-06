import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData light = ThemeData(
    fontFamily: 'Roboto',
    primaryColor: const Color(0xFFF0546E),
    secondaryHeaderColor: const Color(0xFF1ED7AA),
    disabledColor: const Color(0xFFBABFC4),
    highlightColor: const Color.fromARGB(255, 132, 132, 132),
    brightness: Brightness.light,
    hintColor: const Color(0xFF9F9F9F),
    cardColor: const Color.fromARGB(255, 240, 240, 240),
    scaffoldBackgroundColor: const Color.fromARGB(255, 255, 255, 255),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: const Color(0xFFEF7822)),
    ),
    colorScheme:
        const ColorScheme.light(
              primary: Color(0xFFEF7822),
              secondary: Color(0xFFEF7822),
            )
            .copyWith(surface: const Color.fromARGB(255, 255, 255, 255))
            .copyWith(error: const Color(0xFFE84D4F)),
  );

  static final ThemeData dark = ThemeData(
    fontFamily: 'Roboto',
    primaryColor: const Color(0xffF0546E),
    secondaryHeaderColor: const Color(0xFF009f67),
    disabledColor: const Color(0xffa2a7ad),
    highlightColor: const Color.fromARGB(255, 132, 132, 132),
    brightness: Brightness.dark,
    hintColor: const Color(0xFFbebebe),
    scaffoldBackgroundColor: const Color.fromARGB(255, 13, 14, 14),
    cardColor: const Color.fromARGB(255, 39, 41, 45),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: const Color(0xFFffbd5c)),
    ),
    colorScheme:
        const ColorScheme.dark(
              primary: Color(0xFFffbd5c),
              secondary: Color(0xFFffbd5c),
            )
            .copyWith(surface: const Color.fromARGB(255, 13, 14, 14))
            .copyWith(error: const Color(0xFFdd3135)),
  );
}
