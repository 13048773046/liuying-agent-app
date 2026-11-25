import 'package:flutter_test/flutter_test.dart';
import 'package:liuying_agent/main.dart';

void main() {
  testWidgets('品牌启动页结束后进入独立登录门，不进入社区首页', (tester) async {
    await tester.pumpWidget(const LiuyingAgentApp(initialToken: ''));

    // 启动页：品牌字标 + 小萤主视觉，先于登录页出现。
    expect(find.text('LIUYING  /  AGENT'), findsOneWidget);
    expect(find.text('小萤 Agent'), findsOneWidget);
    expect(find.text('正在唤醒小萤'), findsOneWidget);
    expect(find.text('进入 Agent'), findsNothing);

    // 等待启动页计时与切换动画结束。
    await tester.pump(const Duration(milliseconds: 1800));
    await tester.pumpAndSettle();

    expect(find.text('进入 Agent'), findsOneWidget);
    expect(find.text('账号密码'), findsOneWidget);
    expect(find.text('Token'), findsOneWidget);
    expect(find.text('JAPANESE MANGA / 01'), findsOneWidget);
    expect(find.text('进入 Agent'), findsOneWidget);
  });
}
