import '../../domain/models/note.dart';
import '../../domain/repositories/note_repository.dart';
import '../datasources/note_remote_data_source.dart';
import '../models/note_model.dart';

class NoteRepositoryImpl implements NoteRepository {
  NoteRepositoryImpl(this._remoteDataSource);

  final NoteRemoteDataSource _remoteDataSource;

  @override
  Future<List<Note>> getNotes() async {
    final models = await _remoteDataSource.getNotes();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> createNote(Note note) async {
    await _remoteDataSource.createNote(NoteModel.fromEntity(note));
  }

  @override
  Future<void> updateNote(Note note) async {
    await _remoteDataSource.updateNote(NoteModel.fromEntity(note));
  }

  @override
  Future<void> deleteNote(String id) async {
    await _remoteDataSource.deleteNote(id);
  }
}
