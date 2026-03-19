import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../theme/app_colors.dart';

/// Represents a pending file before upload (local path + display name).
class PendingFile {
  final File file;
  final String name;
  final bool isImage;

  PendingFile({required this.file, required this.name, required this.isImage});
}

/// Widget that handles picking files/images from mobile and
/// displaying them as removable chips before the task is saved.
class FileAttachmentWidget extends StatelessWidget {
  final List<PendingFile> pendingFiles;
  final bool isUploading;
  final void Function(String source) onPick;
  final void Function(int index) onRemove;

  const FileAttachmentWidget({
    super.key,
    required this.pendingFiles,
    required this.isUploading,
    required this.onPick,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Action row — trigger button
        GestureDetector(
          onTap: () => _showPickerBottomSheet(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.primaryExtraLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.add_circle_outline_rounded,
                    color: AppColors.primary, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: isUploading
                      ? Row(
                          children: [
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Subiendo archivo...',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: AppColors.primary),
                            ),
                          ],
                        )
                      : Text(
                          pendingFiles.isEmpty
                              ? 'Additional Files'
                              : '${pendingFiles.length} archivo(s) seleccionado(s)',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.primary, size: 22),
              ],
            ),
          ),
        ),

        // Preview chips
        if (pendingFiles.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(pendingFiles.length, (i) {
              final f = pendingFiles[i];
              return _FileChip(
                file: f,
                onRemove: () => onRemove(i),
                onTap: () => _previewFile(context, f),
              );
            }),
          ),
        ],
      ],
    );
  }

  void _showPickerBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              _PickerOption(
                icon: Icons.photo_library_rounded,
                label: 'Galería de fotos',
                subtitle: 'Selecciona imágenes existentes',
                onTap: () {
                  Navigator.pop(context);
                  onPick('gallery');
                },
              ),
              _PickerOption(
                icon: Icons.camera_alt_rounded,
                label: 'Tomar foto',
                subtitle: 'Usa la cámara ahora',
                onTap: () {
                  Navigator.pop(context);
                  onPick('camera');
                },
              ),
              _PickerOption(
                icon: Icons.attach_file_rounded,
                label: 'Otros archivos',
                subtitle: 'PDF, Word, Excel, etc.',
                onTap: () {
                  Navigator.pop(context);
                  onPick('file');
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _previewFile(BuildContext context, PendingFile f) {
    if (!f.isImage) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _ImagePreviewScreen(file: f.file, name: f.name),
      ),
    );
  }
}

class _FileChip extends StatelessWidget {
  final PendingFile file;
  final VoidCallback onRemove;
  final VoidCallback onTap;

  const _FileChip({
    required this.file,
    required this.onRemove,
    required this.onTap,
  });

  IconData get _icon {
    final ext = file.name.split('.').last.toLowerCase();
    if (['jpg', 'jpeg', 'png', 'gif', 'webp', 'heic'].contains(ext)) {
      return Icons.image_rounded;
    }
    if (ext == 'pdf') return Icons.picture_as_pdf_rounded;
    if (['doc', 'docx'].contains(ext)) return Icons.description_rounded;
    if (['xls', 'xlsx'].contains(ext)) return Icons.table_chart_rounded;
    return Icons.insert_drive_file_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 160),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Thumbnail for images, icon for others
            if (file.isImage)
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.file(
                  file.file,
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primaryExtraLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(_icon, color: AppColors.primary, size: 18),
              ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                file.name,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontSize: 11,
                      color: AppColors.textPrimary,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onRemove,
              child: const Icon(Icons.close_rounded,
                  size: 15, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _PickerOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _PickerOption({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.primaryExtraLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.primary, size: 22),
      ),
      title: Text(label,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle,
          style: Theme.of(context)
              .textTheme
              .labelMedium
              ?.copyWith(color: AppColors.textSecondary)),
      onTap: onTap,
    );
  }
}

class _ImagePreviewScreen extends StatelessWidget {
  final File file;
  final String name;

  const _ImagePreviewScreen({required this.file, required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(name,
            style: const TextStyle(color: Colors.white, fontSize: 14)),
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.file(file, fit: BoxFit.contain),
        ),
      ),
    );
  }
}

// ─── Helpers used by AddTaskScreen ───────────────────────────────────────────

final _picker = ImagePicker();

Future<List<PendingFile>> pickImages() async {
  final images = await _picker.pickMultiImage(imageQuality: 85);
  return images.map((x) {
    final name = x.path.split('/').last;
    return PendingFile(file: File(x.path), name: name, isImage: true);
  }).toList();
}

Future<PendingFile?> pickFromCamera() async {
  final image =
      await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
  if (image == null) return null;
  final name = image.path.split('/').last;
  return PendingFile(file: File(image.path), name: name, isImage: true);
}

Future<List<PendingFile>> pickGenericFiles() async {
  final result = await FilePicker.platform.pickFiles(
    allowMultiple: true,
    type: FileType.any,
  );
  if (result == null) return [];
  return result.files.where((f) => f.path != null).map((f) {
    final ext = f.extension?.toLowerCase() ?? '';
    final isImage = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'heic'].contains(ext);
    return PendingFile(file: File(f.path!), name: f.name, isImage: isImage);
  }).toList();
}
