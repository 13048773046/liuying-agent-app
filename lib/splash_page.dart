/// 小萤 Agent · 纸白漫画启动页
///
/// 一页漫画封面：巨大字标、透明人物贴纸、分镜框与对话框。
/// 不使用人物背景图、光晕或渐变。
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
    final top = MediaQuery.paddingOf(context).top;
    final bottom = MediaQuery.paddingOf(context).bottom;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 18,
                left: 24,
                right: 24,
                child: FadeTransition(
                  opacity: _ctrl,
                  child: Row(
                    children: [
                      Text(
                        'VOL.01  /  PROLOGUE',
                        style: AppType.micro.copyWith(
                          fontSize: 9,
                          letterSpacing: 2.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      const MangaStamp(text: '小萤'),
                    ],
                  ),
                ),
              ),

              Positioned(
                top: 58 + top * 0.1,
                left: 24,
                right: 24,
                child: FadeTransition(
                  opacity: _ctrl,
                  child: const MangaWordmark(),
                ),
              ),

              // 左侧标题区：大字排成漫画台词。
              Positioned(
                top: 150,
                left: 24,
                width: 210,
                child: FadeTransition(
                  opacity: CurvedAnimation(
                    parent: _ctrl,
                    curve: const Interval(0.15, 1, curve: Curves.easeOut),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '给目标，\n拆步骤，\n交成品。',
                        style: AppType.display.copyWith(
                          fontSize: 31,
                          height: 1.18,
                          letterSpacing: -1.6,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: 168,
                        height: 5,
                        color: const Color(AppColors.textPrimary),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '轻活在本机做。\n重活进云沙箱。',
                        style: AppType.bodySm.copyWith(
                          fontSize: 12,
                          height: 1.7,
                          color: const Color(AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 右侧分镜框：只放透明人物，没有人物背景。
              Positioned(
                top: 238,
                right: 18,
                width: 206,
                child: FadeTransition(
                  opacity: _ctrl,
                  child: SlideTransition(
                    position:
                        Tween<Offset>(
                          begin: const Offset(0.04, 0.02),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: _ctrl,
                            curve: Curves.easeOutCubic,
                          ),
                        ),
                    child: MangaPanel(
                      tag: 'CUT / 01',
                      color: const Color(AppColors.card),
                      child: SizedBox(
                        height: 400,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Positioned(
                              left: 8,
                              right: 8,
                              bottom: 28,
                              top: 10,
                              child: const MangaCutout(
                                asset: 'assets/brand/xiaoying_full.png',
                                height: 370,
                                alignment: Alignment.bottomCenter,
                              ),
                            ),
                            Positioned(
                              left: 10,
                              right: 10,
                              bottom: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                  horizontal: 7,
                                ),
                                color: const Color(AppColors.textPrimary),
                                child: Row(
                                  children: [
                                    Text(
                                      '小萤',
                                      style: AppType.micro.copyWith(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(AppColors.card),
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      'ONLINE',
                                      style: AppType.micro.copyWith(
                                        fontSize: 8,
                                        letterSpacing: 1.4,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(
                                          AppColors.accentSoft,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // 页脚对话框与加载线。
              Positioned(
                left: 24,
                right: 24,
                bottom: 18 + bottom,
                child: FadeTransition(
                  opacity: CurvedAnimation(
                    parent: _ctrl,
                    curve: const Interval(0.3, 1, curve: Curves.easeOut),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SpeechBubble(text: '欢迎回来。给我一个目标，我拆步骤、调工具，做完交给你。'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const MangaLoader(width: 104),
                          const SizedBox(width: 12),
                          Text(
                            '正在唤醒小萤',
                            style: AppType.micro.copyWith(
                              fontSize: 10,
                              letterSpacing: 1.2,
                              color: const Color(AppColors.textSecondary),
                            ),
                          ),
                          const Spacer(),
                          const MangaTag(text: 'READY / 01', onDark: false),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
