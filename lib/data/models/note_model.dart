import 'package:flutter/material.dart';
import '../../domain/models/note.dart';

class NoteModel {
  final String id;
  final String title;
  final String content;
  final Color color;
  final DateTime createdAt;
  final DateTime updatedAt;

  const NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.color,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      id: map['id'].toString(),
      title: map['title'] as String? ?? '',
      content: map['content'] as String? ?? '',
      color:
          noteColors[((map['color_value'] as int?) ?? 0) % noteColors.length],
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  static const List<Color> noteColors = [
    Color(0xFFE8F8F2),
    Color(0xFFFFF8E1),
    Color(0xFFE3F2FD),
    Color(0xFFFCE4EC),
    Color(0xFFF3E5F5),
  ];

  Map<String, dynamic> toMap() {
    final colorIndex = noteColors.indexWhere(
      (c) => c.toARGB32() == color.toARGB32(),
    );
    return {
      'title': title,
      'content': content,
      'color_value': colorIndex >= 0 ? colorIndex : 0,
    };
  }

  Note toEntity() {
    return Note(
      id: id,
      title: title,
      content: content,
      color: color,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory NoteModel.fromEntity(Note note) {
    return NoteModel(
      id: note.id,
      title: note.title,
      content: note.content,
      color: note.color,
      createdAt: note.createdAt,
      updatedAt: note.updatedAt,
    );
  }
}
