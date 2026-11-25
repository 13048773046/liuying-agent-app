/// 小萤 Agent · 日系漫画设计令牌
///
/// 纸白画布 + 墨黑硬线 + 薄荷绿点色。页面里的颜色、字号、间距都从这里取，
/// 不再使用霓虹青、发光、径向渐变或大面积的黑色 UI。
library;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppColors {
  const AppColors._();

  // ---- 纸面 ----
  static const int bg = 0xFFF6F1E6; // 暖纸白
  static const int canvas = 0xFFEFE8D9; // 次级纸面
  static const int card = 0xFFFFFCF4; // 分镜纸
  static const int elevated = 0xFFFFFFFF; // 输入/浮层纸
  static const int glass = 0xEFFFFCF4;

  // ---- 墨线 ----
  static const int border = 0x3314110E;
  static const int hairline = 0x1A14110E;

  // ---- 字 ----
  static const int textPrimary = 0xFF14110E;
  static const int textSecondary = 0xCC14110E;
  static const int textTertiary = 0x9914110E;
  static const int textDisabled = 0x5514110E;

  // ---- 点色 ----
  static const int accent = 0xFF2E8F73; // 小萤薄荷绿（印刷墨绿）
  static const int accentPressed = 0xFF1F705A;
  static const int accentSoft = 0xFFE2F1E9;
  static const int onAccent = 0xFFFFFCF4;

  // ---- 语义 ----
  static const int heart = 0xFFD94B35;
  static const int warning = 0xFFB7791F;
  static const int danger = 0xFFC0392B;
  static const int success = 0xFF2E8F73;
  static const int info = 0xFF2F6FA3;
  static const int verified = 0xFF2E8F73;

  // ---- 兼容色位（已降饱和，避免破坏纸面） ----
  static const int lilac = 0xFF8A7FA6;
  static const int peach = 0xFFC07A5E;
  static const int sky = 0xFF5E88A8;

  // 不再使用渐变；保留字段给旧调用，统一为实色。
  static const int gradStart = accent;
  static const int gradEnd = accentPressed;

  static const List<int> mediaScrim = [
    0x00000000,
    0x33000000,
    0xB3000000,
    0xE6000000,
  ];

  static const int skeletonBase = 0xFFE7DFD0;
  static const int skeletonHighlight = 0xFFF3ECDD;
}

class AppRadius {
  const AppRadius._();

  static const double xs = 2;
  static const double sm = 4;
  static const double md = 6;
  static const double lg = 8;
  static const double xl = 12;
  static const double pill = 999;
  static const BorderRadius rXs = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius rSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius rMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius rLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius rXl = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius rPill = BorderRadius.all(Radius.circular(pill));
  static const BorderRadius sheetTop = BorderRadius.vertical(
    top: Radius.circular(8),
  );
}

class AppSpace {
  const AppSpace._();

  static const double x1 = 4;
  static const double x2 = 8;
  static const double x3 = 12;
  static const double x4 = 16;
  static const double x5 = 20;
  static const double x6 = 24;
  static const double x7 = 32;
  static const double x8 = 40;
  static const double gutter = 16;
  static const double listGap = 12;
}

class AppType {
  const AppType._();

  static const TextStyle display = TextStyle(
    fontSize: 36,
    height: 1.1,
    fontWeight: FontWeight.w900,
    letterSpacing: -1.4,
    color: Color(AppColors.textPrimary),
  );

  static const TextStyle h1 = TextStyle(
    fontSize: 27,
    height: 1.18,
    fontWeight: FontWeight.w900,
    letterSpacing: -0.9,
    color: Color(AppColors.textPrimary),
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 21,
    height: 1.22,
    fontWeight: FontWeight.w900,
    letterSpacing: -0.4,
    color: Color(AppColors.textPrimary),
  );

  static const TextStyle title = TextStyle(
    fontSize: 17,
    height: 1.3,
    fontWeight: FontWeight.w800,
    color: Color(AppColors.textPrimary),
  );

  static const TextStyle body = TextStyle(
    fontSize: 15,
    height: 1.55,
    fontWeight: FontWeight.w400,
    color: Color(AppColors.textPrimary),
  );

  static const TextStyle bodySm = TextStyle(
    fontSize: 13.5,
    height: 1.5,
    fontWeight: FontWeight.w400,
    color: Color(AppColors.textSecondary),
  );

  static const TextStyle label = TextStyle(
    fontSize: 13,
    height: 1.25,
    fontWeight: FontWeight.w700,
    color: Color(AppColors.textPrimary),
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    height: 1.3,
    fontWeight: FontWeight.w500,
    color: Color(AppColors.textTertiary),
  );

  static const TextStyle micro = TextStyle(
    fontSize: 11,
    height: 1.25,
    fontWeight: FontWeight.w500,
    color: Color(AppColors.textTertiary),
  );

  static const TextStyle numeric = TextStyle(
    fontSize: 12,
    height: 1.2,
    fontWeight: FontWeight.w700,
    color: Color(AppColors.textPrimary),
    fontFeatures: [FontFeature.tabularFigures()],
  );
}

