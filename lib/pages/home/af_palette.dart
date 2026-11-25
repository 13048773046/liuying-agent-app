/// 小萤 Agent · 纸白漫画色板。
library;

import 'package:flutter/material.dart';

class AfPalette {
  const AfPalette._();

  // 纸面
  static const int bg = 0xFFF6F1E6;
  static const int bg2 = 0xFFEFE8D9;
  static const int card = 0xFFFFFCF4;
  static const int card2 = 0xFFF3ECDD;

  // 墨线
  static const int line = 0x3314110E;
  static const int lineStrong = 0x6614110E;

  // 字
  static const int text = 0xFF14110E;
  static const int text2 = 0xCC14110E;
  static const int text3 = 0x9914110E;

  // 点色
  static const int accent = 0xFF2E8F73;
  static const int accentDeep = 0xFF1F705A;
  static const int accentSoft = 0xFFE2F1E9;
  static const int accentLine = 0x552E8F73;
  static const int accentLineStrong = 0xCC2E8F73;
  static const int onAccent = 0xFFFFFCF4;

  // 辅助
  static const int warm = 0xFFB7791F;
  static const int ok = 0xFF2E8F73;
  static const int danger = 0xFFC0392B;

  // 不再用渐变；保留字段供旧调用，统一为实色。
  static const LinearGradient accentGrad = LinearGradient(
    colors: [Color(accent), Color(accent)],
  );
  static const LinearGradient barGrad = LinearGradient(
    colors: [Color(accent), Color(accent)],
  );
  static const LinearGradient edgeGrad = LinearGradient(
    colors: [Color(accent), Color(accent)],
  );

  /// 旧“光晕”入口统一改成硬边错位阴影。
  static List<BoxShadow> glow({double opacity = 0.32}) => const [
    BoxShadow(color: Color(0xCC14110E), offset: Offset(3, 3), blurRadius: 0),
  ];
}
