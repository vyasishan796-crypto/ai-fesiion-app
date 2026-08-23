import 'package:flutter/material.dart';

class AppRadius {
  AppRadius._();

  static const BorderRadius none = BorderRadius.zero;
  static const BorderRadius xs = BorderRadius.all(Radius.circular(5));
  static const BorderRadius sm = BorderRadius.all(Radius.circular(8));
  static const BorderRadius md = BorderRadius.all(Radius.circular(11));
  static const BorderRadius lg = BorderRadius.all(Radius.circular(18));
  static const BorderRadius pill = BorderRadius.all(Radius.circular(9999));
  static const BorderRadius full = BorderRadius.all(Radius.circular(9999));

  static BorderRadius custom(double radius) =>
      BorderRadius.all(Radius.circular(radius));
}
