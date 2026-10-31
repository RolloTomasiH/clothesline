<picture>
  <source media="(prefers-color-scheme: dark)" srcset="docs/images/zh-Hans/hero-dark.png">
  <img src="docs/images/zh-Hans/hero-light.png" alt="晾衣绳 (Clothesline)。截图、剪贴板与便笺，优雅挂在屏幕顶栏。">
</picture>

<h1 align="center">晾衣绳 · Clothesline (macOS & Windows)</h1>

<p align="center">
  <b>看不见，却够得着。双平台灵动挂绳工作台。</b><br>
  截图悬挂 · 剪贴板历史 · 灵感便笺 · 原生物理微风摆动
</p>

<p align="center">
  <a href="https://github.com/RolloTomasiH/clothesline/releases/latest">📦 立即下载最新版安装包&nbsp;&rsaquo;</a>
  &nbsp;&nbsp;·&nbsp;&nbsp;
  <a href="#快速安装与使用">安装与运行指南&nbsp;&rsaquo;</a>
  &nbsp;&nbsp;·&nbsp;&nbsp;
  <a href="#溯源与开源协议致谢">溯源致谢&nbsp;&rsaquo;</a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Platform-macOS%20%7C%20Windows-blue" alt="macOS & Windows">
  <img src="https://img.shields.io/badge/macOS-Universal%20(ARM64%20%2B%20x86__64)-purple" alt="macOS Universal">
  <img src="https://img.shields.io/badge/Windows-x64%20(Setup%20%2B%20Portable)-0078d4" alt="Windows x64">
  <img src="https://img.shields.io/badge/License-MIT-green.svg" alt="License: MIT">
  <img src="https://img.shields.io/badge/Fork-alejandrobujan%2Ftendedero-orange" alt="Forked from tendedero">
</p>

---

