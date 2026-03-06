import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_colors.dart';

TextStyle ultraLight = TextStyle(fontWeight: FontWeight.w100, fontSize: 12.h);

TextStyle light = TextStyle(fontWeight: FontWeight.w200, fontSize: 13.h);

TextStyle regular = TextStyle(fontWeight: FontWeight.w400, fontSize: 14.h);

TextStyle bold = TextStyle(fontWeight: FontWeight.w600, fontSize: 15.h);

TextStyle extraBold = TextStyle(fontWeight: FontWeight.w900, fontSize: 16.h);

TextStyle get bigTitle =>
    extraBold.copyWith(fontSize: 30, fontWeight: FontWeight.w700);
TextStyle get bigSubtitle => regular.copyWith(color: mediumGrey, fontSize: 16);
TextStyle get regularTitle =>
    bold.copyWith(fontSize: 18, fontWeight: FontWeight.w700);
