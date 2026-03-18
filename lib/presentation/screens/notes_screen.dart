import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../domain/repositories/task_repository.dart';
import '../../theme/app_colors.dart';

class _Note {
  final String id;
  String title;
  String content;
  final DateTime createdAt;
  Color color;

  _Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.color,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'createdAt': createdAt.toIso8601String(),
    'colorValue': color.value,
  };

  factory _Note.fromJson(Map<String, dynamic> json) => _Note(
    id: json['id'] as String,
    title: json['title'] as String,
    content: json['content'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    color: Color(json['colorValue'] as int),
  );
}

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key, required this.taskRepository});

  final TaskRepository taskRepository;

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  List<_Note> _notes = [];
  bool _isLoading = true;

  static const _storageKey = 'task_app_notes';

  static const List<Color> _noteColors = [
    Color(0xFFE8F8F2),
    Color(0xFFFFF8E1),
    Color(0xFFE3F2FD),
    Color(0xFFFCE4EC),
    Color(0xFFF3E5F5),
  ];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null) {
      final List decoded = jsonDecode(raw) as List;
      setState(() {
        _notes =
            decoded.map((e) => _Note.fromJson(e as Map<String, dynamic>)).toList();
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(_notes.map((n) => n.toJson()).toList()),
    );
  }

  void _addOrEditNote({_Note? existing}) {
    final titleCtrl =
    TextEditingController(text: existing?.title ?? '');
    final contentCtrl =
    TextEditingController(text: existing?.content ?? '');
    Color selectedColor =
        existing?.color ?? _noteColors[_notes.length % _noteColors.length];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setModal) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      existing == null ? 'Nueva Nota' : 'Editar Nota',
                      style:
                      Theme.of(context).textTheme.titleLarge,
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Color picker
                Row(
                  children: _noteColors.map((c) {
                    final isSelected = selectedColor.value == c.value;
                    return GestureDetector(
                      onTap: () => setModal(() => selectedColor = c),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 28,
                        height: 28,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.transparent,
                            width: 2.5,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: titleCtrl,
                  decoration: InputDecoration(
                    hintText: 'Título',
                    hintStyle: const TextStyle(color: AppColors.textHint),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                      const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: AppColors.primary, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: contentCtrl,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: 'Escribe tu nota aquí...',
                    hintStyle: const TextStyle(color: AppColors.textHint),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                      const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: AppColors.primary, width: 2),
                    ),
                    contentPadding: const EdgeInsets.all(14),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () {
                      if (titleCtrl.text.trim().isEmpty &&
                          contentCtrl.text.trim().isEmpty) {
                        Navigator.pop(ctx);
                        return;
                      }
                      if (existing == null) {
                        final note = _Note(
                          id: DateTime.now().millisecondsSinceEpoch
                              .toString(),
                          title: titleCtrl.text.trim(),
                          content: contentCtrl.text.trim(),
                          createdAt: DateTime.now(),
                          color: selectedColor,
                        );
                        setState(() => _notes.insert(0, note));
                      } else {
                        setState(() {
                          existing.title = titleCtrl.text.trim();
                          existing.content = contentCtrl.text.trim();
                          existing.color = selectedColor;
                        });
                      }
                      _saveNotes();
                      Navigator.pop(ctx);
                    },
                    child: Text(
                      'Guardar',
                      style:
                      Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  void _deleteNote(_Note note) {
    setState(() => _notes.remove(note));
    _saveNotes();
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'ahora';
    if (diff.inMinutes < 60) return 'hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'hace ${diff.inHours} h';
    return 'hace ${diff.inDays} d';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Quick Notes',
            style: Theme.of(context).textTheme.titleLarge),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditNote(),
        backgroundColor: AppColors.primary,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _isLoading
          ? const Center(
          child:
          CircularProgressIndicator(color: AppColors.primary))
          : _notes.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sticky_note_2_outlined,
                size: 60,
                color: AppColors.primary.withValues(alpha: 0.3)),
            const SizedBox(height: 14),
            Text(
              'Sin notas aún',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 6),
            Text(
              'Pulsa + para crear una',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.textHint),
            ),
          ],
        ),
      )
          : GridView.builder(
        padding:
        const EdgeInsets.fromLTRB(16, 16, 16, 100),
        gridDelegate:
        const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.9,
        ),
        itemCount: _notes.length,
        itemBuilder: (context, index) {
          final note = _notes[index];
          return GestureDetector(
            onTap: () => _addOrEditNote(existing: note),
            onLongPress: () => _showDeleteDialog(note),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: note.color,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          note.title.isEmpty
                              ? 'Sin título'
                              : note.title,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _showDeleteDialog(note),
                        child: const Icon(
                          Icons.more_vert_rounded,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Text(
                      note.content,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                      maxLines: 6,
                      overflow: TextOverflow.fade,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _timeAgo(note.createdAt),
                    style: Theme.of(context)
                        .textTheme
                        .labelMedium
                        ?.copyWith(
                      fontSize: 10,
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDeleteDialog(_Note note) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar nota'),
        content: const Text('¿Seguro que quieres eliminar esta nota?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteNote(note);
            },
            child: const Text('Eliminar',
                style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}
