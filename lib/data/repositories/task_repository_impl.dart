import 'dart:io';
import '../../domain/models/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_remote_data_source.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  TaskRepositoryImpl(this._remoteDataSource);

  final TaskRemoteDataSource _remoteDataSource;

  @override
  Future<List<Task>> getTasks() async {
    final models = await _remoteDataSource.getTasks();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<Task>> getTasksByDate(DateTime date) async {
    final models = await _remoteDataSource.getTasksByDate(date);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> createTask(Task task) async {
    final model = TaskModel.fromEntity(task);
    await _remoteDataSource.createTask(model);
  }

  @override
  Future<void> updateTask(Task task) async {
    final model = TaskModel.fromEntity(task);
    await _remoteDataSource.updateTask(model);
  }

  @override
  Future<void> deleteTask(String id) async {
    await _remoteDataSource.deleteTask(id);
  }

  @override
  Future<void> toggleTaskCompletion(String id, bool isCompleted) async {
    await _remoteDataSource.toggleTaskCompletion(id, isCompleted);
  }

  @override
  Future<Map<String, dynamic>> getWeeklyStats() async {
    return _remoteDataSource.getWeeklyStats();
  }

  @override
  Future<List<Map<String, dynamic>>> getDailyCompletionStats(
      {int days = 7}) async {
    return _remoteDataSource.getDailyCompletionStats(days: days);
  }

  @override
  Future<String> uploadFile({
    required String taskId,
    required File file,
  }) async {
    return _remoteDataSource.uploadFile(taskId: taskId, file: file);
  }

  @override
  Future<void> deleteFile({
    required String taskId,
    required String fileUrl,
  }) async {
    await _remoteDataSource.deleteFile(taskId: taskId, fileUrl: fileUrl);
  }
}