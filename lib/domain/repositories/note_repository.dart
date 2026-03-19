import '../models/note.dart';

abstract class NoteRepository {
  Future<List<Note>> getNotes();
  Future<void> createNote(Note note);
  Future<void> updateNote(Note note);
  Future<void> deleteNote(String id);
}
