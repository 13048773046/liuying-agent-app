/// 小萤 Agent · 日系漫画分镜视觉
///
/// 设计语言：暖纸白画布、墨黑硬线、网点/速度线、硬边分镜、少量薄荷绿，
/// 人物以透明底贴纸叠在纸面上。所有装饰均由 Flutter 绘制，不使用渐变/光晕。
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'tokens.dart';

/// 全屏纸张网点：极淡的黑点 + 边角速度线 + 裁切标记，不拦截手势。
class MangaBackdrop extends StatelessWidget {
  const MangaBackdrop({super.key, required this.child, this.dense = false});

  final Widget child;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 纸白底与网点在内容之下，避免网点盖在人物立绘和正文上。
        const Positioned.fill(child: ColoredBox(color: Color(AppColors.bg))),
        Positioned.fill(
          child: IgnorePointer(
            child: RepaintBoundary(
              child: CustomPaint(painter: _PaperPainter(dense: dense)),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _PaperPainter extends CustomPainter {
  const _PaperPainter({required this.dense});
  final bool dense;

  @override
  void paint(Canvas canvas, Size size) {
    final ink = const Color(0xFF14110E);
    final gap = dense ? 8.0 : 10.0;
    final dot = Paint()..color = ink.withValues(alpha: 0.055);
    for (var y = 0.0; y < size.height; y += gap) {
      for (var x = 0.0; x < size.width; x += gap) {
        if ((x / gap + y / gap).round().isEven) {
          canvas.drawCircle(Offset(x, y), dense ? 0.8 : 0.65, dot);
        }
      }
    }

    // 左上/右下的斜向速度线，像漫画页边的排线。
    final line = Paint()
      ..color = ink.withValues(alpha: 0.045)
      ..strokeWidth = 1;
    final top = Path();
    for (var i = 0; i < 12; i++) {
      final o = 10.0 + i * 6.0;
      top
        ..moveTo(-8, o)
        ..lineTo(o * 0.9, -8);
    }
    canvas.drawPath(top, line);
    final bottom = Path();
    for (var i = 0; i < 10; i++) {
      final o = 12.0 + i * 7.0;
      bottom
        ..moveTo(size.width + 8, size.height - o)
        ..lineTo(size.width - o * 0.8, size.height + 8);
    }
    canvas.drawPath(bottom, line);

    // 四角裁切标记
    final mark = Paint()
      ..color = ink.withValues(alpha: 0.18)
      ..strokeWidth = 1.2;
    const len = 9.0;
    for (final o in [
      const Offset(14, 14),
      Offset(size.width - 14, 14),
      Offset(14, size.height - 14),
      Offset(size.width - 14, size.height - 14),
    ]) {
      canvas.drawLine(o.translate(-len, 0), o.translate(len, 0), mark);
      canvas.drawLine(o.translate(0, -len), o.translate(0, len), mark);
    }
  }

  @override
  bool shouldRepaint(covariant _PaperPainter oldDelegate) =>
      oldDelegate.dense != dense;
}

/// 分镜框：纸白底 + 2px 墨线 + 硬边错位阴影，可带右上角编号标签。
class MangaPanel extends StatelessWidget {
  const MangaPanel({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.radius = 4,
    this.color,
    this.borderColor,
    this.borderWidth = 2,
    this.tag,
    this.accent = false, // 保留参数兼容旧调用；不再产生光晕。
    this.clip = true,
    this.shadow = true,
  });

  final Widget child;
  final EdgeInsets padding;
  final double radius;
  final Color? color;
  final Color? borderColor;
  final double borderWidth;
  final String? tag;
  final bool accent;
  final bool clip;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    final panel = Container(
      decoration: BoxDecoration(
        color: color ?? const Color(AppColors.card),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: borderColor ?? const Color(AppColors.textPrimary),
          width: borderWidth,
        ),
        boxShadow: shadow
            ? const [
                BoxShadow(
                  color: Color(0xCC14110E),
                  offset: Offset(5, 5),
                  blurRadius: 0,
                ),
              ]
            : null,
      ),
      clipBehavior: clip ? Clip.antiAlias : Clip.none,
      child: Padding(padding: padding, child: child),
    );
    if (tag == null) return panel;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        panel,
        Positioned(
          top: -11,
          right: 10,
          child: Transform.rotate(angle: -0.02, child: MangaTag(text: tag!)),
        ),
      ],
    );
  }
}

