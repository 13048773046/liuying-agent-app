# 验收记录 · 小萤 Agent 1.0.1

验收日期：2026-11-25（UTC+8）

## 1. 静态检查

```text
$ flutter analyze
Analyzing liuying-agent-app...
No issues found! (ran in 155.7s)
```

Flutter 3.47.7 / stable，Dart SDK `^3.13.5`。

## 2. 自动化测试

```text
$ flutter test
All tests passed!
```

覆盖：

- 品牌启动页 → 登录门，确认不会进入社区首页
- 390×844 启动页视觉基线
- 390×844 登录页视觉基线（密码模式）
- 390×844 手机验证码登录视觉基线
- 390×844 Agent 欢迎页视觉基线
- 390×844 对话页视觉基线（用户气泡 / AI 卡片 / 思考折叠 / 操作栏）
- 390×844 会话抽屉视觉基线
- 390×844 推理档位弹层视觉基线
- 320×568 登录页布局（不溢出）
- 320×568 登录页 1.3 倍字体（不溢出）
- 320×568 Agent 欢迎页布局（不溢出）

视觉基线位于 `test/goldens/`，文档截图位于 `docs/screenshots/`。测试已加载 NotoSansSC 与 MaterialIcons 字体，截图中的图标为真实图标字形。

## 3. Android Release

```text
产物：release/小萤Agent-1.0.1-Android.apk
大小：49 MB（ls 51.0 MB）
SHA-256：310ee293d8998cad480f6be360e849185b94439aec60d3aedc358d23fcde965f
```

`aapt2 dump badging`：

```text
package: name='com.liuying.agent' versionCode='2' versionName='1.0.1'
sdkVersion:'24'
targetSdkVersion:'36'
application-label:'小萤 Agent'
```

`apksigner verify --print-certs`：

```text
Signer #1 certificate DN: CN=Liuying Agent, OU=Agent, O=Liuying, L=Suzhou, ST=Jiangsu, C=CN
Signer #1 certificate SHA-256 digest: 6735acf69f18cc57a26cd6b7dddfa0b54210806ae04bae28b93326532bbf6dfd
```

权限仅保留：网络、网络状态、相机、录音、读图片（旧系统读外部存储）。`allowBackup=false`，`usesCleartextTraffic=false`。

原生启动资源已替换为纸白漫画版：

- `values/colors.xml`、`values/styles.xml`、`values-night/styles.xml`：`#F6F1E6` 启动底色 + 浅色状态栏。
- `values-v31/styles.xml`：Android 12 `windowSplashScreenBackground` / `windowSplashScreenAnimatedIcon`。
- `drawable-*/splash_logo.png`：160dp 纸白漫画 App 图标。
- `mipmap-*/ic_launcher*.png`：新纸白漫画图标与 adaptive foreground。

## 4. 手机号验证码后端

生产接口：`https://www.dbmt999.asia/community/api`

已核验：

```text
GET  /captcha/config
     {"ok":true,"provider":"cap","app_id":"","mode":"2"}
GET  /captcha/cap-page
     200，页面约 3.5KB，含 cap-widget 与 CapCaptchaBridge
POST /auth/send-code  非法 identifier
     "请输入正确的手机号或邮箱"
POST /auth/send-code  合法手机号、不带 Captcha
     "请先完成安全验证"
POST /auth/login-code 手机号 + 错误验证码
     "验证码错误或已过期"
GET  /af/models
     200
GET  /af/quota 未带 Token
     401 login required
```

结论：手机验证码路由、强制人机校验、Cap 页面与 `/af` 鉴权边界均可达。真实短信发送、真实短信到达、Cap WebView 挑战回传 Token、真实账号 `/af/quota` 需要真人手机号，未在本环境执行。

## 5. iOS

- `Info.plist`：显示名「小萤 Agent」、Bundle ID `com.liuying.agent`、相机/相册/麦克风/语音识别用途说明、ATS 禁止任意明文、`ITSAppUsesNonExemptEncryption=false`、手机仅竖屏。
- `LaunchScreen.storyboard`：纸白背景，`LaunchImage` 安全区内等比显示；LaunchImage 为 390×844 / 780×1688 / 1170×2532 三档纸白漫画封面。
- AppIcon 全尺寸已生成，已去除 alpha 通道。
- 未签名 IPA 由 GitHub Actions `macos-15` 构建；产物 `release/小萤Agent-1.0.1-iOS-unsigned.ipa`，21 MB，SHA-256 `a82bd28f83d454cec6448f1a22b8804d97707ff848debc6cc3b6e8344d896e4c`。
- IPA 内 `CFBundleShortVersionString=1.0.1`、`CFBundleVersion=2`、arm64、最低 iOS 15.0、无 `_CodeSignature`。

## 6. 视觉验收

| 页面 | 检查点 | 结果 |
| --- | --- | --- |
| 启动页 | 纸白封面、刊头、红色「第01话」印章、巨大字标、透明小萤分镜、对话框、加载线 | 通过 |
| 登录页 | 透明头肩像、三模式切换、手机验证码默认、硬边表单、协议默认未勾选 | 通过 |
| Agent 欢迎页 | 纸白头部、额度票签、大字标语、透明小萤、分镜三步、建议问题、模式栏、输入栏 | 通过 |
| 对话页 | 黑色用户气泡、AI 纸白回复框、小萤头像、REPLY / 本话、完成红章、思考折叠、操作栏 | 通过 |
| 会话抽屉 | 章节索引、当前会话薄荷纸签、记忆与偏好、退出登录、新建对话 | 通过 |
| 推理档位 | 纸白卡、2px 墨线、硬阴影、黑轨纸白滑块、SETTING / 03 标题 | 通过 |
| 小屏 320×568 | 登录页、欢迎页、1.3 倍字体 | 通过 |

## 7. 尚未覆盖

- 真实手机号短信、真实短信到达、Cap WebView 在独立 App 内完成挑战并回传 Token、真实账号 `/af/quota` 未在设备上执行。
- SSE `/af/chat`、附件上传、工具卡和文件下载未在真机/模拟器上跑通；本环境只有 Linux，无 Android 模拟器与 iPhone。
- Android APK 未做真机安装启动截图；包结构、签名、权限、应用名、原生资源映射已通过 `aapt2` / `apksigner` 核验。
- iOS 为未签名 IPA，需要 AltStore / Sideloadly / 自签工具安装。

## 8. 安全边界

- `android/key.properties`、`*.jks`、构建产物与签名私钥在 `.gitignore` 中。
- 仓库不含 Token、密码、签名私钥。
- 登录 Token 使用 `flutter_secure_storage`；退出登录会调用 `ApiClient.logout()` 清理。
