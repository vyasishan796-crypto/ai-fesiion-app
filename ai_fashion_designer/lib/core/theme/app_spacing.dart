import 'package:flutter/material.dart';

class AppSpacing {
  AppSpacing._();

  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 17;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double section = 80;

  static const EdgeInsets paddingXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);
  static const EdgeInsets paddingXxl = EdgeInsets.all(xxl);
  static const EdgeInsets paddingSection = EdgeInsets.all(section);

  static const EdgeInsets paddingHorizontalSm = EdgeInsets.symmetric(horizontal: xs);
  static const EdgeInsets paddingHorizontalMd = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets paddingHorizontalLg = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets paddingHorizontalXl = EdgeInsets.symmetric(horizontal: xl);

  static const EdgeInsets paddingVerticalSm = EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets paddingVerticalMd = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets paddingVerticalLg = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets paddingVerticalXl = EdgeInsets.symmetric(vertical: xl);
  static const EdgeInsets paddingVerticalSection = EdgeInsets.symmetric(vertical: section);

  static SizedBox get heightXs => SizedBox(height: xs);
  static SizedBox get heightSm => SizedBox(height: sm);
  static SizedBox get heightMd => SizedBox(height: md);
  static SizedBox get heightLg => SizedBox(height: lg);
  static SizedBox get heightXl => SizedBox(height: xl);
  static SizedBox get heightXxl => SizedBox(height: xxl);

  static SizedBox get widthXs => SizedBox(width: xs);
  static SizedBox get widthSm => SizedBox(width: sm);
  static SizedBox get widthMd => SizedBox(width: md);
  static SizedBox get widthLg => SizedBox(width: lg);
  static SizedBox get widthXl => SizedBox(width: xl);
}
