import 'package:flutter/material.dart';

abstract final class AppSpacing {
  static const none = 0.0;
  static const xxs = 2.0;
  static const xs = 4.0;
  static const sm = 6.0;
  static const md = 8.0;
  static const lg = 10.0;
  static const xl = 12.0;
  static const xxl = 14.0;
  static const gutter = 16.0;
  static const page = 20.0;
  static const loose = 24.0;
  static const section = 28.0;

  static const pageHorizontal = EdgeInsets.symmetric(horizontal: page);
  static const pageVertical = EdgeInsets.symmetric(vertical: loose);
  static const pageInsets = EdgeInsets.symmetric(
    horizontal: page,
    vertical: loose,
  );
  static const listVertical = EdgeInsets.symmetric(vertical: loose);
  static const card = EdgeInsets.all(page);
  static const panel = EdgeInsets.all(gutter);
  static const actionHorizontal = EdgeInsets.symmetric(horizontal: gutter);
  static const row = EdgeInsets.symmetric(horizontal: page, vertical: 18);
  static const compactRow = EdgeInsets.symmetric(
    horizontal: page,
    vertical: xxl,
  );
  static const formFieldGap = EdgeInsets.only(bottom: xl);
}
