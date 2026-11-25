# 验收记录 · 小萤 Agent 1.0.0

验收日期：2026-11-25（UTC+8）

## 1. 静态检查

```text
$ flutter analyze
Analyzing liuying-agent-app...
No issues found! (ran in 157.0s)
```

Flutter 3.47.7 / stable，Dart SDK `^3.13.5`。

## 2. 自动化测试

```text
$ flutter test
00:03 +8: All tests passed!
```

覆盖：

- 品牌启动页 → 登录门，确认不会进入社区首页
- 390×844 启动页视觉基线
- 390×844 登录页视觉基线
- 390×844 Agent 欢迎页视觉基线
- 320×568 登录页布局（不溢出）
- 320×568 登录页 1.3 倍字体（不溢出）
- 320×568 Agent 欢迎页布局（不溢出）

视觉基线位于 `test/goldens/`，文档截图位于 `docs/screenshots/`。测试已加载 NotoSansSC 与 MaterialIcons 字体，截图中的图标为真实图标字形。

## 3. Android Release

```text
产物：build/app/outputs/flutter-apk/app-release.apk
大小：67.0 MB（ls 64 MB）
SHA-256：49523da9d2dad7ed6d80b07bcc16f3e87fb05b4b524b86cda459903a7deaedbb
```

`aapt dump badging`：

```text
package: name='com.liuying.agent' versionCode='1' versionName='1.0.0'
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

## 4. 生产接口连通性

```text
GET https://www.dbmt999.asia/community/api/af/models  -> HTTP 200 {"ok":true,"list":[]}
GET https://www.dbmt999.asia/community/api/af/quota   -> HTTP 401 {"ok":false,"error":"login required"}
```

说明生产域名、证书、路由与鉴权边界可达；未登录请求被正确拒绝。

## 5. iOS

- `Info.plist`：显示名「小萤 Agent」、Bundle ID `com.liuying.agent`、相机/相册/麦克风/语音识别用途说明、ATS 禁止任意明文、`ITSAppUsesNonExemptEncryption=false`、手机仅竖屏。
- 启动屏背景 `#050807`，LaunchImage 为方形小萤图标。
- AppIcon 全尺寸已生成。
- 未签名 IPA 由 `.github/workflows/ios-unsigned.yml` 在 macOS 上构建，产出后上传 GitHub Release。

## 6. 视觉验收

| 页面 | 检查点 | 结果 |
| --- | --- | --- |
| 启动页 | 品牌字标、完整主视觉、对话框、加载条、ONLINE 贴纸 | 通过 |
| 登录页 | 头图、左侧字标、独立版贴纸、台词气泡、LOGIN / 01、两种登录方式 | 通过 |
| Agent 欢迎页 | 欢迎插画、AGENT / READY、在线状态、三步说明、建议问题、模式栏、输入栏 | 通过 |
| 小屏 320×568 | 登录页、欢迎页、1.3 倍字体 | 通过 |

额度栏按真实 `/af/quota` 字段显示：`剩余 3.0万 · 5h 2.0万 · FREE · ¥0.00`。此前 mock 只返回 `left` 导致显示 0 的问题已修正，mock 已对齐 `left` / `gift_left` / `w5h_left` / `limit_w5h` / `balance_yuan`。

## 7. 尚未覆盖

- 真实账号登录、SSE `/af/chat`、附件上传、工具卡和文件下载未在真机/模拟器上跑通；本环境只有 Linux，无 Android 模拟器与 iPhone。生产接口可达性与未授权拒绝已验证。
- Android APK 未做真机安装启动截图；包结构、签名、权限、应用名已通过 `aapt` / `apksigner` 核验。
- iOS 为未签名 IPA，需要自签工具安装。

## 8. 安全边界

- `android/key.properties`、`*.jks`、`brand_src/`、`build/`、`release/` 均在 `.gitignore` 中。
- 仓库不含 Token、密码、签名私钥。
- 登录 Token 使用 `flutter_secure_storage`；退出登录会调用 `ApiClient.logout()` 清理。