/// 漫画编号/印章标签：黑底纸白字，或薄荷底墨字。
class MangaTag extends StatelessWidget {
  const MangaTag({
    super.key,
    required this.text,
    this.color = const Color(AppColors.textPrimary),
    this.onDark = true,
  });

  final String text;
  final Color color;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final bg = onDark ? color : const Color(AppColors.accentSoft);
    final fg = onDark
        ? const Color(AppColors.card)
        : const Color(AppColors.textPrimary);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(
          color: const Color(AppColors.textPrimary),
          width: 1.2,
        ),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        text,
        style: AppType.micro.copyWith(
          fontSize: 9,
          height: 1.0,
          letterSpacing: 1.25,
          fontWeight: FontWeight.w800,
          color: fg,
        ),
      ),
    );
  }
}

/// 日系漫画对话框：纸白气泡、墨线、左下尖尾、硬阴影。
class SpeechBubble extends StatelessWidget {
  const SpeechBubble({
    super.key,
    required this.text,
    this.padding = const EdgeInsets.fromLTRB(15, 12, 15, 22),
    this.color = const Color(AppColors.card),
    this.borderColor = const Color(AppColors.textPrimary),
    this.shadow = true,
  });

  final String text;
  final EdgeInsets padding;
  final Color color;
  final Color borderColor;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BubblePainter(
        color: color,
        border: borderColor,
        shadow: shadow,
      ),
      child: Padding(
        padding: padding,
        child: Text(
          text,
          style: AppType.bodySm.copyWith(
            fontSize: 12.5,
            height: 1.6,
            color: const Color(AppColors.textPrimary),
          ),
        ),
      ),
    );
  }
}

class _BubblePainter extends CustomPainter {
  const _BubblePainter({
    required this.color,
    required this.border,
    required this.shadow,
  });

  final Color color;
  final Color border;
  final bool shadow;

  Path _path(Size size) {
    const tail = 10.0;
    const r = 6.0;
    final body = Rect.fromLTWH(
      1.5,
      1.5,
      size.width - 3,
      size.height - tail - 3,
    );
    return Path()
      ..addRRect(RRect.fromRectAndRadius(body, const Radius.circular(r)))
      ..moveTo(18, body.bottom - 0.5)
      ..lineTo(13, size.height - 1.5)
      ..lineTo(34, body.bottom - 0.5)
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = _path(size);
    if (shadow) {
      canvas.save();
      canvas.translate(4, 4);
      canvas.drawPath(path, Paint()..color = const Color(0x6614110E));
      canvas.restore();
    }
    canvas.drawPath(path, Paint()..color = color);
    canvas.drawPath(
      path,
      Paint()
        ..color = border
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );
  }

  @override
  bool shouldRepaint(covariant _BubblePainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.border != border ||
      oldDelegate.shadow != shadow;
}

/// 品牌字标：纸面黑字，右上角盖「第 01 话」小章。
class MangaWordmark extends StatelessWidget {
  const MangaWordmark({super.key, this.compact = false, this.onImage = false});

