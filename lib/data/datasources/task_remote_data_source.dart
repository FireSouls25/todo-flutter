import 'dart:io';
import 'package:mime/mime.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/task_model.dart';

class TaskRemoteDataSource {
  TaskRemoteDataSource(this._client);

  final SupabaseClient _client;

  static const String _table = 'tasks';
  static const String _bucket = 'task-attachments';

  Future<List<TaskModel>> getTasks() async {
    final List<dynamic> response = await _client
        .from(_table)
        .select('*')
        .order('created_at', ascending: false);

    return response
        .cast<Map<String, dynamic>>()
        .map(TaskModel.fromMap)
        .toList();
  }

  Future<List<TaskModel>> getTasksByDate(DateTime date) async {
    final startUtc = DateTime.utc(date.year, date.month, date.day);
    final endUtc = DateTime.utc(date.year, date.month, date.day, 23, 59, 59);

    final List<dynamic> response = await _client
        .from(_table)
        .select('*')
        .order('scheduled_at', ascending: true, nullsFirst: false)
        .order('created_at', ascending: false);

    return response
        .cast<Map<String, dynamic>>()
        .map(TaskModel.fromMap)
        .where((task) {
      if (task.scheduledAt != null) {
        final utc = task.scheduledAt!.toUtc();
        return !utc.isBefore(startUtc) && !utc.isAfter(endUtc);
      }
      final createdUtc = task.createdAt.toUtc();
      return !createdUtc.isBefore(startUtc) && !createdUtc.isAfter(endUtc);
    }).toList();
  }

  Future<void> createTask(TaskModel model) async {
    await _client.from(_table).insert(model.toMap());
  }

  Future<void> updateTask(TaskModel model) async {
    await _client.from(_table).update(model.toMap()).eq('id', model.id);
  }

  Future<void> deleteTask(String id) async {
    await _client.from(_table).delete().eq('id', id);
  }

  Future<void> toggleTaskCompletion(String id, bool isCompleted) async {
    await _client
        .from(_table)
        .update({'is_completed': isCompleted}).eq('id', id);
  }

  Future<Map<String, dynamic>> getWeeklyStats() async {
    final now = DateTime.now();
    final weekStart = DateTime(now.year, now.month, now.day - now.weekday + 1)
        .toIso8601String();
    final weekEnd =
        DateTime(now.year, now.month, now.day, 23, 59, 59).toIso8601String();

    final List<dynamic> response = await _client
        .from(_table)
        .select('is_completed')
        .gte('created_at', weekStart)
        .lte('created_at', weekEnd);

    final total = response.length;
    final completed =
        response.where((t) => (t['is_completed'] as bool?) == true).length;

    return {
      'total': total,
      'completed': completed,
      'percentage': total > 0 ? (completed / total * 100).round() : 0,
    };
  }

  Future<List<Map<String, dynamic>>> getDailyCompletionStats(
      {int days = 7}) async {
    final now = DateTime.now();
    final rangeStart =
        DateTime(now.year, now.month, now.day - (days - 1)).toIso8601String();

    final List<dynamic> response = await _client
        .from(_table)
        .select('created_at, is_completed')
        .gte('created_at', rangeStart)
        .order('created_at', ascending: true);

    final Map<String, Map<String, int>> grouped = {};
    for (var row in response) {
      final dt = DateTime.parse(row['created_at'] as String);
      final key =
          '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
      grouped.putIfAbsent(key, () => {'total': 0, 'completed': 0});
      grouped[key]!['total'] = grouped[key]!['total']! + 1;
      if (row['is_completed'] == true) {
        grouped[key]!['completed'] = grouped[key]!['completed']! + 1;
      }
    }

    return grouped.entries.map((e) => {'date': e.key, ...e.value}).toList();
  }

  /// Uploads a file to Supabase Storage and returns its public URL.
  /// Path: task-attachments/{taskId}/{fileName}
  Future<String> uploadFile({
    required String taskId,
    required File file,
  }) async {
    final fileName = file.path.split('/').last;
    final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';
    final storagePath = '$taskId/$fileName';

    await _client.storage.from(_bucket).upload(
          storagePath,
          file,
          fileOptions: FileOptions(contentType: mimeType, upsert: true),
        );

    final publicUrl = _client.storage.from(_bucket).getPublicUrl(storagePath);
    return publicUrl;
  }

  /// Deletes a file from Storage given its full public URL.
  Future<void> deleteFile({
    required String taskId,
    required String fileUrl,
  }) async {
    final fileName = Uri.parse(fileUrl).pathSegments.last;
    final storagePath = '$taskId/$fileName';
    await _client.storage.from(_bucket).remove([storagePath]);
  }
}
