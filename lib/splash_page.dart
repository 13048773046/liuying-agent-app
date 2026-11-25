/// 小萤 Agent · 品牌启动页
///
/// 原生启动图之后接一屏日系漫画主视觉，再进入登录/工作台。
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'design/manga.dart';
import 'design/tokens.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1450), widget.onDone);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    final top = MediaQuery.paddingOf(context).top;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(AppColors.bg),
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/brand/splash_art.jpg',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              filterQuality: FilterQuality.medium,
            ),
            // 顶部/底部压暗，保证叠加文字可读。
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xE6080A09),
                    Color(0x00080A09),
                    Color(0x00080A09),
                    Color(0xF2080A09),
                  ],
                  stops: [0, 0.28, 0.58, 1],
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  22,
                  18 + top * 0.2,
                  22,
                  16 + bottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FadeTransition(
                      opacity: CurvedAnimation(
                        parent: _ctrl,
                        curve: const Interval(0, 0.7, curve: Curves.easeOut),
                      ),
                      child: SlideTransition(
                        position:
                            Tween<Offset>(
                              begin: const Offset(0, -0.03),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: _ctrl,
                                curve: const Interval(
                                  0,
                                  0.75,
                                  curve: Curves.easeOutCubic,
                                ),
                              ),
                            ),
                        child: const MangaWordmark(),
                      ),
                    ),
                    const Spacer(),
                    FadeTransition(
                      opacity: CurvedAnimation(
                        parent: _ctrl,
                        curve: const Interval(0.25, 1, curve: Curves.easeOut),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SpeechBubble(
                            text: '欢迎回来。给我一个目标，我拆步骤、调工具，做完交给你。',
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              const MangaLoader(width: 118),
                              const SizedBox(width: 12),
                              Text(
                                '正在唤醒小萤',
                                style: AppType.micro.copyWith(
                                  fontSize: 10.5,
                                  letterSpacing: 1.2,
                                  color: const Color(0xB8F6F2E9),
                                ),
                              ),
                              const Spacer(),
                              const MangaTag(text: 'ONLINE / 01'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
