class Task {
  final String id;
  final String title;
  final String? description;
  final DateTime? scheduledAt;
  final bool isCompleted;
  final String category;
  final DateTime createdAt;
  final List<String> attachmentUrls;

  const Task({
    required this.id,
    required this.title,
    this.description,
    this.scheduledAt,
    required this.isCompleted,
    required this.category,
    required this.createdAt,
    this.attachmentUrls = const [],
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? scheduledAt,
    bool? isCompleted,
    String? category,
    DateTime? createdAt,
    List<String>? attachmentUrls,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      isCompleted: isCompleted ?? this.isCompleted,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      attachmentUrls: attachmentUrls ?? this.attachmentUrls,
    );
  }
}