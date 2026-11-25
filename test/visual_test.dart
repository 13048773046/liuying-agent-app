@Tags(['golden'])
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:liuying_agent/api/client.dart';
import 'package:liuying_agent/design/components.dart';
import 'package:liuying_agent/design/manga.dart';
import 'package:liuying_agent/design/tokens.dart';
import 'package:liuying_agent/login_page.dart';
import 'package:liuying_agent/main.dart';
import 'package:liuying_agent/pages/home/af_effort_card.dart';
import 'package:liuying_agent/pages/home/af_workbench_page.dart';
import 'package:liuying_agent/splash_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ByteData> _fileFont(String path) async {
  final bytes = await File(path).readAsBytes();
  return ByteData.sublistView(Uint8List.fromList(bytes));
}

Future<void> _warmImages(WidgetTester tester, List<String> assets) async {
  final ctx = tester.element(find.byType(MaterialApp));
  await tester.runAsync(() async {
    for (final asset in assets) {
      await precacheImage(AssetImage(asset), ctx);
    }
  });
  await tester.pump();
}

void main() {
  setUpAll(() async {
    final loader = FontLoader('NotoSansSC')
      ..addFont(rootBundle.load('assets/fonts/NotoSansSC-Regular.otf'));
    await loader.load();

    final root = Platform.environment['FLUTTER_ROOT'];
    if (root != null) {
      final iconFont = File(
        '$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
      );
      if (await iconFont.exists()) {
        final material = FontLoader('MaterialIcons')
          ..addFont(_fileFont(iconFont.path));
        await material.load();
      }
    }
  });

  testWidgets('启动页视觉', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildImmersiveTheme(),
        home: SplashPage(onDone: () {}),
      ),
    );
    await _warmImages(tester, const ['assets/brand/xiaoying_full.png']);
    await tester.pump(const Duration(milliseconds: 900));
    await expectLater(
      find.byType(SplashPage),
      matchesGoldenFile('goldens/splash.png'),
    );
  });

  testWidgets('登录页视觉', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildImmersiveTheme(),
        home: MangaBackdrop(child: LoginPage(onLoggedIn: (_) {})),
      ),
    );
    await _warmImages(tester, const ['assets/brand/xiaoying_portrait.png']);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('密码'));
    await tester.pump(const Duration(milliseconds: 300));
    await expectLater(
      find.byType(LoginPage),
      matchesGoldenFile('goldens/login.png'),
    );
  });

  testWidgets('登录页手机验证码视觉', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildImmersiveTheme(),
        home: MangaBackdrop(child: LoginPage(onLoggedIn: (_) {})),
      ),
    );
    await _warmImages(tester, const ['assets/brand/xiaoying_portrait.png']);
    await tester.pump(const Duration(milliseconds: 300));
    await expectLater(
      find.byType(LoginPage),
      matchesGoldenFile('goldens/login_phone.png'),
    );
  });

  testWidgets('Agent 欢迎页视觉', (tester) async {
    SharedPreferences.setMockInitialValues({});
    ApiClient.token = 'visual-test-token';
    final mock = MockClient((request) async {
      final path = request.url.path;
      if (path.endsWith('/af/quota')) {
        return http.Response(
          jsonEncode({
            'ok': true,
            'plan': 'free',
            'left': 30000,
            'gift_left': 30000,
            'w5h_left': 20000,
            'limit_w5h': 20000,
            'balance_yuan': 0,
          }),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }
      if (path.endsWith('/af/conversations')) {
        return http.Response(
          jsonEncode({'ok': true, 'list': <Object>[]}),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }
      return http.Response(
        jsonEncode({'ok': true}),
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildImmersiveTheme(),
        home: MangaBackdrop(
          child: AfWorkbenchPage(client: mock, onLogout: () {}),
        ),
      ),
    );
    await _warmImages(tester, const ['assets/brand/xiaoying_full.png']);
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(seconds: 2));
    await expectLater(
      find.byType(AfWorkbenchPage),
      matchesGoldenFile('goldens/workbench.png'),
    );
  });

  testWidgets('对话页视觉', (tester) async {
    SharedPreferences.setMockInitialValues({'af_conv_id': 'c1'});
    ApiClient.token = 'visual-test-token';
    final mock = MockClient((request) async {
      final path = request.url.path;
      if (path.endsWith('/af/quota')) {
        return http.Response(
          jsonEncode({
            'ok': true,
            'plan': 'free',
            'left': 30000,
            'gift_left': 30000,
            'w5h_left': 20000,
            'limit_w5h': 20000,
            'balance_yuan': 0,
          }),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }
      if (path.endsWith('/af/conversations')) {
        return http.Response(
          jsonEncode({
            'ok': true,
            'list': [
              {
                'id': 'c1',
                'title': '项目周报',
                'created': 1700000000,
                'updated': 1700000100,
              },
            ],
          }),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }
      if (path.endsWith('/af/messages')) {
        return http.Response(
          jsonEncode({
            'ok': true,
            'list': [
              {
                'id': 'm1',
                'role': 'user',
                'content': '帮我把这周的项目进度整理成一页周报',
                'created': 1700000000,
              },
              {
                'id': 'm2',
                'role': 'assistant',
                'content':
                    '已整理好。**本周完成**：独立壳、双端配置、视觉主题。\n\n**下周计划**：真机回归与商店素材。',
                'reasoning': '先确认周报模板，再按完成/风险/计划三段整理。',
                'created': 1700000005,
                'ms': 1200,
                'status': 'done',
              },
            ],
            'items': <Object>[],
          }),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }
      return http.Response(
        jsonEncode({'ok': true}),
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildImmersiveTheme(),
        home: MangaBackdrop(
          child: AfWorkbenchPage(client: mock, onLogout: () {}),
        ),
      ),
    );
    await _warmImages(tester, const ['assets/brand/xiaoying_full.png']);
    // 先让真实异步的 SharedPreferences 与 mock HTTP 完成，再进入固定时长渲染。
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(seconds: 2));
    await expectLater(
      find.byType(AfWorkbenchPage),
      matchesGoldenFile('goldens/chat.png'),
    );

  });

  testWidgets('推理档位弹层视觉', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildImmersiveTheme(),
        home: MangaBackdrop(
          child: TickerMode(
            enabled: false,
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: AfEffortSheet(
                mode: 'work',
                model: 'deepseek-v4-pro',
                effort: 'medium',
                onMode: (_) {},
                onModel: (_) {},
                onEffort: (_) {},
                initialProviders: const [],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    await expectLater(
      find.byType(AfEffortSheet),
      matchesGoldenFile('goldens/effort_sheet.png'),
    );
  });

  testWidgets('会话抽屉视觉', (tester) async {
    SharedPreferences.setMockInitialValues({});
    ApiClient.token = 'visual-test-token';
    final mock = MockClient((request) async {
      final path = request.url.path;
      if (path.endsWith('/af/quota')) {
        return http.Response(
          jsonEncode({
            'ok': true,
            'plan': 'free',
            'left': 30000,
            'gift_left': 30000,
            'w5h_left': 20000,
            'limit_w5h': 20000,
            'balance_yuan': 0,
          }),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }
      if (path.endsWith('/af/conversations')) {
        return http.Response(
          jsonEncode({
            'ok': true,
            'list': [
              {'id': 'c1', 'title': '本周项目周报', 'pinned': 0},
              {'id': 'c2', 'title': '把网页抓成 Markdown', 'pinned': 1},
              {'id': 'c3', 'title': '整理下载文件夹', 'pinned': 0},
            ],
          }),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }
      return http.Response(
        jsonEncode({'ok': true}),
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildImmersiveTheme(),
        home: MangaBackdrop(
          child: AfWorkbenchPage(client: mock, onLogout: () {}),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 600));
    await tester.tap(find.byIcon(Icons.menu_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 360));
    await tester.pump(const Duration(milliseconds: 20));
    await expectLater(
      find.byType(AfWorkbenchPage),
      matchesGoldenFile('goldens/drawer.png'),
    );
    await tester.tap(find.byIcon(Icons.close_rounded).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 360));
    await tester.pump(const Duration(milliseconds: 20));
  });

  testWidgets('独立 App 启动后不出现社区首页', (tester) async {
    await tester.pumpWidget(const LiuyingAgentApp(initialToken: ''));
    await tester.pump(const Duration(milliseconds: 1800));
    await tester.pumpAndSettle();
    expect(find.text('验证码登录 / 注册'), findsOneWidget);
    expect(find.text('LOGIN'), findsOneWidget);
  });
}
