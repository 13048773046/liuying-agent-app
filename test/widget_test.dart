import 'package:flutter_test/flutter_test.dart';
import 'package:liuying_agent/main.dart';

void main() {
  testWidgets('品牌启动页结束后进入独立登录门，不进入社区首页', (tester) async {
    await tester.pumpWidget(const LiuyingAgentApp(initialToken: ''));

    // 启动页：品牌字标 + 小萤主视觉，先于登录页出现。
    expect(find.text('LIUYING COMICS'), findsOneWidget);
    expect(find.text('AGENT'), findsOneWidget);
    expect(find.text('给目标，\n拆步骤，\n交成品。'), findsOneWidget);
    expect(find.text('正在唤醒小萤'), findsOneWidget);
    expect(find.text('验证码登录 / 注册'), findsNothing);

    // 等待启动页计时与切换动画结束。
    await tester.pump(const Duration(milliseconds: 1800));
    await tester.pumpAndSettle();

    expect(find.text('验证码登录 / 注册'), findsOneWidget);
    expect(find.text('手机验证码'), findsOneWidget);
    expect(find.text('Token'), findsOneWidget);
    expect(find.text('LOGIN / 01'), findsOneWidget);
  });
}
