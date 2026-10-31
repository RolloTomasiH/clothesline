<picture>
  <source media="(prefers-color-scheme: dark)" srcset="docs/images/zh-Hans/hero-dark.png">
  <img src="docs/images/zh-Hans/hero-light.png" alt="晾衣绳 (Clothesline)。截图、剪贴板与便笺，优雅挂在屏幕顶栏。">
</picture>

<h1 align="center">晾衣绳 · Clothesline for macOS</h1>

<p align="center">
  <b>看不见，却够得着。为 macOS 打造的灵动挂绳工作台。</b><br>
  截图悬挂 · 剪贴板历史 · 灵感便笺 · 原生物理微风摆动
</p>

<p align="center">
  <a href="https://github.com/RolloTomasiH/clothesline/releases/latest">下载 DMG 安装包&nbsp;&rsaquo;</a>
  &nbsp;&nbsp;·&nbsp;&nbsp;
  <a href="#从源码构建">从源码构建&nbsp;&rsaquo;</a>
  &nbsp;&nbsp;·&nbsp;&nbsp;
  <a href="#溯源与开源协议致谢">溯源致谢&nbsp;&rsaquo;</a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/macOS-14.0%2B-blue?logo=apple" alt="macOS 14+">
  <img src="https://img.shields.io/badge/Architecture-Universal%20(ARM64%20%2B%20x86__64)-purple" alt="Universal Binary">
  <img src="https://img.shields.io/badge/License-MIT-green.svg" alt="License: MIT">
  <img src="https://img.shields.io/badge/Fork-alejandrobujan%2Ftendedero-orange" alt="Forked from tendedero">
</p>

---

> [!NOTE]
> ### 溯源与致谢 (Upstream Attribution & Acknowledgments)
> 
> 本项目为开源项目 **[alejandrobujan/tendedero](https://github.com/alejandrobujan/tendedero)** 的深度定制与中文增强分支（Enhanced Fork）。
> 
> 衷心感谢原作者 **[Alejandro Buján](https://alejandrobujan.com)** 卓越的创意设计与优雅的 macOS 灵动挂绳物理原型！
> 
> **开源合规与商标声明**：
> 1. 原项目遵循 [MIT License](LICENSE)，本项目完整保留原作者的版权声明与许可文件。
> 2. 原作者在原版许可中明确声明保留「Tendedero」名称与原版图标之所有权，并指出 fork 版本需自备独立名称与图标。
> 3. 本项目严格遵从上述规范，全面重命名为 **「晾衣绳 (Clothesline)」**，并自研拓展了三绳架构、剪贴板捕获、即时便笺编辑器与原生构建管道。

---

<br>

## 核心特性与增强

### 1. 三绳多维工作台 (Tri-Line System)
原版仅支持单一屏幕截图挂起，本项目重构了核心数据总线，升级为三大独立挂绳形态，自由无缝切换：
- 📷 **截图绳 (Screenshots)**：拍下截图或录屏瞬间挂上顶栏，跳过杂乱桌面，不占屏幕空间。
- 📋 **剪贴板绳 (Clipboard History)**：轻量级后台监听，自动捕获复制的文字片段或代码块（内置防自身回环机制），需要时随手取下。
- 📝 **灵动便笺绳 (Sticky Notes)**：轻量级便笺卡片，随时呼出编辑器记录临时灵感、待办要点，像便利贴一样轻盈夹在屏幕顶端。

<br>

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="docs/images/zh-Hans/demo-dark.gif">
  <img src="docs/images/zh-Hans/demo-light.gif" alt="指针停在上边缘，绳子带着卡片轻轻摇晃着滑下来，单击复制其中一张，指针离开后绳子收起。">
</picture>

<br>

### 2. 每个动作都有自然手势

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="docs/images/zh-Hans/bento-dark.png">
  <img src="docs/images/zh-Hans/bento-light.png" alt="单击复制。长按标记。拖拽分享。松手放下。">
</picture>

| 手势 / 操作 | 响应行为 |
|:---|:---|
| **单击** | 快速复制内容到剪贴板，随处粘贴。 |
| **长按** | 针对截图调用 macOS 原生「标记 (Markup)」涂鸦与批注。 |
| **双击** | 使用系统「预览」打开大图查看。 |
| **用力点按 (Force Touch)** | 使用「快速查看 (Quick Look)」悬浮预览。 |
| **拖入 App** | 传递一份副本（邮件、微信、文档），原件仍稳固挂在绳上。 |
| **拖入文件夹 / 桌面** | 永久保存至本地，卡片顺理成章从绳上摘除。 |
| **下拉轻甩 / 点叉** | 物理重力脱落动画，轻松丢弃。 |
| **指针靠近顶部菜单栏** | 晾衣绳轻盈滑下悬停；指针移开无感收拢。 |
| **全局快捷键** | 默认支持快捷唤出与隐藏，可在菜单栏设置中自定义。 |

<br>

### 3. 极度克制与隐私安全
- **零网络外联**：纯原生 Swift + AppKit / SwiftUI 编写，零第三方网络跟踪，所有数据全本地运行。
- **内存极小**：Universal 二进制包仅约 2.6 MB，极低 CPU 与内存占用。

---

## 快速安装与使用

### 方式一：直接下载 DMG 安装（推荐）
前往 [Releases 页面](https://github.com/RolloTomasiH/clothesline/releases) 下载最新的 `晾衣绳-1.5.2.dmg`，双击后将「晾衣绳」拖入 `Applications` 文件夹即可。

### 方式二：从源码本地构建 (无需 Xcode 笨重工程)
本项目内置原生快速编译脚本，基于 Swift 命令行工具链即可一秒打包 Universal (Apple Silicon M系列 + Intel) 双架构应用：

```bash
# 1. 克隆本仓库
git clone https://github.com/RolloTomasiH/clothesline.git
cd clothesline

# 2. 编译生成 Universal 应用包
./scripts/build-app.sh release

# 3. 运行应用
open build/晾衣绳.app
```

如需制作高质量原生 DMG 镜像：
```bash
./scripts/make-dmg.sh
# 生成路径: build/晾衣绳-1.5.2.dmg
```

---

## 快捷键速查

| 功能 | 默认快捷键 |
|:---|:---|
| 显示 / 隐藏晾衣绳 | <kbd>⌃</kbd>&thinsp;<kbd>⌥</kbd>&thinsp;<kbd>T</kbd> |
| 临时固定挂绳 | 点击菜单栏图标 |
| 取消选择 / 收起 | 点击屏幕空白处或菜单栏 |

---

## 许可证 (License)

本项目遵循 **MIT License** 开源。详细条款请见 [LICENSE](LICENSE)。

- 原始项目著作权归原作者所有：Copyright (c) 2026 Alejandro Buján
- 增强功能与中文定制著作权归属：Copyright (c) 2026 RolloTomasiH
- Upstream: https://github.com/alejandrobujan/tendedero
