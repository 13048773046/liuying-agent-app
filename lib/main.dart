/// 小萤 Agent · 独立 App 入口
///
/// 只承载小萤 Agent 工作台；账号、会话、额度复用流萤社区 /af 后端。
/// 社区原版代码不做任何改动，本工程是独立复制出来的壳。
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'api/client.dart';
import 'design/components.dart';
import 'design/manga.dart';
import 'design/tokens.dart';
import 'login_page.dart';
import 'pages/home/af_workbench_page.dart';
import 'services/secure_store.dart';
import 'splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.portraitUp,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  String token = '';
  try {
    await SecureStore.migrateLegacy();
    token = await SecureStore.read(SecureStore.tokenKey) ?? '';
    if (token.isNotEmpty) ApiClient.token = token;
  } catch (_) {}
  runApp(LiuyingAgentApp(initialToken: token));
}

class LiuyingAgentApp extends StatelessWidget {
  const LiuyingAgentApp({super.key, required this.initialToken});

  final String initialToken;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '小萤 Agent',
      debugShowCheckedModeBanner: false,
      theme: buildImmersiveTheme(),
      builder: (ctx, child) {
        final scale = MediaQuery.textScalerOf(ctx)
            .clamp(minScaleFactor: 0.9, maxScaleFactor: 1.15);
        return MangaBackdrop(
          child: MediaQuery(
            data: MediaQuery.of(ctx).copyWith(textScaler: scale),
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
      home: _BootGate(initialToken: initialToken),
    );
  }
}

class _BootGate extends StatefulWidget {
  const _BootGate({required this.initialToken});

  final String initialToken;

  @override
  State<_BootGate> createState() => _BootGateState();
}

class _BootGateState extends State<_BootGate> {
  bool _ready = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 360),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeIn,
      child: _ready
          ? AuthGate(
              key: const ValueKey('auth'),
              initialToken: widget.initialToken,
            )
          : SplashPage(
              key: const ValueKey('splash'),
              onDone: () {
                if (mounted) setState(() => _ready = true);
              },
            ),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key, required this.initialToken});

  final String initialToken;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late String _token = widget.initialToken.trim();

  void _onLoggedIn(String token) {
    setState(() => _token = token.trim());
  }

  Future<void> _logout() async {
    await ApiClient.logout();
    await SecureStore.clearAuth();
    ApiClient.token = null;
    ApiClient.userId = null;
    ApiClient.meProfile = null;
    ApiClient.meSignature = null;
    if (!mounted) return;
    setState(() => _token = '');
  }

  @override
  Widget build(BuildContext context) {
    if (_token.isEmpty) return LoginPage(onLoggedIn: _onLoggedIn);
    return AfWorkbenchPage(onLogout: _logout);
  }
}
