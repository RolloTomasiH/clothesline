const { app, BrowserWindow, screen, Tray, Menu, globalShortcut, clipboard, ipcMain, shell, nativeImage } = require('electron');
const path = require('path');
const fs = require('fs');
const chokidar = require('chokidar');

let mainWindow = null;
let tray = null;
let isPinned = false;
let isExpanded = false;
let animTimer = null;

const WINDOW_HEIGHT = 220;
const RETRACTED_OFFSET = -(WINDOW_HEIGHT - 6); // 6px sensor zone remaining at top

// Path for storing sticky notes
const notesFilePath = path.join(app.getPath('userData'), 'clothesline-notes.json');

// Self-copy tracker to prevent recursive capture
let lastSelfCopyText = '';
let lastSelfCopyTime = 0;

function createWindow() {
  const primaryDisplay = screen.getPrimaryDisplay();
  const { width } = primaryDisplay.bounds;

  mainWindow = new BrowserWindow({
    width: width,
    height: WINDOW_HEIGHT,
    x: 0,
    y: RETRACTED_OFFSET,
    frame: false,
    transparent: true,
    alwaysOnTop: true,
    skipTaskbar: true,
    resizable: false,
    focusable: true,
    hasShadow: false,
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      nodeIntegration: false,
      contextIsolation: true,
      webSecurity: false // allow local file previews
    }
  });

  mainWindow.loadFile(path.join(__dirname, 'index.html'));
  mainWindow.setVisibleOnAllWorkspaces(true, { visibleOnFullScreen: true });
  mainWindow.setAlwaysOnTop(true, 'screen-saver');

  // Monitor cursor position at screen top to trigger slide-down
  startCursorPolling();

  mainWindow.on('closed', () => {
    mainWindow = null;
  });
}

// Smooth slide animation
function slideTo(targetY, onComplete) {
  if (!mainWindow) return;
  if (animTimer) clearInterval(animTimer);

  const [currentX, currentY] = mainWindow.getPosition();
  const distance = targetY - currentY;
  if (Math.abs(distance) < 2) {
    mainWindow.setPosition(currentX, targetY);
    if (onComplete) onComplete();
    return;
  }

  const steps = 10;
  let step = 0;
  animTimer = setInterval(() => {
    step++;
    const progress = step / steps;
    // Ease out cubic
    const ease = 1 - Math.pow(1 - progress, 3);
    const newY = Math.round(currentY + distance * ease);
    mainWindow.setPosition(currentX, newY);

    if (step >= steps) {
      clearInterval(animTimer);
      animTimer = null;
      mainWindow.setPosition(currentX, targetY);
      if (onComplete) onComplete();
    }
  }, 16);
}

function expandLine() {
  if (isExpanded) return;
  isExpanded = true;
  slideTo(0);
}

function retractLine() {
  if (!isExpanded || isPinned) return;
  isExpanded = false;
  slideTo(RETRACTED_OFFSET);
}

function toggleLine() {
  if (isExpanded) {
    retractLine();
  } else {
    expandLine();
  }
}

// Check cursor position for auto-drop
function startCursorPolling() {
  setInterval(() => {
    if (!mainWindow) return;
    const point = screen.getCursorScreenPoint();
    
    // Near very top edge (Y <= 3) triggers line dropdown
    if (point.y <= 3) {
      expandLine();
    } else if (point.y > WINDOW_HEIGHT + 10 && isExpanded && !isPinned) {
      retractLine();
    }
  }, 120);
}

// System Tray setup
function createTray() {
  const iconPath = path.join(__dirname, 'assets', process.platform === 'win32' ? 'icon.ico' : 'icon.png');
  const icon = nativeImage.createFromPath(iconPath);
  tray = new Tray(icon.resize({ width: 16, height: 16 }));

  const updateMenu = () => {
    const contextMenu = Menu.buildFromTemplate([
      {
        label: isExpanded ? '收起晾衣绳' : '放下晾衣绳',
        click: () => toggleLine(),
        accelerator: 'Ctrl+Alt+T'
      },
      {
        label: isPinned ? '✓ 固定在屏幕顶端' : '固定在屏幕顶端',
        type: 'checkbox',
        checked: isPinned,
        click: () => {
          isPinned = !isPinned;
          if (isPinned) expandLine();
          updateMenu();
        }
      },
      { type: 'separator' },
      {
        label: '📷 切换到截图绳',
        click: () => {
          expandLine();
          mainWindow?.webContents.send('set-category', 0);
        }
      },
      {
        label: '📋 切换到剪贴板绳',
        click: () => {
          expandLine();
          mainWindow?.webContents.send('set-category', 1);
        }
      },
      {
        label: '📝 切换到便笺绳',
        click: () => {
          expandLine();
          mainWindow?.webContents.send('set-category', 2);
        }
      },
      { type: 'separator' },
      {
        label: '🧹 清空当前挂绳',
        click: () => mainWindow?.webContents.send('clear-current')
      },
      {
        label: '开机自动启动',
        type: 'checkbox',
        checked: app.getLoginItemSettings().openAtLogin,
        click: (item) => {
          app.setLoginItemSettings({ openAtLogin: item.checked });
        }
      },
      { type: 'separator' },
      {
        label: '关于晾衣绳...',
        click: () => {
          shell.openExternal('https://github.com/RolloTomasiH/clothesline');
        }
      },
      {
        label: '退出',
        click: () => app.quit()
      }
    ]);
    tray.setContextMenu(contextMenu);
  };

  tray.setToolTip('晾衣绳 (Clothesline) · 优雅挂起截图、剪贴板与便笺 (Ctrl+Alt+T)');
  tray.on('click', () => toggleLine());
  updateMenu();
}