> [!NOTE]
> ### 溯源与致谢 (Upstream Attribution & Acknowledgments)
> 
> 本项目为开源项目 **[alejandrobujan/tendedero](https://github.com/alejandrobujan/tendedero)** 的深度定制、多平台重构与中文增强分支（Enhanced Fork）。
> 
> 衷心感谢原作者 **[Alejandro Buján](https://alejandrobujan.com)** 卓越的创意设计与优雅的 macOS 灵动挂绳物理原型！
> 
> **开源合规与商标声明**：
> 1. 原项目遵循 [MIT License](LICENSE)，本项目完整保留原作者版权声明与许可条款。
> 2. 原作者在原版许可中明确声明保留「Tendedero」名称与原版图标之所有权，并指出 fork 版本需自备独立名称与图标。
> 3. 本项目严格遵从上述规范，全面重命名为 **「晾衣绳 (Clothesline)」**，并自研拓展了三绳架构、剪贴板捕获、即时便笺编辑器，以及全新的 **Windows 原生桌面支持**。

---

<br>

## 核心特性与多端一致体验

### 1. 三绳多维工作台 (Tri-Line System)
原版仅支持单一屏幕截图挂起，本项目重构了核心数据流，升级为三大独立挂绳形态，自由无缝切换：
- 📷 **截图绳 (Screenshots)**：拍下截图瞬间挂上顶栏（macOS 监听原生截图；Windows 监听系统截图目录 `Pictures\Screenshots`），跳过杂乱桌面，不占屏幕空间。
- 📋 **剪贴板绳 (Clipboard History)**：轻量级后台监听，自动捕获复制的文字片段或代码块（内置防自身回环机制），需要时随手取下。
- 📝 **灵动便笺绳 (Sticky Notes)**：轻量级便笺卡片，随时呼出编辑器记录临时灵感、待办要点，像便利贴一样轻盈夹在屏幕顶端。

<br>

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="docs/images/zh-Hans/demo-dark.gif">
  <img src="docs/images/zh-Hans/demo-light.gif" alt="指针停在上边缘，绳子带着卡片轻轻摇晃着滑下来，单击复制其中一张，指针离开后绳子收起。">
</picture>

<br>

### 2. 双平台手势与交互

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="docs/images/zh-Hans/bento-dark.png">
  <img src="docs/images/zh-Hans/bento-light.png" alt="单击复制。长按标记。拖拽分享。松手放下。">
</picture>

| 手势 / 操作 | macOS 响应行为 | Windows 响应行为 |
|:---|:---|:---|
| **单击** | 快速复制内容到剪贴板 | 快速复制内容到剪贴板（浮现 Toast 提示） |
| **长按** | 调用 macOS 原生「标记 (Markup)」批注 | 长按快捷查看 |
| **双击** | 使用系统「预览」打开大图查看 | 使用 Windows 默认看图/记事本程序打开 |
| **拖入 App** | 传递一份副本（邮件、微信、文档），原件仍挂绳 | 拖拽导出副本到目标窗口 |
| **下拉轻甩 / 点叉** | 物理重力脱落动画，轻松丢弃 | 物理重力脱落动画，轻松丢弃 |
| **指针靠近顶部** | 晾衣绳轻盈滑下悬停；指针移开无感收拢 | 鼠标靠向屏幕顶端即刻滑下；移开无感收起 |
| **全局快捷键** | <kbd>⌃</kbd>&thinsp;<kbd>⌥</kbd>&thinsp;<kbd>T</kbd> | <kbd>Ctrl</kbd>&thinsp;+&thinsp;<kbd>Alt</kbd>&thinsp;+&thinsp;<kbd>T</kbd> |
| **托盘 / 菜单栏** | 顶部菜单栏图标控制与设置 | 任务栏右下角系统托盘菜单控制与设置 |

<br>

---

## 快速安装与使用

### 📦 预编译二进制下载 ([前往 Releases 页面](https://github.com/RolloTomasiH/clothesline/releases/latest))

| 平台 | 安装包名称 | 类型 | 说明 |
|:---|:---|:---|:---|
| **macOS** | `晾衣绳-1.5.2.dmg` | Universal DMG 镜像 | 支持 Apple Silicon (M1/M2/M3/M4) 与 Intel，macOS 14+ |
| **Windows** | `晾衣绳-1.5.2-Windows-x64.exe` | NSIS 标准安装包 | 自动创建桌面与开始菜单快捷方式，支持无缝升级与卸载 |
| **Windows** | `晾衣绳-1.5.2-Windows-Portable-x64.exe` | 单文件便携版 (Green) | **无需安装**，下载后双击即可直接运行，纯绿色无污染 |

<br>

### 🛠️ 从源码本地构建

#### 1. macOS 原生版构建 (Swift)
```bash
# 基于 Swift 命令行工具链一键构建 Universal 双架构包
./scripts/build-app.sh release
open build/晾衣绳.app

# 制作发布用 DMG
./scripts/make-dmg.sh
```

#### 2. Windows 版构建 (Electron)
```bash
cd windows
npm install
npm run dist
# 生成产物位于 windows/dist/：
# - 晾衣绳-1.5.2-Windows-x64.exe (NSIS 安装包)
# - 晾衣绳-1.5.2-Windows-Portable-x64.exe (便携版)
```

---

## 快捷键速查

| 功能 | macOS 快捷键 | Windows 快捷键 |
|:---|:---|:---|
| 显示 / 隐藏晾衣绳 | <kbd>⌃</kbd>&thinsp;<kbd>⌥</kbd>&thinsp;<kbd>T</kbd> | <kbd>Ctrl</kbd>&thinsp;+&thinsp;<kbd>Alt</kbd>&thinsp;+&thinsp;<kbd>T</kbd> |
| 临时固定挂绳在顶端 | 点击菜单栏图标勾选固定 | 点击挂绳右侧 📌 图标或托盘菜单勾选 |
| 取消选择 / 快速收起 | 点击屏幕空白处 | 鼠标移出挂绳区域或按快捷键 |

---

## 许可证 (License)

本项目遵循 **MIT License** 开源。详细条款请见 [LICENSE](LICENSE)。

- 原始项目著作权归原作者所有：Copyright (c) 2026 Alejandro Buján
- 增强功能、Windows 版与中文定制著作权归属：Copyright (c) 2026 RolloTomasiH
- Upstream: https://github.com/alejandrobujan/tendedero
