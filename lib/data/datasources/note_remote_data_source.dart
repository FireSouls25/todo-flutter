import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/note_model.dart';

class NoteRemoteDataSource {
  NoteRemoteDataSource(this._client);

  final SupabaseClient _client;

  static const String _table = 'notes';

  Future<List<NoteModel>> getNotes() async {
    final List<dynamic> response = await _client
        .from(_table)
        .select('*')
        .order('created_at', ascending: false);

    return response
        .cast<Map<String, dynamic>>()
        .map(NoteModel.fromMap)
        .toList();
  }

  Future<void> createNote(NoteModel model) async {
    await _client.from(_table).insert(model.toMap());
  }

  Future<void> updateNote(NoteModel model) async {
    await _client.from(_table).update(model.toMap()).eq('id', model.id);
  }

  Future<void> deleteNote(String id) async {
    await _client.from(_table).delete().eq('id', id);
  }
}