class AppMotion {
  const AppMotion._();

  static const Duration fast = Duration(milliseconds: 140);
  static const Duration base = Duration(milliseconds: 200);
  static const Duration slow = Duration(milliseconds: 320);
  static const Duration page = Duration(milliseconds: 260);
  static const Duration sharedForward = Duration(milliseconds: 260);
  static const Duration sharedBack = Duration(milliseconds: 220);
  static const Duration sharedFade = Duration(milliseconds: 120);

  static const Curve standard = Curves.easeOutCubic;
  static const Curve emphasized = Curves.easeOutQuint;
  static const Curve enter = Curves.easeOut;
  static const Curve exit = Curves.easeIn;
}

class AppEffects {
  const AppEffects._();

  /// 纸面不再发光；所有“glow”调用都落成漫画硬边错位阴影。
  static List<BoxShadow> accentGlow({double opacity = 0.35}) => const [
    BoxShadow(color: Color(0xCC14110E), offset: Offset(3, 3), blurRadius: 0),
  ];

  static const List<BoxShadow> overlay = [
    BoxShadow(color: Color(0x6614110E), offset: Offset(4, 4), blurRadius: 0),
  ];

  // 仅供视频/大图的压暗可读性，不作为 UI 背景使用。
  static LinearGradient topScrim({double height = 0.28}) => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [const Color(0xB3000000), const Color(0x00000000)],
    stops: [0, height],
  );

  static LinearGradient bottomScrim({double start = 0.45}) => LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: [const Color(0xF2000000), const Color(0x00000000)],
    stops: [0, 1 - start],
  );

  static const LinearGradient navScrim = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: [Color(0xF2000000), Color(0x00000000)],
    stops: [0.35, 1],
  );
}

ThemeData buildImmersiveTheme() {
  const scheme = ColorScheme.light(
    primary: Color(AppColors.accent),
    onPrimary: Color(AppColors.onAccent),
    secondary: Color(AppColors.accent),
    surface: Color(AppColors.bg),
    onSurface: Color(AppColors.textPrimary),
    error: Color(AppColors.danger),
    onError: Color(AppColors.onAccent),
    outline: Color(AppColors.border),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: scheme,
    scaffoldBackgroundColor: const Color(AppColors.bg),
    canvasColor: const Color(AppColors.bg),
    splashFactory: InkSparkle.splashFactory,
    fontFamily: 'NotoSansSC',
    fontFamilyFallback: const ['PingFang SC', 'Heiti SC'],
    textTheme:
        const TextTheme(
          displayLarge: AppType.display,
          headlineLarge: AppType.h1,
          headlineSmall: AppType.h2,
          titleMedium: AppType.title,
          bodyLarge: AppType.body,
          bodyMedium: AppType.bodySm,
          labelLarge: AppType.label,
          bodySmall: AppType.caption,
          labelSmall: AppType.micro,
        ).apply(
          bodyColor: const Color(AppColors.textPrimary),
          displayColor: const Color(AppColors.textPrimary),
        ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: AppType.h2,
      iconTheme: IconThemeData(color: Color(AppColors.textPrimary), size: 22),
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Color(AppColors.card),
      surfaceTintColor: Colors.transparent,
      modalBackgroundColor: Color(AppColors.card),
      modalBarrierColor: Color(0x6614110E),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.sheetTop),
      showDragHandle: false,
      elevation: 0,
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: Color(AppColors.card),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.rSm,
        side: BorderSide(color: Color(AppColors.textPrimary), width: 2),
      ),
      titleTextStyle: AppType.h2,
      contentTextStyle: AppType.bodySm,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(AppColors.textPrimary),
      contentTextStyle: AppType.bodySm.copyWith(
        color: const Color(AppColors.card),
      ),
      behavior: SnackBarBehavior.floating,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.rSm),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(AppColors.hairline),
      thickness: 1,
      space: 1,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(AppColors.card),
      hintStyle: AppType.bodySm.copyWith(
        color: const Color(AppColors.textTertiary),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpace.x4,
        vertical: AppSpace.x3,
      ),
      border: OutlineInputBorder(
        borderRadius: AppRadius.rSm,
        borderSide: const BorderSide(
          color: Color(AppColors.textPrimary),
          width: 1.5,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.rSm,
        borderSide: const BorderSide(
          color: Color(AppColors.border),
          width: 1.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.rSm,
        borderSide: const BorderSide(color: Color(AppColors.accent), width: 2),
      ),
    ),
    iconTheme: const IconThemeData(
      color: Color(AppColors.textPrimary),
      size: 22,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: Color(AppColors.accent),
      linearTrackColor: Color(AppColors.hairline),
      circularTrackColor: Color(AppColors.hairline),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? const Color(AppColors.accent)
            : const Color(AppColors.textTertiary),
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? const Color(AppColors.accentSoft)
            : const Color(AppColors.hairline),
      ),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}
