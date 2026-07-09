
const BASE_URL = 'http://192.168.1.236:5000/api';

const Api = {
  getToken() {
    return localStorage.getItem('token');
  },

  saveToken(token) {
    localStorage.setItem('token', token);
  },

  clearToken() {
    localStorage.removeItem('token');
  },

  authHeaders() {
    return {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${this.getToken()}`,
    };
  },

  async register(name, email, password) {
    const res = await fetch(`${BASE_URL}/auth/register`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ name, email, password }),
    });
    const data = await res.json();
    if (res.ok) {
      this.saveToken(data.token);
      return { success: true, data };
    }
    return { success: false, message: data.message || 'Registration failed' };
  },

  async login(email, password) {
    const res = await fetch(`${BASE_URL}/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email, password }),
    });
    const data = await res.json();
    if (res.ok) {
      this.saveToken(data.token);
      return { success: true, data };
    }
    return { success: false, message: data.message || 'Login failed' };
  },

  async getTasks({ search = '', status = 'all', category = 'All' } = {}) {
    const params = new URLSearchParams();
    if (search) params.set('search', search);
    if (status && status !== 'all') params.set('status', status);
    if (category && category !== 'All') params.set('category', category);

    const res = await fetch(`${BASE_URL}/tasks?${params.toString()}`, {
      headers: this.authHeaders(),
    });
    if (!res.ok) throw new Error('Failed to load tasks');
    return res.json();
  },

  async getCategories() {
    const res = await fetch(`${BASE_URL}/tasks/categories`, {
      headers: this.authHeaders(),
    });
    if (!res.ok) return [];
    return res.json();
  },

  async createTask({ title, priority, dueDate, category, notes }) {
    const res = await fetch(`${BASE_URL}/tasks`, {
      method: 'POST',
      headers: this.authHeaders(),
      body: JSON.stringify({ title, priority, dueDate: dueDate || null, category, notes }),
    });
    if (!res.ok) throw new Error('Failed to create task');
    return res.json();
  },

  async updateTask(id, updates) {
    const res = await fetch(`${BASE_URL}/tasks/${id}`, {
      method: 'PUT',
      headers: this.authHeaders(),
      body: JSON.stringify(updates),
    });
    if (!res.ok) throw new Error('Failed to update task');
    return res.json();
  },

  async deleteTask(id) {
    const res = await fetch(`${BASE_URL}/tasks/${id}`, {
      method: 'DELETE',
      headers: this.authHeaders(),
    });
    if (!res.ok) throw new Error('Failed to delete task');
    return res.json();
  },
};