// Watch screenshots folder
function setupScreenshotWatcher() {
  const picturesDir = app.getPath('pictures');
  const screenshotsDir = path.join(picturesDir, 'Screenshots');
  const watchDirs = [screenshotsDir];

  if (!fs.existsSync(screenshotsDir)) {
    try { fs.mkdirSync(screenshotsDir, { recursive: true }); } catch (e) {}
  }

  const watcher = chokidar.watch(watchDirs, {
    ignored: /(^|[\/\\])\../, // ignore dotfiles
    persistent: true,
    ignoreInitial: true,
    depth: 1
  });

  watcher.on('add', (filePath) => {
    const ext = path.extname(filePath).toLowerCase();
    if (['.png', '.jpg', '.jpeg', '.webp', '.bmp'].includes(ext)) {
      setTimeout(() => {
        if (!fs.existsSync(filePath)) return;
        const stats = fs.statSync(filePath);
        mainWindow?.webContents.send('screenshot-added', {
          id: Date.now().toString(),
          path: filePath,
          name: path.basename(filePath),
          time: stats.mtimeMs,
          size: stats.size
        });
        expandLine();
      }, 500); // Wait for file flush
    }
  });
}

// Clipboard polling
let lastClipboardText = '';
function setupClipboardWatcher() {
  setInterval(() => {
    try {
      const text = clipboard.readText();
      if (text && text.trim().length >= 2 && text !== lastClipboardText) {
        lastClipboardText = text;
        const now = Date.now();
        // Ignore if copied by ourselves within last 1.5s
        if (text === lastSelfCopyText && now - lastSelfCopyTime < 2000) {
          return;
        }
        mainWindow?.webContents.send('clipboard-text-added', {
          id: Date.now().toString(),
          text: text,
          date: new Date().toLocaleTimeString('zh-CN', { hour: '2-digit', minute: '2-digit' })
        });
      }
    } catch (e) {}
  }, 800);
}

// IPC Handlers
ipcMain.handle('slide-down', () => expandLine());
ipcMain.handle('slide-up', () => retractLine());
ipcMain.handle('set-pinned', (_e, pinned) => {
  isPinned = pinned;
  if (isPinned) expandLine();
});

ipcMain.handle('copy-text', (_e, text) => {
  lastSelfCopyText = text;
  lastSelfCopyTime = Date.now();
  clipboard.writeText(text);
  return true;
});

ipcMain.handle('copy-image', (_e, filePath) => {
  try {
    const image = nativeImage.createFromPath(filePath);
    clipboard.writeImage(image);
    return true;
  } catch (err) {
    return false;
  }
});

ipcMain.handle('open-file', (_e, filePath) => shell.openPath(filePath));
ipcMain.handle('reveal-file', (_e, filePath) => shell.showItemInFolder(filePath));
ipcMain.handle('trash-file', (_e, filePath) => shell.trashItem(filePath));

ipcMain.handle('load-notes', () => {
  try {
    if (fs.existsSync(notesFilePath)) {
      return JSON.parse(fs.readFileSync(notesFilePath, 'utf8'));
    }
  } catch (e) {}
  return [];
});

ipcMain.handle('save-notes', (_e, notes) => {
  try {
    fs.writeFileSync(notesFilePath, JSON.stringify(notes, null, 2), 'utf8');
    return true;
  } catch (e) {
    return false;
  }
});

// App Lifecycle
app.whenReady().then(() => {
  createWindow();
  createTray();
  setupScreenshotWatcher();
  setupClipboardWatcher();

  // Register Global Hotkey
  globalShortcut.register('CommandOrControl+Alt+T', () => {
    toggleLine();
  });
});

app.on('will-quit', () => {
  globalShortcut.unregisterAll();
});

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});
