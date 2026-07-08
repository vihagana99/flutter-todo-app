const express = require('express');
const router = express.Router();
const Task = require('../models/Task');
const authMiddleware = require('../middleware/authMiddleware');

// All routes here require a valid JWT token
router.use(authMiddleware);

// GET /api/tasks?search=&status=&category=
router.get('/', async (req, res) => {
  try {
    const { search, status, category } = req.query;
    const tasks = await Task.getTasksByUser(req.userId, { search, status, category });
    res.json(tasks);
  } catch (err) {
    res.status(500).json({ message: 'Server error', error: err.message });
  }
});

// GET /api/tasks/categories - distinct categories user has used
router.get('/categories', async (req, res) => {
  try {
    const categories = await Task.getCategories(req.userId);
    res.json(categories);
  } catch (err) {
    res.status(500).json({ message: 'Server error', error: err.message });
  }
});

// POST /api/tasks
router.post('/', async (req, res) => {
  try {
    const { title, priority, dueDate, category, notes } = req.body;
    if (!title) {
      return res.status(400).json({ message: 'Title is required' });
    }
    const newTask = await Task.createTask({ userId: req.userId, title, priority, dueDate, category, notes });
    res.status(201).json(newTask);
  } catch (err) {
    res.status(500).json({ message: 'Server error', error: err.message });
  }
});

// PUT /api/tasks/:id
router.put('/:id', async (req, res) => {
  try {
    const { title, completed, priority, dueDate, category, notes } = req.body;
    const updates = {};
    if (title !== undefined) updates.title = title;
    if (completed !== undefined) updates.completed = completed;
    if (priority !== undefined) updates.priority = priority;
    if (dueDate !== undefined) updates.dueDate = dueDate;
    if (category !== undefined) updates.category = category;
    if (notes !== undefined) updates.notes = notes;

    const updated = await Task.updateTask(req.params.id, req.userId, updates);
    if (!updated) {
      return res.status(404).json({ message: 'Task not found' });
    }
    res.json(updated);
  } catch (err) {
    res.status(500).json({ message: 'Server error', error: err.message });
  }
});

// DELETE /api/tasks/:id
router.delete('/:id', async (req, res) => {
  try {
    const deleted = await Task.deleteTask(req.params.id, req.userId);
    if (!deleted) {
      return res.status(404).json({ message: 'Task not found' });
    }
    res.json({ message: 'Task deleted' });
  } catch (err) {
    res.status(500).json({ message: 'Server error', error: err.message });
  }
});

module.exports = router;
