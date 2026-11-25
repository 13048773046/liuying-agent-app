/// 小萤 Agent · 独立登录页
///
/// 三种入口：账号密码、社区手机验证码、Token。手机验证码复用社区
/// `/auth/send-code` + `/auth/login-code` 与 Cap 人机验证，不另造后端。
library;

import 'package:flutter/material.dart';

import 'api/client.dart';
import 'design/components.dart';
import 'design/flip_countdown_button.dart';
import 'design/manga.dart';
import 'services/secure_store.dart';
import 'widgets/captcha_dialog.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.onLoggedIn});

  final ValueChanged<String> onLoggedIn;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const _modes = ['手机验证码', '密码', 'Token'];
  int _mode = 0;
  final _account = TextEditingController();
  final _password = TextEditingController();
  final _phone = TextEditingController();
  final _code = TextEditingController();
  final _token = TextEditingController();
  bool _busy = false;
  bool _obscure = true;
  bool _agreed = false;
  String? _error;

  @override
  void dispose() {
    _account.dispose();
    _password.dispose();
    _phone.dispose();
    _code.dispose();
    _token.dispose();
    super.dispose();
  }

  bool get _phoneValid => ApiClient.isValidPhone(_phone.text.trim());

  Future<bool> _sendCode() async {
    final phone = _phone.text.trim();
    if (!_phoneValid) {
      setState(() => _error = '请输入正确的手机号');
      return false;
    }
    setState(() => _error = null);
    final captcha = await showCaptchaDialog(context);
    if (captcha == null) return false;
    try {
      await ApiClient.sendLoginCode(phone, captcha);
      if (mounted) showAppToast(context, '验证码已发送到手机');
      return true;
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e is ApiException ? e.message : '发送失败，请检查网络后重试';
        });
      }
      return false;
    }
  }

  Future<void> _submit() async {
    if (_busy) return;
    if (!_agreed) {
      setState(() => _error = '请先阅读并同意用户协议和隐私政策');
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      if (_mode == 0) {
        await _loginWithPhone();
      } else if (_mode == 1) {
        await _loginWithPassword();
      } else {
        await _loginWithToken();
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

  Future<void> _loginWithPhone() async {
    final phone = _phone.text.trim();
    final code = _code.text.trim();
    if (!_phoneValid) throw ApiException(0, '请输入正确的手机号');
    if (code.length != 6) throw ApiException(0, '请输入 6 位验证码');
    final j = await ApiClient.loginCode(phone, code);
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
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(22, 18, 22, 22 + bottom),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _masthead(),
              const SizedBox(height: 16),
              _cover(),
              const SizedBox(height: 16),
              const SpeechBubble(text: '账号与小萤的会话、额度都跟流萤社区打通。手机号验证码登录会自动注册新账号。'),
              const SizedBox(height: 18),
              MangaPanel(
                tag: 'LOGIN / 01',
                padding: const EdgeInsets.fromLTRB(14, 20, 14, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _modeSwitch(),
                    const SizedBox(height: 18),
                    if (_mode == 0)
                      ..._phoneFields()
                    else if (_mode == 1)
                      ..._passwordFields()
                    else ...[
                      _tokenField(),
                    ],
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      _errorBox(_error!),
                    ],
                    const SizedBox(height: 16),
                    _agreement(),
                    const SizedBox(height: 14),
                    PillButton(
                      label: switch (_mode) {
                        0 => '验证码登录 / 注册',
                        1 => '进入 Agent',
                        _ => '用 Token 进入 Agent',
                      },
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
              const SizedBox(height: 14),
              Text(
                '社区原版 Agent 仍在社区里保留，本次是独立版，不影响原入口。',
                textAlign: TextAlign.center,
                style: AppType.micro.copyWith(
                  color: const Color(AppColors.textTertiary),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 6),
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
    );
  }

  Widget _masthead() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Expanded(child: MangaWordmark(compact: true)),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'LOGIN',
              style: AppType.micro.copyWith(
                fontSize: 9,
                letterSpacing: 2.4,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 3),
            const MangaStamp(text: '第 01 话'),
          ],
        ),
      ],
    );
  }

  Widget _cover() {
    return SizedBox(
      height: 226,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 4,
            bottom: 0,
            width: 218,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const MangaTag(text: 'PROLOGUE / 起', onDark: false),
                const SizedBox(height: 12),
                Text(
                  '给目标。\n我拆步骤，\n做完交给你。',
                  style: AppType.display.copyWith(
                    fontSize: 28,
                    height: 1.22,
                    letterSpacing: -1.3,
                  ),
                ),
                const Spacer(),
                Container(height: 4, color: const Color(AppColors.textPrimary)),
                const SizedBox(height: 8),
                Text(
                  '会规划 / 会调工具 / 交成品',
                  style: AppType.micro.copyWith(
                    fontSize: 10,
                    letterSpacing: 0.8,
                    color: const Color(AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            width: 132,
            height: 218,
            child: MangaPanel(
              shadow: true,
              tag: 'CUT / 01',
              color: const Color(AppColors.card),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned(
                    left: 4,
                    right: 4,
                    top: 8,
                    bottom: 26,
                    child: const MangaCutout(
                      asset: 'assets/brand/xiaoying_portrait.png',
                      height: 178,
                    ),
                  ),
                  Positioned(
                    left: 8,
                    right: 8,
                    bottom: 7,
                    child: Text(
                      '小萤 / ONLINE',
                      style: AppType.micro.copyWith(
                        fontSize: 8,
                        letterSpacing: 1.0,
                        fontWeight: FontWeight.w800,
                        color: const Color(AppColors.accent),
                      ),
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

  Widget _modeSwitch() {
    return Row(
      children: [
        for (var i = 0; i < _modes.length; i++) ...[
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _busy
                  ? null
                  : () => setState(() {
                      _mode = i;
                      _error = null;
                    }),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: _mode == i
                          ? const Color(AppColors.textPrimary)
                          : const Color(AppColors.hairline),
                      width: _mode == i ? 2.5 : 1,
                    ),
                  ),
                ),
                child: Text(
                  _modes[i],
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: AppType.micro.copyWith(
                    fontSize: 11,
                    fontWeight: _mode == i ? FontWeight.w900 : FontWeight.w500,
                    color: _mode == i
                        ? const Color(AppColors.textPrimary)
                        : const Color(AppColors.textTertiary),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  List<Widget> _passwordFields() => [
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
          _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          size: 18,
          color: const Color(AppColors.textTertiary),
        ),
      ),
    ),
  ];

  List<Widget> _phoneFields() => [
    _field(
      controller: _phone,
      hint: '11 位手机号',
      icon: Icons.phone_iphone_rounded,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.telephoneNumber],
      onChanged: (_) => setState(() {}),
    ),
    const SizedBox(height: 12),
    Row(
      children: [
        Expanded(
          child: _field(
            controller: _code,
            hint: '6 位验证码',
            icon: Icons.password_rounded,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
          ),
        ),
        const SizedBox(width: 8),
        FlipCountdownButton(
          onSend: _sendCode,
          enabled: _phoneValid && !_busy,
          width: 112,
          idleLabel: '获取验证码',
        ),
      ],
    ),
    const SizedBox(height: 8),
    Text(
      '首次登录会自动创建账号；验证码 5 分钟内有效。',
      style: AppType.micro.copyWith(
        color: const Color(AppColors.textTertiary),
        height: 1.5,
      ),
    ),
  ];

  Widget _tokenField() => Column(
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

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    List<String>? autofillHints,
    ValueChanged<String>? onSubmitted,
    ValueChanged<String>? onChanged,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      onSubmitted: onSubmitted,
      onChanged: onChanged,
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
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppRadius.rSm,
          borderSide: BorderSide(
            color: Color(AppColors.textPrimary),
            width: 1.5,
          ),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppRadius.rSm,
          borderSide: BorderSide(color: Color(AppColors.accent), width: 2),
        ),
        disabledBorder: const OutlineInputBorder(
          borderRadius: AppRadius.rSm,
          borderSide: BorderSide(color: Color(AppColors.hairline)),
        ),
      ),
    );
  }

  Widget _agreement() {
    return GestureDetector(
      onTap: _busy ? null : () => setState(() => _agreed = !_agreed),
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: _agreed
                  ? const Color(AppColors.textPrimary)
                  : const Color(AppColors.card),
              border: Border.all(
                color: const Color(AppColors.textPrimary),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
            child: _agreed
                ? const Icon(
                    Icons.check_rounded,
                    size: 12,
                    color: Color(AppColors.card),
                  )
                : null,
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              '我已阅读并同意《用户协议》和《隐私政策》',
              style: AppType.micro.copyWith(
                fontSize: 10.5,
                color: const Color(AppColors.textSecondary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorBox(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(AppColors.card),
        border: Border.all(color: const Color(AppColors.danger), width: 1.5),
        borderRadius: AppRadius.rSm,
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
