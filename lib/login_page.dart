/// 小萤 Agent · 独立登录页
///
/// 账号与流萤社区/音乐互通；登录后直接进入 Agent，不再进入社区首页。
library;

import 'package:flutter/material.dart';

import 'api/client.dart';
import 'design/components.dart';
import 'design/manga.dart';
import 'services/secure_store.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.onLoggedIn});

  final ValueChanged<String> onLoggedIn;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _account = TextEditingController();
  final _password = TextEditingController();
  final _token = TextEditingController();
  bool _tokenMode = false;
  bool _busy = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _account.dispose();
    _password.dispose();
    _token.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      if (_tokenMode) {
        await _loginWithToken();
      } else {
        await _loginWithPassword();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e is ApiException
            ? e.message
            : e is SecureStoreException
            ? e.message
            : '登录失败，请检查网络后重试';
        _busy = false;
      });
    }
  }

  Future<void> _loginWithPassword() async {
    final account = _account.text.trim();
    final password = _password.text;
    if (account.isEmpty || password.isEmpty) {
      throw ApiException(0, '请填写账号和密码');
    }
    final j = await ApiClient.login(account, password);
    final token = (j['token'] ?? '').toString();
    if (token.isEmpty) throw ApiException(0, '登录未返回 token');
    await _finishLogin(token, j);
  }

  Future<void> _loginWithToken() async {
    final token = _token.text.trim();
    if (token.isEmpty) throw ApiException(0, '请粘贴社区 token');
    ApiClient.token = token;
    try {
      final j = await ApiClient.myProfile();
      await _finishLogin(token, j);
    } catch (_) {
      ApiClient.token = null;
      rethrow;
    }
  }

  Future<void> _finishLogin(String token, Map<String, dynamic> payload) async {
    await SecureStore.write(SecureStore.tokenKey, token);
    ApiClient.token = token;
    final user = payload['user'];
    if (user is Map) {
      ApiClient.meProfile = Map<String, dynamic>.from(user);
      ApiClient.userId = (user['id'] ?? '').toString();
      ApiClient.meSignature = (user['signature'] ?? '').toString();
    } else {
      ApiClient.userId = (payload['id'] ?? '').toString();
      ApiClient.meSignature = (payload['signature'] ?? '').toString();
    }
    if (!mounted) return;
    widget.onLoggedIn(token);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return ImmersivePage(
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.0, -0.55),
                  radius: 1.15,
                  colors: [
                    const Color(AppColors.accent).withValues(alpha: 0.13),
                    const Color(AppColors.bg),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(24, 34, 24, 24 + bottom),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _brand(),
                  const SizedBox(height: 18),
                  MangaPanel(
                    tag: 'LOGIN / 01',
                    padding: const EdgeInsets.fromLTRB(14, 18, 14, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _modeSwitch(),
                        const SizedBox(height: 18),
                        if (_tokenMode) _tokenField() else ..._passwordFields(),
                        if (_error != null) ...[
                          const SizedBox(height: 12),
                          _errorBox(_error!),
                        ],
                        const SizedBox(height: 18),
                        PillButton(
                          label: _tokenMode ? '用 Token 进入 Agent' : '进入 Agent',
                          trailingIcon: Icons.arrow_forward_rounded,
                          size: PillSize.lg,
                          expand: true,
                          loading: _busy,
                          glow: true,
                          onTap: _submit,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '账号、会话与额度与流萤社区共用；\n社区原版 Agent 仍然保留，不受影响。',
                    textAlign: TextAlign.center,
                    style: AppType.micro.copyWith(
                      color: const Color(AppColors.textTertiary),
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '登录即表示同意《用户协议》与《隐私政策》',
                    textAlign: TextAlign.center,
                    style: AppType.micro.copyWith(
                      color: const Color(AppColors.textDisabled),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _brand() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MangaPanel(
          tag: 'JAPANESE MANGA / 01',
          padding: EdgeInsets.zero,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/brand/login_hero.jpg',
                  fit: BoxFit.cover,
                  alignment: Alignment.centerRight,
                  filterQuality: FilterQuality.medium,
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Color(0xF20A0C0B),
                        Color(0xD90A0C0B),
                        Color(0x1A0A0C0B),
                        Color(0x000A0C0B),
                      ],
                      stops: [0, 0.34, 0.62, 1],
                    ),
                  ),
                ),
                Positioned(
                  left: 14,
                  top: 13,
                  bottom: 13,
                  right: 118,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const MangaWordmark(compact: true, onImage: true),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const MangaTag(text: '独立版'),
                          const SizedBox(height: 7),
                          Text(
                            '会规划 · 会调工具 · 交成品',
                            style: AppType.micro.copyWith(
                              fontSize: 10,
                              letterSpacing: 0.6,
                              height: 1.3,
                              color: const Color(0xB8F6F2E9),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        const SpeechBubble(text: '给目标，我拆步骤，做完交给你。轻活在本机，重活交给云沙箱。'),
      ],
    );
  }

  Widget _modeSwitch() {
    return Align(
      alignment: Alignment.centerLeft,
      child: SegmentedTabs(
        labels: const ['账号密码', 'Token'],
        index: _tokenMode ? 1 : 0,
        onChanged: (i) {
          if (_busy) return;
          setState(() {
            _tokenMode = i == 1;
            _error = null;
          });
        },
      ),
    );
  }

  List<Widget> _passwordFields() {
    return [
      _field(
        controller: _account,
        hint: '用户名或邮箱',
        icon: Icons.person_outline_rounded,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
        autofillHints: const [AutofillHints.username],
      ),
      const SizedBox(height: 12),
      _field(
        controller: _password,
        hint: '密码',
        icon: Icons.lock_outline_rounded,
        obscure: _obscure,
        textInputAction: TextInputAction.done,
        autofillHints: const [AutofillHints.password],
        onSubmitted: (_) => _submit(),
        suffix: IconButton(
          onPressed: () => setState(() => _obscure = !_obscure),
          icon: Icon(
            _obscure
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            size: 18,
            color: const Color(AppColors.textTertiary),
          ),
        ),
      ),
    ];
  }

  Widget _tokenField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _field(
          controller: _token,
          hint: '粘贴流萤社区 token',
          icon: Icons.key_rounded,
          keyboardType: TextInputType.visiblePassword,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submit(),
        ),
        const SizedBox(height: 8),
        Text(
          'token 可在流萤社区网页版登录后获取；仅保存在本机安全存储。',
          style: AppType.micro.copyWith(
            color: const Color(AppColors.textTertiary),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    List<String>? autofillHints,
    ValueChanged<String>? onSubmitted,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      onSubmitted: onSubmitted,
      enabled: !_busy,
      style: AppType.body,
      cursorColor: const Color(AppColors.accent),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppType.bodySm.copyWith(
          color: const Color(AppColors.textTertiary),
        ),
        prefixIcon: Icon(
          icon,
          size: 18,
          color: const Color(AppColors.textTertiary),
        ),
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(AppColors.card),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.rMd,
          borderSide: const BorderSide(color: Color(AppColors.border)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.rMd,
          borderSide: BorderSide(
            color: const Color(AppColors.accent).withValues(alpha: 0.8),
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.rMd,
          borderSide: const BorderSide(color: Color(AppColors.hairline)),
        ),
      ),
    );
  }

  Widget _errorBox(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(AppColors.danger).withValues(alpha: 0.1),
        borderRadius: AppRadius.rSm,
        border: Border.all(
          color: const Color(AppColors.danger).withValues(alpha: 0.32),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 16,
            color: Color(AppColors.danger),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: AppType.caption.copyWith(
                color: const Color(AppColors.danger),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
