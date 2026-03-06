import 'package:flutter/material.dart';

const Color primaryColor = Color(0xFFF0546E);
const Color secondaryColor = Color(0xFF0b133d);
const Color accentColor = primaryColor;
const Color blackColor = Colors.black;
const Color darkGrey = Color(0xFF1A1B1E);
const Color mediumGrey = Color(0xFF474A54);
const Color lightGrey = Color.fromARGB(255, 187, 187, 187);
const Color veryLightGrey = Color(0xFFE3E3E3);
const Color backgroundColor = Color(0xfff4f4f4);
const Color whiteColor = Colors.white;
const Color dangerColor = Colors.redAccent;
const Color lightPrimaryColor = Color(0xffffc0ce);
const Color greenColor = Colors.green;
const Color theirdColor = Color(0xff0c1c35);

const shimmerGradient = LinearGradient(
  colors: [
    Color(0xFFEBEBF4),
    Color(0xFFF4F4F4),
    Color(0xFFEBEBF4),
    Color(0xFFF4F4F4),
  ],
  stops: [0.1, 0.3, 0.4, 0.8],
  begin: Alignment(-1.0, -1),
  end: Alignment(1.0, 1),
  tileMode: TileMode.repeated,
);

LinearGradient customeGradiant({
  required Color startColor,
  required Color endColor,
  begin = Alignment.topCenter,
  end = Alignment.bottomCenter,
}) => LinearGradient(colors: [startColor, endColor], begin: begin, end: end);

LinearGradient overlayGradiant(
  Color color, {
  begin = Alignment.bottomCenter,
  end = Alignment.center,
}) => LinearGradient(
  colors: [color, const Color.fromARGB(0, 255, 255, 255)],
  begin: begin,
  end: end,
);

RadialGradient radialGradiant() =>
    RadialGradient(colors: [primaryColor, primaryColor.withValues(alpha: .3)]);
