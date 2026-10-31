// State
let currentCategory = 0; // 0: 截图, 1: 剪贴板, 2: 便笺
let isPinned = false;

let screenshots = [];
let clipboardItems = [];
let notes = [];

// DOM Elements
const stage = document.getElementById('stage');
const itemsTrack = document.getElementById('items-track');
const emptyHint = document.getElementById('empty-hint');
const hintMsg = document.getElementById('hint-msg');
const tabButtons = document.querySelectorAll('.tab-btn');
const badgeScreenshots = document.getElementById('badge-screenshots');
const badgeClipboard = document.getElementById('badge-clipboard');
const badgeNotes = document.getElementById('badge-notes');
const btnAddNote = document.getElementById('btn-add-note');
const btnPin = document.getElementById('btn-pin');
const pinIcon = document.getElementById('pin-icon');
const btnClear = document.getElementById('btn-clear');
const ropePath = document.getElementById('rope-path');
const toast = document.getElementById('toast');
const toastMsg = document.getElementById('toast-msg');

// Note Modal Elements
const noteModal = document.getElementById('note-modal');
const btnCloseModal = document.getElementById('btn-close-modal');
const btnCancelNote = document.getElementById('btn-cancel-note');
const btnSaveNote = document.getElementById('btn-save-note');
const noteTitleInput = document.getElementById('note-title-input');
const noteContentInput = document.getElementById('note-content-input');
const colorOptions = document.querySelectorAll('.color-option');
let selectedColor = 'yellow';

// Color map for sticky notes
const colorMap = {
  yellow: { bg: '#fef08a', text: '#713f12', title: '#854d0e' },
  green: { bg: '#bbf7d0', text: '#14532d', title: '#166534' },
  blue: { bg: '#bae6fd', text: '#0c4a6e', title: '#0369a1' },
  pink: { bg: '#fbcfe8', text: '#831843', title: '#9d174d' },
  purple: { bg: '#e9d5ff', text: '#581c87', title: '#6b21a8' }
};

// Update Dynamic Sagging Rope
function updateRope() {
  const width = window.innerWidth;
  const count = getItemsForCategory().length;
  // Sag increases with more items on the line
  const sag = Math.min(26, 12 + count * 1.5);
  ropePath.setAttribute('d', `M 0 16 Q ${width / 2} ${16 + sag} ${width} 16`);
}

function getItemsForCategory() {
  if (currentCategory === 0) return screenshots;
  if (currentCategory === 1) return clipboardItems;
  return notes;
}

// Update Badges & Counters
function updateBadges() {
  badgeScreenshots.textContent = screenshots.length;
  badgeClipboard.textContent = clipboardItems.length;
  badgeNotes.textContent = notes.length;
}

// Show Toast
let toastTimer = null;
function showToast(message) {
  toastMsg.textContent = message;
  toast.classList.remove('hidden');
  toast.style.opacity = '1';
  if (toastTimer) clearTimeout(toastTimer);
  toastTimer = setTimeout(() => {
    toast.style.opacity = '0';
    setTimeout(() => toast.classList.add('hidden'), 200);
  }, 1500);
}

