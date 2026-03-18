import '../../domain/models/task.dart';

class TaskModel {
  final String id;
  final String title;
  final String? description;
  final DateTime? scheduledAt;
  final bool isCompleted;
  final String category;
  final DateTime createdAt;

  const TaskModel({
    required this.id,
    required this.title,
    this.description,
    this.scheduledAt,
    required this.isCompleted,
    required this.category,
    required this.createdAt,
  });

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'].toString(),
      title: map['title'] as String,
      description: map['description'] as String?,
      scheduledAt: map['scheduled_at'] != null
          ? DateTime.parse(map['scheduled_at'] as String)
          : null,
      isCompleted: map['is_completed'] as bool? ?? false,
      category: map['category'] as String? ?? 'Personal',
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'scheduled_at': scheduledAt?.toIso8601String(),
      'is_completed': isCompleted,
      'category': category,
    };
  }

  Task toEntity() {
    return Task(
      id: id,
      title: title,
      description: description,
      scheduledAt: scheduledAt,
      isCompleted: isCompleted,
      category: category,
      createdAt: createdAt,
    );
  }

  factory TaskModel.fromEntity(Task task) {
    return TaskModel(
      id: task.id,
      title: task.title,
      description: task.description,
      scheduledAt: task.scheduledAt,
      isCompleted: task.isCompleted,
      category: task.category,
      createdAt: task.createdAt,
    );
  }
}
