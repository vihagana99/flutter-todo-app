// ---------- Auth guard ----------
if (!Api.getToken()) {
  window.location.href = 'login.html';
}

// ---------- State ----------
let tasks = [];
let categories = [];
let statusFilter = 'all';
let categoryFilter = 'All';
let searchQuery = '';
let searchDebounce = null;
let editingTaskId = null;
let taskPendingDelete = null;

// ---------- Elements ----------
const taskListEl = document.getElementById('taskList');
const searchInput = document.getElementById('searchInput');
const statusChipsEl = document.getElementById('statusChips');
const categoryChipsEl = document.getElementById('categoryChips');
const toastEl = document.getElementById('toast');

const taskModalOverlay = document.getElementById('taskModalOverlay');
const modalTitle = document.getElementById('modalTitle');
const taskTitleInput = document.getElementById('taskTitle');
const taskCategoryInput = document.getElementById('taskCategory');
const taskDueDateInput = document.getElementById('taskDueDate');
const taskNotesInput = document.getElementById('taskNotes');
const categorySuggestionsEl = document.getElementById('categorySuggestions');
const saveTaskBtn = document.getElementById('saveTaskBtn');

const deleteModalOverlay = document.getElementById('deleteModalOverlay');
const deleteMessage = document.getElementById('deleteMessage');

let selectedPriority = 'medium';

// ---------- Toast ----------
function showToast(message) {
  toastEl.textContent = message;
  toastEl.classList.add('show');
  setTimeout(() => toastEl.classList.remove('show'), 2500);
}

// ---------- Dark mode ----------
const themeToggle = document.getElementById('themeToggle');
if (localStorage.getItem('theme') === 'dark') {
  document.body.classList.add('dark');
  themeToggle.textContent = '☀️';
}
themeToggle.addEventListener('click', () => {
  document.body.classList.toggle('dark');
  const isDark = document.body.classList.contains('dark');
  localStorage.setItem('theme', isDark ? 'dark' : 'light');
  themeToggle.textContent = isDark ? '☀️' : '🌙';
});

// ---------- Logout ----------
document.getElementById('logoutBtn').addEventListener('click', () => {
  Api.clearToken();
  window.location.href = 'login.html';
});

// ---------- Loading tasks ----------
async function loadTasks() {
  try {
    tasks = await Api.getTasks({
      search: searchQuery,
      status: statusFilter,
      category: categoryFilter,
    });
    renderTasks();
    updateSummary();
  } catch (err) {
    showToast('Failed to load tasks');
  }
}

async function loadCategories() {
  categories = await Api.getCategories();
  renderCategoryChips();
}

