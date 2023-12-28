import 'package:flutter/material.dart';

class MyColors {
  static const Color light = Color(0xFFFFFFFF);
  static const Color dark = Color(0xFF333333);
  static const Color primary = Color(0xFFF05C3E);
  static const Color secondary = Color(0xFF04B0BA);

  static Color background(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light ? light : dark;
  }

  static Color text(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light ? dark : light;
  }


}