import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:liuying_agent/api/client.dart';
import 'package:liuying_agent/design/manga.dart';
import 'package:liuying_agent/design/tokens.dart';
import 'package:liuying_agent/login_page.dart';
import 'package:liuying_agent/pages/home/af_workbench_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final loader = FontLoader('NotoSansSC')
      ..addFont(rootBundle.load('assets/fonts/NotoSansSC-Regular.otf'));
    await loader.load();
  });

  Future<void> setPhone(WidgetTester tester, Size size) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
  }

  Widget app(Widget child) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildImmersiveTheme(),
        builder: (context, inner) => MangaBackdrop(child: inner ?? const SizedBox()),
        home: child,
      );

  testWidgets('320x568 登录页不溢出', (tester) async {
    await setPhone(tester, const Size(320, 568));
    await tester.pumpWidget(app(LoginPage(onLoggedIn: (_) {})));
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);
    expect(find.text('进入 Agent'), findsOneWidget);
    expect(find.text('账号密码'), findsOneWidget);
    expect(find.text('Token'), findsOneWidget);
  });

  testWidgets('320x568 登录页放大字体不溢出', (tester) async {
    await setPhone(tester, const Size(320, 568));
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(app(LoginPage(onLoggedIn: (_) {})));
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);
  });

  testWidgets('320x568 Agent 欢迎页不溢出', (tester) async {
    SharedPreferences.setMockInitialValues({});
    ApiClient.token = 'layout-test-token';
    final mock = MockClient((request) async {
      final path = request.url.path;
      final body = path.endsWith('/af/quota')
          ? {
              'ok': true,
              'plan': 'free',
              'left': 30000,
              'gift_left': 30000,
              'w5h_left': 20000,
              'limit_w5h': 20000,
              'balance_yuan': 0,
            }
          : path.endsWith('/af/conversations')
              ? {'ok': true, 'list': <Object>[]}
              : {'ok': true};
      return http.Response(
        jsonEncode(body),
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });
    await setPhone(tester, const Size(320, 568));
    await tester.pumpWidget(
      app(AfWorkbenchPage(client: mock, onLogout: () {})),
    );
    await tester.pump(const Duration(milliseconds: 600));
    expect(tester.takeException(), isNull);
  });
}