  final bool compact;
  final bool onImage;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'LIUYING COMICS',
              style: AppType.micro.copyWith(
                fontSize: compact ? 8 : 9,
                letterSpacing: 2.2,
                fontWeight: FontWeight.w700,
                color: const Color(AppColors.textSecondary),
              ),
            ),
            const SizedBox(width: 8),
            const MangaTag(text: '第 01 话', onDark: false),
          ],
        ),
        SizedBox(height: compact ? 5 : 7),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '小萤',
              style: TextStyle(
                fontSize: compact ? 30 : 44,
                height: 0.98,
                fontWeight: FontWeight.w900,
                letterSpacing: -2,
                color: const Color(AppColors.textPrimary),
              ),
            ),
            const SizedBox(width: 6),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'AGENT',
                style: TextStyle(
                  fontSize: compact ? 11 : 13,
                  height: 1,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.4,
                  color: const Color(AppColors.accent),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// 墨线加载条：一根黑线 + 一截薄荷绿进度，无发光。
class MangaLoader extends StatefulWidget {
  const MangaLoader({super.key, this.width = 118});

  final double width;

  @override
  State<MangaLoader> createState() => _MangaLoaderState();
}

class _MangaLoaderState extends State<MangaLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: 12,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, _) =>
            CustomPaint(painter: _LoaderPainter(progress: _ctrl.value)),
      ),
    );
  }
}

class _LoaderPainter extends CustomPainter {
  const _LoaderPainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height / 2;
    canvas.drawLine(
      Offset(0, y),
      Offset(size.width, y),
      Paint()
        ..color = const Color(AppColors.textPrimary)
        ..strokeWidth = 2,
    );
    final head = progress * size.width;
    canvas.drawRect(
      Rect.fromLTWH(0, y - 3.5, head, 7),
      Paint()..color = const Color(AppColors.accent),
    );
    canvas.drawLine(
      Offset(head, y - 5),
      Offset(head, y + 5),
      Paint()
        ..color = const Color(AppColors.textPrimary)
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(covariant _LoaderPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// 透明人物贴纸：不带任何背景/光晕，直接叠在纸面或分镜上。
class MangaCutout extends StatelessWidget {
  const MangaCutout({
    super.key,
    required this.asset,
    this.height,
    this.width,
    this.alignment = Alignment.center,
    this.rotate = 0,
    this.opacity = 1,
  });

  final String asset;
  final double? height;
  final double? width;
  final Alignment alignment;
  final double rotate;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      asset,
      height: height,
      width: width,
      fit: BoxFit.contain,
      alignment: alignment,
      filterQuality: FilterQuality.medium,
    );
    return Opacity(
      opacity: opacity,
      child: rotate == 0
          ? image
          : Transform.rotate(angle: rotate, child: image),
    );
  }
}

/// 章节小标题：黑字 + 粗下划线 + 编号，替代普通 section header。
class MangaSectionTitle extends StatelessWidget {
  const MangaSectionTitle({
    super.key,
    required this.index,
    required this.title,
  });

  final String index;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          index,
          style: AppType.micro.copyWith(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
            color: const Color(AppColors.card),
            backgroundColor: const Color(AppColors.textPrimary),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppType.label.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.4,
            color: const Color(AppColors.textPrimary),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 2,
            color: const Color(AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}

/// 手绘印章：红色方章，轻微旋转，适合点题。
class MangaStamp extends StatelessWidget {
  const MangaStamp({super.key, required this.text, this.rotate = -0.06});

  final String text;
  final double rotate;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(AppColors.danger), width: 2),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Text(
          text,
          style: AppType.micro.copyWith(
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            color: const Color(AppColors.danger),
          ),
        ),
      ),
    );
  }
}

/// 小型速度线装饰，放在标题/空态背后。
class SpeedLines extends StatelessWidget {
  const SpeedLines({
    super.key,
    this.color = const Color(0x2214110E),
    this.count = 8,
  });
  final Color color;
  final int count;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SpeedPainter(color: color, count: count),
    );
  }
}

class _SpeedPainter extends CustomPainter {
  const _SpeedPainter({required this.color, required this.count});
  final Color color;
  final int count;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 1.4;
    for (var i = 0; i < count; i++) {
      final t = i / math.max(1, count - 1);
      final y = size.height * t;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width * (0.35 + 0.6 * (1 - t)), y),
        p,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SpeedPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.count != count;
}