// ---------- Rendering ----------
function formatDueDate(dateStr) {
  const date = new Date(dateStr);
  const now = new Date();
  const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
  const due = new Date(date.getFullYear(), date.getMonth(), date.getDate());
  const diffDays = Math.round((due - today) / 86400000);

  if (diffDays === 0) return 'Today';
  if (diffDays === 1) return 'Tomorrow';
  if (diffDays < 0) {
    return `Overdue · ${String(date.getMonth() + 1).padStart(2, '0')}/${String(date.getDate()).padStart(2, '0')}`;
  }
  return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`;
}

function priorityColor(priority) {
  return { low: 'var(--low)', medium: 'var(--medium)', high: 'var(--high)' }[priority] || 'var(--medium)';
}

function renderTasks() {
  if (tasks.length === 0) {
    taskListEl.innerHTML = `
      <div class="empty-state">
        <div class="icon-circle">✓</div>
        <h3>Nothing here yet</h3>
        <p>Add your first task to get started</p>
      </div>`;
    return;
  }

  taskListEl.innerHTML = tasks.map((task, index) => {
    const isOverdue = task.due_date && new Date(task.due_date) < new Date() && !task.completed;
    const dueTag = task.due_date
      ? `<span class="tag ${isOverdue ? 'overdue' : ''}">📅 ${formatDueDate(task.due_date)}</span>`
      : '';
    const notesTag = task.notes ? `<span class="tag">📝</span>` : '';

    return `
      <div class="task-card" style="animation-delay: ${Math.min(index * 40, 300)}ms" data-id="${task.id}">
        <div class="task-priority-bar" style="background:${priorityColor(task.priority)}"></div>
        <div class="task-body" data-action="edit">
          <div class="check-circle ${task.completed ? 'checked' : ''}" data-action="toggle">
            ${task.completed ? '✓' : ''}
          </div>
          <div class="task-content">
            <div class="task-title ${task.completed ? 'completed' : ''}">${escapeHtml(task.title)}</div>
            <div class="tag-row">
              <span class="tag">🏷️ ${escapeHtml(task.category)}</span>
              ${dueTag}
              ${notesTag}
            </div>
          </div>
        </div>
        <button class="task-delete" data-action="delete" title="Delete">🗑️</button>
      </div>`;
  }).join('');
}

function escapeHtml(str) {
  const div = document.createElement('div');
  div.textContent = str ?? '';
  return div.innerHTML;
}

function updateSummary() {
  const total = tasks.length;
  const done = tasks.filter(t => t.completed).length;
  const pending = total - done;
  const percent = total === 0 ? 0 : Math.round((done / total) * 100);

  document.getElementById('totalCount').textContent = total;
  document.getElementById('pendingCount').textContent = pending;
  document.getElementById('doneCount').textContent = done;

  const circumference = 163.36;
  const offset = circumference - (percent / 100) * circumference;
  document.getElementById('ringFg').style.strokeDashoffset = offset;
  document.getElementById('ringLabel').textContent = `${percent}%`;
}

function renderCategoryChips() {
  const allChip = `<button class="chip ${categoryFilter === 'All' ? 'active' : ''}" data-category="All">All</button>`;
  const chips = categories.map(c =>
    `<button class="chip ${categoryFilter === c ? 'active' : ''}" data-category="${escapeHtml(c)}">${escapeHtml(c)}</button>`
  ).join('');
  categoryChipsEl.innerHTML = allChip + chips;
}

// ---------- Task list interactions (event delegation) ----------
taskListEl.addEventListener('click', async (e) => {
  const card = e.target.closest('.task-card');
  if (!card) return;
  const taskId = card.dataset.id;
  const task = tasks.find(t => String(t.id) === String(taskId));

  if (e.target.closest('[data-action="toggle"]')) {
    try {
      const updated = await Api.updateTask(taskId, { completed: !task.completed });
      Object.assign(task, updated);
      renderTasks();
      updateSummary();
    } catch (err) {
      showToast('Failed to update task');
    }
  } else if (e.target.closest('[data-action="delete"]')) {
    taskPendingDelete = task;
    deleteMessage.textContent = `"${task.title}" will be deleted permanently.`;
    deleteModalOverlay.classList.add('open');
  } else if (e.target.closest('[data-action="edit"]')) {
    openEditModal(task);
  }
});

// ---------- Filters ----------
statusChipsEl.addEventListener('click', (e) => {
  const btn = e.target.closest('.chip');
  if (!btn) return;
  statusFilter = btn.dataset.status;
  [...statusChipsEl.children].forEach(c => c.classList.toggle('active', c === btn));
  loadTasks();
});

categoryChipsEl.addEventListener('click', (e) => {
  const btn = e.target.closest('.chip');
  if (!btn) return;
  categoryFilter = btn.dataset.category;
  renderCategoryChips();
  loadTasks();
});

searchInput.addEventListener('input', (e) => {
  clearTimeout(searchDebounce);
  searchDebounce = setTimeout(() => {
    searchQuery = e.target.value;
    loadTasks();
  }, 400);
});

// ---------- Add/Edit modal ----------
function resetModalFields() {
  taskTitleInput.value = '';
  taskCategoryInput.value = '';
  taskDueDateInput.value = '';
  taskNotesInput.value = '';
  selectedPriority = 'medium';
  updatePriorityUI();
}

function updatePriorityUI() {
  document.querySelectorAll('.priority-option').forEach(el => {
    el.classList.toggle('active', el.dataset.priority === selectedPriority);
  });
}

document.querySelectorAll('.priority-option').forEach(el => {
  el.addEventListener('click', () => {
    selectedPriority = el.dataset.priority;
    updatePriorityUI();
  });
});

function renderCategorySuggestions() {
  const defaults = ['General', 'Work', 'Personal', 'Shopping'];
  const combined = [...new Set([...defaults, ...categories])];
  categorySuggestionsEl.innerHTML = combined.map(c =>
    `<button type="button" class="chip" data-fill-category="${escapeHtml(c)}">${escapeHtml(c)}</button>`
  ).join('');
}

categorySuggestionsEl.addEventListener('click', (e) => {
  const btn = e.target.closest('[data-fill-category]');
  if (btn) taskCategoryInput.value = btn.dataset.fillCategory;
});

document.getElementById('addTaskBtn').addEventListener('click', () => {
  editingTaskId = null;
  modalTitle.textContent = 'New Task';
  saveTaskBtn.textContent = 'Add Task';
  resetModalFields();
  renderCategorySuggestions();
  taskModalOverlay.classList.add('open');
  taskTitleInput.focus();
});

function openEditModal(task) {
  editingTaskId = task.id;
  modalTitle.textContent = 'Edit Task';
  saveTaskBtn.textContent = 'Save';
  taskTitleInput.value = task.title;
  taskCategoryInput.value = task.category;
  taskDueDateInput.value = task.due_date ? task.due_date.split('T')[0] : '';
  taskNotesInput.value = task.notes || '';
  selectedPriority = task.priority;
  updatePriorityUI();
  renderCategorySuggestions();
  taskModalOverlay.classList.add('open');
}

document.getElementById('cancelModalBtn').addEventListener('click', () => {
  taskModalOverlay.classList.remove('open');
});

saveTaskBtn.addEventListener('click', async () => {
  const title = taskTitleInput.value.trim();
  if (!title) {
    showToast('Title is required');
    return;
  }

  const payload = {
    title,
    priority: selectedPriority,
    category: taskCategoryInput.value.trim() || 'General',
    dueDate: taskDueDateInput.value || null,
    notes: taskNotesInput.value.trim() || null,
  };

  try {
    if (editingTaskId) {
      const updated = await Api.updateTask(editingTaskId, payload);
      const index = tasks.findIndex(t => String(t.id) === String(editingTaskId));
      if (index !== -1) tasks[index] = updated;
    } else {
      const created = await Api.createTask(payload);
      tasks.push(created);
    }
    taskModalOverlay.classList.remove('open');
    renderTasks();
    updateSummary();
    loadCategories();
  } catch (err) {
    showToast(editingTaskId ? 'Failed to update task' : 'Failed to add task');
  }
});

// ---------- Delete modal ----------
document.getElementById('cancelDeleteBtn').addEventListener('click', () => {
  deleteModalOverlay.classList.remove('open');
  taskPendingDelete = null;
});

document.getElementById('confirmDeleteBtn').addEventListener('click', async () => {
  if (!taskPendingDelete) return;
  try {
    await Api.deleteTask(taskPendingDelete.id);
    tasks = tasks.filter(t => t.id !== taskPendingDelete.id);
    renderTasks();
    updateSummary();
  } catch (err) {
    showToast('Failed to delete task');
  } finally {
    deleteModalOverlay.classList.remove('open');
    taskPendingDelete = null;
  }
});

// Close modals when clicking the dark overlay itself
[taskModalOverlay, deleteModalOverlay].forEach(overlay => {
  overlay.addEventListener('click', (e) => {
    if (e.target === overlay) overlay.classList.remove('open');
  });
});

// ---------- Init ----------
loadTasks();
loadCategories();
