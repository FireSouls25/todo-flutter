class Task {
  final String id;
  final String title;
  final String? description;
  final DateTime? scheduledAt;
  final bool isCompleted;
  final String category;
  final DateTime createdAt;

  const Task({
    required this.id,
    required this.title,
    this.description,
    this.scheduledAt,
    required this.isCompleted,
    required this.category,
    required this.createdAt,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? scheduledAt,
    bool? isCompleted,
    String? category,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      isCompleted: isCompleted ?? this.isCompleted,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