// Render Current Category Items
function renderItems() {
  itemsTrack.innerHTML = '';
  const items = getItemsForCategory();
  updateBadges();
  updateRope();

  if (items.length === 0) {
    emptyHint.classList.remove('hidden');
    if (currentCategory === 0) hintMsg.textContent = '截屏或录屏，会自动晾在绳子上';
    else if (currentCategory === 1) hintMsg.textContent = '复制文字或代码，会自动挂上剪贴板绳';
    else hintMsg.textContent = '点击上方「＋新便笺」，把待办与灵感晾起来';
    return;
  }

  emptyHint.classList.add('hidden');

  items.forEach((item, index) => {
    const card = document.createElement('div');
    card.className = 'item-card';
    const tilt = (Math.random() * 4 - 2).toFixed(1);
    card.style.transform = `rotate(${tilt}deg)`;
    card.style.animationDelay = `${(index * 0.2).toFixed(1)}s`;

    // Clothespin (衣夹)
    const pin = document.createElement('div');
    pin.className = 'clothespin';
    card.appendChild(pin);

    // Card Body
    const body = document.createElement('div');
    body.className = 'card-body';

    if (currentCategory === 0) {
      // Screenshot Card
      const img = document.createElement('img');
      img.className = 'card-thumb';
      img.src = `file://${item.path}`;
      img.alt = item.name;
      body.appendChild(img);

      const footer = document.createElement('div');
      footer.className = 'card-footer';
      const timeStr = new Date(item.time).toLocaleTimeString('zh-CN', { hour: '2-digit', minute: '2-digit' });
      footer.innerHTML = `<span>${timeStr}</span>`;
      
      const closeBtn = document.createElement('button');
      closeBtn.className = 'card-close-btn';
      closeBtn.innerHTML = '&times;';
      closeBtn.title = '从绳上取下';
      closeBtn.onclick = (e) => {
        e.stopPropagation();
        dropCard(card, () => {
          screenshots = screenshots.filter(s => s.id !== item.id);
          renderItems();
        });
      };
      footer.appendChild(closeBtn);
      body.appendChild(footer);

      // Gestures
      card.onclick = () => {
        window.api.copyImage(item.path).then(() => {
          showToast('✓ 截图已复制');
        });
      };
      card.ondblclick = () => {
        window.api.openFile(item.path);
      };

    } else if (currentCategory === 1) {
      // Clipboard Text Card
      const preview = document.createElement('div');
      preview.className = 'card-text-preview';
      preview.textContent = item.text;
      body.appendChild(preview);

      const footer = document.createElement('div');
      footer.className = 'card-footer';
      footer.innerHTML = `<span>${item.date}</span>`;

      const closeBtn = document.createElement('button');
      closeBtn.className = 'card-close-btn';
      closeBtn.innerHTML = '&times;';
      closeBtn.title = '从绳上取下';
      closeBtn.onclick = (e) => {
        e.stopPropagation();
        dropCard(card, () => {
          clipboardItems = clipboardItems.filter(c => c.id !== item.id);
          renderItems();
        });
      };
      footer.appendChild(closeBtn);
      body.appendChild(footer);

      // Gestures
      card.onclick = () => {
        window.api.copyText(item.text).then(() => {
          showToast('✓ 文本已复制');
        });
      };

    } else if (currentCategory === 2) {
      // Sticky Note Card
      const noteTheme = colorMap[item.color] || colorMap.yellow;
      const noteBody = document.createElement('div');
      noteBody.className = 'card-note-body';
      noteBody.style.backgroundColor = noteTheme.bg;

      const titleEl = document.createElement('div');
      titleEl.className = 'card-note-title';
      titleEl.style.color = noteTheme.title;
      titleEl.textContent = item.title || '便笺';
      noteBody.appendChild(titleEl);

      const descEl = document.createElement('div');
      descEl.className = 'card-note-desc';
      descEl.style.color = noteTheme.text;
      descEl.textContent = item.content;
      noteBody.appendChild(descEl);

      body.appendChild(noteBody);

      const footer = document.createElement('div');
      footer.className = 'card-footer';
      footer.innerHTML = `<span>${item.date}</span>`;

      const closeBtn = document.createElement('button');
      closeBtn.className = 'card-close-btn';
      closeBtn.innerHTML = '&times;';
      closeBtn.title = '从绳上取下';
      closeBtn.onclick = (e) => {
        e.stopPropagation();
        dropCard(card, () => {
          notes = notes.filter(n => n.id !== item.id);
          window.api.saveNotes(notes);
          renderItems();
        });
      };
      footer.appendChild(closeBtn);
      body.appendChild(footer);

      // Gestures
      card.onclick = () => {
        window.api.copyText(`${item.title ? item.title + '\n' : ''}${item.content}`).then(() => {
          showToast('✓ 便笺已复制');
        });
      };
    }

    card.appendChild(body);
    itemsTrack.appendChild(card);
  });
}

