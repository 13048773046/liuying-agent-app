/// 小萤 Agent · 日系漫画视觉组件
///
/// 只服务独立版：用网点、速度线、硬边框分镜和对话框，把 Agent 界面
/// 统一到「日系漫画 + 薄荷绿」的品牌语言里；不引入第三方依赖。
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'tokens.dart';

/// 全屏漫画网点/速度线叠层：放在 MaterialApp.builder 最上层，透明度极低，
/// 不拦截手势，只负责给整个 App 一层纸张印刷质感。
class MangaBackdrop extends StatelessWidget {
  const MangaBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            child: RepaintBoundary(
              child: CustomPaint(painter: _MangaGrainPainter()),
            ),
          ),
        ),
      ],
    );
  }
}

class _MangaGrainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const gap = 11.0;
    final dot = Paint()
      ..color = const Color(0x0AF6F2E9)
      ..style = PaintingStyle.fill;
    for (var y = 4.0; y < size.height; y += gap) {
      for (var x = 4.0; x < size.width; x += gap) {
        final fade = 0.45 + 0.55 * (1 - (y / size.height));
        canvas.drawCircle(
          Offset(x, y),
          0.62,
          dot..color = dot.color.withValues(alpha: 0.025 * fade),
        );
      }
    }

    final line = Paint()
      ..color = const Color(0x087CE3B6)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    final topRight = Path();
    for (var i = 0; i < 7; i++) {
      final o = 8.0 + i * 9;
      topRight
        ..moveTo(size.width - o, -6)
        ..lineTo(size.width - 6, o);
    }
    canvas.drawPath(topRight, line);

    final bottomLeft = Path();
    for (var i = 0; i < 6; i++) {
      final o = 10.0 + i * 10;
      bottomLeft
        ..moveTo(-4, size.height - o)
        ..lineTo(o, size.height + 4);
    }
    canvas.drawPath(bottomLeft, line);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 漫画分镜框：硬边框 + 错位硬阴影 + 可选的右上角标签。
class MangaPanel extends StatelessWidget {
  const MangaPanel({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.radius = 18,
    this.color,
    this.borderColor,
    this.tag,
    this.accent = true,
    this.clip = true,
  });

  final Widget child;
  final EdgeInsets padding;
  final double radius;
  final Color? color;
  final Color? borderColor;
  final String? tag;
  final bool accent;
  final bool clip;

  @override
  Widget build(BuildContext context) {
    final radiusValue = BorderRadius.circular(radius);
    final panel = Container(
      decoration: BoxDecoration(
        color: color ?? const Color(0xFF121713),
        borderRadius: radiusValue,
        border: Border.all(
          color: borderColor ?? const Color(0x33F6F2E9),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.55),
            offset: const Offset(4, 4),
            blurRadius: 0,
          ),
          if (accent)
            BoxShadow(
              color: const Color(0x2E7CE3B6),
              offset: const Offset(4, 4),
              blurRadius: 16,
            ),
        ],
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
          top: -9,
          right: 14,
          child: Transform.rotate(angle: -0.035, child: MangaTag(text: tag!)),
        ),
      ],
    );
  }
}

/// 漫画贴纸标签：小字号、宽字距、硬边。
class MangaTag extends StatelessWidget {
  const MangaTag({
    super.key,
    required this.text,
    this.color = const Color(0xFF7CE3B6),
    this.onDark = true,
  });

  final String text;
  final Color color;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: onDark ? const Color(0xFF0B0E0C) : color,
        border: Border.all(color: color, width: 1),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        text,
        style: AppType.micro.copyWith(
          fontSize: 9,
          height: 1.0,
          letterSpacing: 1.4,
          fontWeight: FontWeight.w700,
          color: onDark ? color : const Color(0xFF07100C),
        ),
      ),
    );
  }
}

/// 日系对话框：圆角气泡 + 左下小尾巴，适合放角色台词/引导语。
class SpeechBubble extends StatelessWidget {
  const SpeechBubble({
    super.key,
    required this.text,
    this.padding = const EdgeInsets.fromLTRB(15, 11, 15, 20),
    this.color = const Color(0xFF141A16),
    this.borderColor = const Color(0x4D7CE3B6),
  });

  final String text;
  final EdgeInsets padding;
  final Color color;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BubblePainter(color: color, border: borderColor),
      child: Padding(
        padding: padding,
        child: Text(
          text,
          style: AppType.bodySm.copyWith(
            fontSize: 12.5,
            height: 1.55,
            color: const Color(0xFFD7D3C8),
          ),
        ),
      ),
    );
  }
}

class _BubblePainter extends CustomPainter {
  const _BubblePainter({required this.color, required this.border});

  final Color color;
  final Color border;

  @override
  void paint(Canvas canvas, Size size) {
    const tail = 9.0;
    const r = 14.0;
    final body = Rect.fromLTWH(
      0.6,
      0.6,
      size.width - 1.2,
      size.height - tail - 1.2,
    );
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(body, const Radius.circular(r)))
      ..moveTo(18, body.bottom - 1)
      ..lineTo(14, size.height - 1.0)
      ..lineTo(33, body.bottom - 1)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = border
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1,
    );
  }

  @override
  bool shouldRepaint(covariant _BubblePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.border != border;
}

/// 登录/启动页的品牌字标：粗体标题 + 细字距英文眉题。
class MangaWordmark extends StatelessWidget {
  const MangaWordmark({super.key, this.compact = false, this.onImage = false});

  final bool compact;
  final bool onImage;

  @override
  Widget build(BuildContext context) {
    final mainColor = onImage
        ? const Color(0xFFF6F2E9)
        : const Color(0xFFF6F2E9);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'LIUYING  /  AGENT',
          style: AppType.micro.copyWith(
            fontSize: compact ? 8.5 : 9.5,
            letterSpacing: 2.6,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF7CE3B6),
          ),
        ),
        SizedBox(height: compact ? 5 : 7),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '小萤 Agent',
              style: TextStyle(
                fontSize: compact ? 22 : 30,
                height: 1.05,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.8,
                color: mainColor,
                shadows: const [
                  Shadow(
                    color: Color(0xB3000000),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
            if (!compact) ...[
              const SizedBox(width: 8),
              const MangaTag(text: '独立版'),
            ],
          ],
        ),
      ],
    );
  }
}

/// 手绘感进度条：细线 + 一个薄荷绿圆点，启动页/加载态复用。
class MangaLoader extends StatefulWidget {
  const MangaLoader({super.key, this.width = 132});

  final double width;

  @override
  State<MangaLoader> createState() => _MangaLoaderState();
}

class _MangaLoaderState extends State<MangaLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
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
      height: 10,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, _) {
          final t = _ctrl.value;
          return CustomPaint(painter: _LoaderPainter(progress: t));
        },
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
        ..color = const Color(0x33F6F2E9)
        ..strokeWidth = 1,
    );
    final head = progress * size.width;
    canvas.drawLine(
      Offset(0, y),
      Offset(head, y),
      Paint()
        ..color = const Color(0xFF7CE3B6)
        ..strokeWidth = 1.4,
    );
    final pulse = 2.4 + 1.6 * math.sin(progress * math.pi * 2).abs();
    canvas.drawCircle(
      Offset(head, y),
      pulse,
      Paint()..color = const Color(0xFF7CE3B6),
    );
  }

  @override
  bool shouldRepaint(covariant _LoaderPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
