import 'dart:io';
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

  /// Uploads [file] to Storage under [taskId] folder.
  /// Returns the public URL of the uploaded file.
  Future<String> uploadFile({required String taskId, required File file});

  /// Deletes a file from Storage given its public [fileUrl].
  Future<void> deleteFile({required String taskId, required String fileUrl});
}