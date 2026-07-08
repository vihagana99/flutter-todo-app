const pool = require('../config/db');

// filters: { search, status ('all'|'pending'|'completed'), category }
async function getTasksByUser(userId, filters = {}) {
  let query = 'SELECT * FROM tasks WHERE user_id = ?';
  const values = [userId];

  if (filters.search) {
    query += ' AND title LIKE ?';
    values.push(`%${filters.search}%`);
  }
  if (filters.status === 'pending') {
    query += ' AND completed = FALSE';
  } else if (filters.status === 'completed') {
    query += ' AND completed = TRUE';
  }
  if (filters.category && filters.category !== 'All') {
    query += ' AND category = ?';
    values.push(filters.category);
  }

  query += ' ORDER BY due_date IS NULL, due_date ASC, created_at DESC';

  const [rows] = await pool.query(query, values);
  return rows;
}

async function createTask({ userId, title, priority, dueDate, category, notes }) {
  const [result] = await pool.query(
    'INSERT INTO tasks (user_id, title, priority, due_date, category, notes) VALUES (?, ?, ?, ?, ?, ?)',
    [userId, title, priority || 'medium', dueDate || null, category || 'General', notes || null]
  );
  const [rows] = await pool.query('SELECT * FROM tasks WHERE id = ?', [result.insertId]);
  return rows[0];
}

async function updateTask(id, userId, updates) {
  const fields = [];
  const values = [];

  if (updates.title !== undefined) {
    fields.push('title = ?');
    values.push(updates.title);
  }
  if (updates.completed !== undefined) {
    fields.push('completed = ?');
    values.push(updates.completed);
  }
  if (updates.priority !== undefined) {
    fields.push('priority = ?');
    values.push(updates.priority);
  }
  if (updates.dueDate !== undefined) {
    fields.push('due_date = ?');
    values.push(updates.dueDate);
  }
  if (updates.category !== undefined) {
    fields.push('category = ?');
    values.push(updates.category);
  }
  if (updates.notes !== undefined) {
    fields.push('notes = ?');
    values.push(updates.notes);
  }

  if (fields.length === 0) return null;

  values.push(id, userId);
  const [result] = await pool.query(
    `UPDATE tasks SET ${fields.join(', ')} WHERE id = ? AND user_id = ?`,
    values
  );

  if (result.affectedRows === 0) return null;

  const [rows] = await pool.query('SELECT * FROM tasks WHERE id = ?', [id]);
  return rows[0];
}

async function deleteTask(id, userId) {
  const [result] = await pool.query(
    'DELETE FROM tasks WHERE id = ? AND user_id = ?',
    [id, userId]
  );
  return result.affectedRows > 0;
}

async function getCategories(userId) {
  const [rows] = await pool.query(
    'SELECT DISTINCT category FROM tasks WHERE user_id = ?',
    [userId]
  );
  return rows.map(r => r.category);
}

module.exports = { getTasksByUser, createTask, updateTask, deleteTask, getCategories };
