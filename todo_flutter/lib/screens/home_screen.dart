import 'dart:async';
import 'package:flutter/material.dart';
import '../main.dart';
import '../models/task.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/task_dialog.dart';
import '../widgets/animated_task_card.dart';
import '../widgets/progress_ring.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Task> _tasks = [];
  List<String> _categories = [];
  bool _isLoading = true;
  String? _errorMessage;

  String _statusFilter = 'all'; // all | pending | completed
  String _categoryFilter = 'All';
  String _searchQuery = '';
  Timer? _debounce;
  int _loadToken = 0;

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _loadCategories();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    final categories = await ApiService.getCategories();
    if (mounted) setState(() => _categories = categories);
  }

  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final tasks = await ApiService.getTasks(
        search: _searchQuery,
        status: _statusFilter,
        category: _categoryFilter,
      );
      setState(() {
        _tasks = tasks;
        _isLoading = false;
        _loadToken++; // forces a fresh entrance animation cascade on reload
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load tasks';
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _searchQuery = value;
      _loadTasks();
    });
  }

  Future<void> _openAddDialog() async {
    final result = await showTaskDialog(context, suggestedCategories: _categories);
    if (result == null) return;
    try {
      final task = await ApiService.createTask(
        title: result.title,
        priority: result.priority,
        dueDate: result.dueDate,
        category: result.category,
        notes: result.notes,
      );
      setState(() => _tasks.add(task));
      _loadCategories();
    } catch (e) {
      _showError('Failed to add task');
    }
  }

  Future<void> _openEditDialog(Task task) async {
    final result = await showTaskDialog(
      context,
      existingTask: task,
      suggestedCategories: _categories,
    );
    if (result == null) return;
    try {
      final updated = await ApiService.updateTask(
        task.id,
        title: result.title,
        priority: result.priority,
        dueDate: result.dueDate,
        clearDueDate: result.dueDate == null,
        category: result.category,
        notes: result.notes ?? '',
      );
      setState(() {
        final index = _tasks.indexWhere((t) => t.id == task.id);
        if (index != -1) _tasks[index] = updated;
      });
      _loadCategories();
    } catch (e) {
      _showError('Failed to update task');
    }
  }

  Future<void> _toggleTask(Task task) async {
    try {
      final updated = await ApiService.updateTask(task.id, completed: !task.completed);
      setState(() {
        final index = _tasks.indexWhere((t) => t.id == task.id);
        if (index != -1) _tasks[index] = updated;
      });
    } catch (e) {
      _showError('Failed to update task');
    }
  }

  Future<bool> _confirmAndDelete(Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Delete task?'),
        content: Text('"${task.title}" will be deleted permanently.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.priorityHigh),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return false;

    try {
      await ApiService.deleteTask(task.id);
      return true;
    } catch (e) {
      _showError('Failed to delete task');
      return false;
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _logout() async {
    await ApiService.clearToken();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  String _formatDueDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(date.year, date.month, date.day);
    final diff = due.difference(today).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    if (diff < 0) {
      return 'Overdue \u00b7 ${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
    }
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final pendingCount = _tasks.where((t) => !t.completed).length;
    final completedCount = _tasks.where((t) => t.completed).length;
    final total = pendingCount + completedCount;
    final progress = total == 0 ? 0.0 : completedCount / total;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        actions: [
          IconButton(
            icon: ValueListenableBuilder<ThemeMode>(
              valueListenable: themeNotifier,
              builder: (context, mode, _) => Icon(
                mode == ThemeMode.dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              ),
            ),
            onPressed: () {
              themeNotifier.value =
                  themeNotifier.value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
            },
          ),
          IconButton(icon: const Icon(Icons.logout_outlined), onPressed: _logout),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: TextField(
              onChanged: _onSearchChanged,
              decoration: const InputDecoration(
                hintText: 'Search tasks...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),

          // Status filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _statusChip('All', 'all'),
                const SizedBox(width: 8),
                _statusChip('Pending', 'pending'),
                const SizedBox(width: 8),
                _statusChip('Completed', 'completed'),
              ],
            ),
          ),

          // Category filter chips
          if (_categories.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: SizedBox(
                height: 34,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _categoryChip('All'),
                    ..._categories.map(_categoryChip),
                  ],
                ),
              ),
            ),

          // Progress summary card
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                child: Row(
                  children: [
                    ProgressRing(progress: progress, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _summaryItem(context, '$total', 'Total'),
                          _summaryItem(context, '$pendingCount', 'Pending'),
                          _summaryItem(context, '$completedCount', 'Done'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Task list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(child: Text(_errorMessage!))
                    : _tasks.isEmpty
                        ? _EmptyState(onAdd: _openAddDialog)
                        : RefreshIndicator(
                            onRefresh: _loadTasks,
                            child: ListView.builder(
                              key: ValueKey(_loadToken),
                              padding: const EdgeInsets.only(top: 10, bottom: 90),
                              itemCount: _tasks.length,
                              itemBuilder: (context, index) {
                                final task = _tasks[index];
                                final isOverdue = task.dueDate != null &&
                                    task.dueDate!.isBefore(DateTime.now()) &&
                                    !task.completed;
                                return Dismissible(
                                  key: ValueKey(task.id),
                                  direction: DismissDirection.endToStart,
                                  confirmDismiss: (_) => _confirmAndDelete(task),
                                  onDismissed: (_) {
                                    setState(() => _tasks.removeAt(index));
                                  },
                                  background: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: AppColors.priorityHigh,
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 22),
                                    child: const Icon(Icons.delete_outline, color: Colors.white),
                                  ),
                                  child: AnimatedTaskCard(
                                    task: task,
                                    index: index,
                                    onTap: () => _openEditDialog(task),
                                    onToggle: () => _toggleTask(task),
                                    dueDateLabel:
                                        task.dueDate != null ? _formatDueDate(task.dueDate!) : '',
                                    isOverdue: isOverdue,
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddDialog,
        icon: const Icon(Icons.add),
        label: const Text('New Task'),
      ),
    );
  }

  Widget _statusChip(String label, String value) {
    final selected = _statusFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) {
        setState(() => _statusFilter = value);
        _loadTasks();
      },
    );
  }

  Widget _categoryChip(String category) {
    final selected = _categoryFilter == category;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(category, style: const TextStyle(fontSize: 12)),
        selected: selected,
        onSelected: (_) {
          setState(() => _categoryFilter = category);
          _loadTasks();
        },
      ),
    );
  }

  Widget _summaryItem(BuildContext context, String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(value, style: Theme.of(context).textTheme.headlineSmall),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              ),
              child: Icon(
                Icons.task_alt_outlined,
                size: 40,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text('Nothing here yet', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(
              'Add your first task to get started',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Add Task'),
            ),
          ],
        ),
      ),
    );
  }
}
