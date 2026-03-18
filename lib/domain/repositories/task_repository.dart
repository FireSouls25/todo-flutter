import '../models/task.dart';

abstract class TaskRepository {
  Future<List<Task>> getTasks();
  Future<List<Task>> getTasksByDate(DateTime date);
  Future<void> createTask(Task task);
  Future<void> updateTask(Task task);
  Future<void> deleteTask(String id);
  Future<void> toggleTaskCompletion(String id, bool isCompleted);
  Future<Map<String, dynamic>> getWeeklyStats();
  Future<List<Map<String, dynamic>>> getDailyCompletionStats({int days = 7});
}
