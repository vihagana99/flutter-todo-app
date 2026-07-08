class Task {
  final String id;
  final String title;
  final bool completed;
  final String priority; // 'low' | 'medium' | 'high'
  final DateTime? dueDate;
  final String category;
  final String? notes;

  Task({
    required this.id,
    required this.title,
    required this.completed,
    this.priority = 'medium',
    this.dueDate,
    this.category = 'General',
    this.notes,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'].toString(),
      title: json['title'],
      completed: json['completed'] == true || json['completed'] == 1,
      priority: json['priority'] ?? 'medium',
      dueDate: json['due_date'] != null ? DateTime.tryParse(json['due_date']) : null,
      category: json['category'] ?? 'General',
      notes: json['notes'],
    );
  }
}