// Gravity drop animation
function dropCard(card, onDone) {
  card.classList.add('falling');
  setTimeout(() => {
    onDone();
  }, 350);
}

// Category Tabs Click
tabButtons.forEach(btn => {
  btn.addEventListener('click', () => {
    tabButtons.forEach(b => b.classList.remove('active'));
    btn.classList.add('active');
    currentCategory = parseInt(btn.dataset.cat, 10);
    renderItems();
  });
});

// Pin Button Click
btnPin.addEventListener('click', () => {
  isPinned = !isPinned;
  btnPin.classList.toggle('active', isPinned);
  window.api.setPinned(isPinned);
  showToast(isPinned ? '📌 挂绳已固定在屏幕顶端' : '🔓 挂绳恢复鼠标感应自动收起');
});

// Clear Button Click
btnClear.addEventListener('click', () => {
  if (currentCategory === 0) screenshots = [];
  else if (currentCategory === 1) clipboardItems = [];
  else {
    notes = [];
    window.api.saveNotes(notes);
  }
  renderItems();
  showToast('🧹 已清空当前挂绳');
});

// Note Modal Handlers
btnAddNote.addEventListener('click', () => {
  noteTitleInput.value = '';
  noteContentInput.value = '';
  selectedColor = 'yellow';
  colorOptions.forEach(opt => opt.classList.toggle('active', opt.dataset.color === 'yellow'));
  noteModal.classList.remove('hidden');
  noteContentInput.focus();
});

btnCloseModal.addEventListener('click', () => noteModal.classList.add('hidden'));
btnCancelNote.addEventListener('click', () => noteModal.classList.add('hidden'));

colorOptions.forEach(opt => {
  opt.addEventListener('click', () => {
    colorOptions.forEach(o => o.classList.remove('active'));
    opt.classList.add('active');
    selectedColor = opt.dataset.color;
  });
});

btnSaveNote.addEventListener('click', () => {
  const content = noteContentInput.value.trim();
  if (!content) {
    noteContentInput.focus();
    return;
  }
  const newNote = {
    id: Date.now().toString(),
    title: noteTitleInput.value.trim(),
    content: content,
    color: selectedColor,
    date: new Date().toLocaleTimeString('zh-CN', { hour: '2-digit', minute: '2-digit' })
  };

  notes.unshift(newNote);
  window.api.saveNotes(notes);
  noteModal.classList.add('hidden');

  // Switch to notes tab if not already
  currentCategory = 2;
  tabButtons.forEach(b => b.classList.toggle('active', b.dataset.cat === '2'));
  renderItems();
  showToast('📝 便笺已挂上晾衣绳');
});

// IPC Event Listeners from Main Process
window.api.onScreenshotAdded((data) => {
  screenshots.unshift(data);
  // Auto switch to screenshots tab
  currentCategory = 0;
  tabButtons.forEach(b => b.classList.toggle('active', b.dataset.cat === '0'));
  renderItems();
});

window.api.onClipboardTextAdded((data) => {
  clipboardItems.unshift(data);
  if (clipboardItems.length > 50) clipboardItems.pop();
  renderItems();
});

window.api.onSetCategory((cat) => {
  currentCategory = cat;
  tabButtons.forEach(b => b.classList.toggle('active', b.dataset.cat === cat.toString()));
  renderItems();
});

window.api.onClearCurrent(() => {
  btnClear.click();
});

// Startup: Load saved notes
window.addEventListener('DOMContentLoaded', () => {
  window.api.loadNotes().then(savedNotes => {
    if (Array.isArray(savedNotes)) {
      notes = savedNotes;
    }
    renderItems();
  });
});

window.addEventListener('resize', updateRope);
