/// 小萤 Agent · 日系漫画色板（墨黑 + 薄荷绿 + 暖纸白）。
///
/// 独立版专用：把原社区 Agent 的「深空蓝黑 + 极光青」整体换成
/// 「漫画墨黑 + 小萤薄荷绿」。工作台、会话抽屉、额度与账单同步生效。
library;

import 'package:flutter/material.dart';

class AfPalette {
  const AfPalette._();

  // ---- 底：墨黑，不用纯黑，留一点印刷纸感 ----
  static const int bg = 0xFF0A0C0B;
  static const int bg2 = 0xFF0F1311;
  static const int card = 0xFF141A16;
  static const int card2 = 0xFF1A211C;

  // ---- 线：暖纸白 ----
  static const int line = 0x1AF6F2E9; // 10%
  static const int lineStrong = 0x33F6F2E9; // 20%

  // ---- 文字：暖白，避免冷白破坏漫画纸张感 ----
  static const int text = 0xFFF6F2E9;
  static const int text2 = 0xB8F6F2E9; // 72%
  static const int text3 = 0x73F6F2E9; // 45%

  // ---- 主色：小萤薄荷绿 ----
  static const int accent = 0xFF7CE3B6;
  static const int accentDeep = 0xFF4FCB9B;
  static const int accentSoft = 0x1F7CE3B6; // 背景淡填充 12%
  static const int accentLine = 0x4D7CE3B6; // 描边 30%
  static const int accentLineStrong = 0x997CE3B6; // 描边 60%
  static const int onAccent = 0xFF06110C;

  // ---- 辅助 ----
  static const int warm = 0xFFF3C96B; // 额度提醒 / 重点标记（漫画高光黄）
  static const int ok = 0xFF7CE3B6;
  static const int danger = 0xFFFF6B7A;

  // ---- 渐变 ----
  static const LinearGradient accentGrad = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7CE3B6), Color(0xFF45B8A0)],
  );

  static const LinearGradient barGrad = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF45B8A0), Color(0xFF7CE3B6)],
  );

  /// 文件卡左侧竖条（自上而下淡出）
  static const LinearGradient edgeGrad = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF7CE3B6), Color(0x007CE3B6)],
  );

  /// 发送按钮光晕
  static List<BoxShadow> glow({double opacity = 0.32}) => [
    BoxShadow(
      color: const Color(AfPalette.accent).withValues(alpha: opacity),
      blurRadius: 16,
      spreadRadius: 0,
      offset: const Offset(0, 4),
    ),
  ];
}
