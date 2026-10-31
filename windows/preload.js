const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('api', {
  // Events from main
  onScreenshotAdded: (callback) => ipcRenderer.on('screenshot-added', (_event, data) => callback(data)),
  onClipboardTextAdded: (callback) => ipcRenderer.on('clipboard-text-added', (_event, data) => callback(data)),
  onClipboardImageAdded: (callback) => ipcRenderer.on('clipboard-image-added', (_event, data) => callback(data)),
  onToggleLine: (callback) => ipcRenderer.on('toggle-line', (_event, forceOpen) => callback(forceOpen)),
  onSetCategory: (callback) => ipcRenderer.on('set-category', (_event, cat) => callback(cat)),
  onClearCurrent: (callback) => ipcRenderer.on('clear-current', () => callback()),

  // Commands to main
  copyText: (text) => ipcRenderer.invoke('copy-text', text),
  copyImage: (filePath) => ipcRenderer.invoke('copy-image', filePath),
  openFile: (filePath) => ipcRenderer.invoke('open-file', filePath),
  revealFile: (filePath) => ipcRenderer.invoke('reveal-file', filePath),
  trashFile: (filePath) => ipcRenderer.invoke('trash-file', filePath),
  
  // Slide controls
  slideDown: () => ipcRenderer.invoke('slide-down'),
  slideUp: () => ipcRenderer.invoke('slide-up'),
  setPinned: (isPinned) => ipcRenderer.invoke('set-pinned', isPinned),
  
  // Notes persistence
  loadNotes: () => ipcRenderer.invoke('load-notes'),
  saveNotes: (notes) => ipcRenderer.invoke('save-notes', notes),

  // Platform
  platform: process.platform
});
