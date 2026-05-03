# 📱 5G 随身WiFi iOS 应用（简化版）

这个版本专门为了快速通过 GitHub Actions 编译而优化！

---

## 🚀 5 分钟快速上手（推荐！）

### 步骤 1：创建 GitHub 仓库

1. 访问 https://github.com 并登录/注册
2. 点击 "New repository" 创建新仓库
3. 仓库名称：`5GMobileWiFi`（可以随意）
4. 点击 "Create repository"

### 步骤 2：上传代码

在 GitHub 仓库页面：
- 点击 "uploading an existing file"
- 把 `iOSApp_Simple` 文件夹里的**所有内容**（不是文件夹本身）拖进去
- 点击 "Commit changes"

### 步骤 3：自动编译

1. 点击仓库顶部的 "Actions" 选项卡
2. 点击左侧的 "Build 5GMobileWiFi IPA"
3. 点击右侧的 "Run workflow" 按钮
4. 等待 3-5 分钟

### 步骤 4：下载 IPA

- 编译成功后（绿色 ✓），点击该次 workflow
- 在页面底部找到 "Artifacts"
- 点击 "5GMobileWiFi-IPA" 下载

### 步骤 5：安装到手机

1. 下载 Sideloadly：https://sideloadly.io/
2. 连接 iPhone 到电脑
3. 把下载的 IPA 拖进 Sideloadly
4. 输入你的 Apple ID（免费的就行）
5. 点击 Start

第一次打开需要在 iPhone 设置里信任证书！

---

## 💡 如果你有 Mac

直接用 Xcode 打开 `5GMobileWiFi.xcodeproj`，连接手机点击运行即可。

---

## 🎉 功能说明

- ✅ 主页 - 显示设备状态、信号、流量等
- ✅ 短信 - 收发和转发短信
- ✅ 网络 - 移动网络、DNS、VPN 等设置
- ✅ WiFi - 2.4G/5G WiFi 设置
- ✅ 设置 - 系统管理、设备连接

---

## 📝 注意

当前是演示版，使用模拟数据。连接真实设备需要实现 API 通信。
