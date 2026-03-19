import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config/environment.dart';
import 'core/supabase/supabase_client_provider.dart';
import 'data/datasources/task_remote_data_source.dart';
import 'data/datasources/note_remote_data_source.dart';
import 'data/repositories/task_repository_impl.dart';
import 'data/repositories/note_repository_impl.dart';
import 'domain/repositories/task_repository.dart';
import 'domain/repositories/note_repository.dart';
import 'presentation/screens/main_shell.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Environment.init();

  final supabaseUrl = Environment.supabaseUrl;
  final supabaseAnonKey = Environment.supabaseAnonKey;

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  SupabaseClientProvider.init(
    supabaseUrl: supabaseUrl,
    supabaseAnonKey: supabaseAnonKey,
  );

  runApp(const TaskApp());
}

class TaskApp extends StatelessWidget {
  const TaskApp({super.key});

  @override
  Widget build(BuildContext context) {
    final taskRemoteDataSource =
        TaskRemoteDataSource(SupabaseClientProvider.instance.client);
    final noteRemoteDataSource =
        NoteRemoteDataSource(SupabaseClientProvider.instance.client);
    final TaskRepository taskRepository =
        TaskRepositoryImpl(taskRemoteDataSource);
    final NoteRepository noteRepository =
        NoteRepositoryImpl(noteRemoteDataSource);

    return MaterialApp(
      title: 'Task Manager',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: MainShell(
          taskRepository: taskRepository, noteRepository: noteRepository),
    );
  }
}
