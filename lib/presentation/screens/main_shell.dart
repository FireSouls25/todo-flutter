import 'package:flutter/material.dart';
import '../../domain/repositories/task_repository.dart';
import '../../domain/repositories/note_repository.dart';
import '../../theme/app_colors.dart';
import 'home_screen.dart';
import 'analytics_screen.dart';
import 'notes_screen.dart';
import 'add_task_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({
    super.key,
    required this.taskRepository,
    required this.noteRepository,
  });

  final TaskRepository taskRepository;
  final NoteRepository noteRepository;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  final GlobalKey<HomeScreenContentState> _homeKey = GlobalKey();

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreenContent(
        key: _homeKey,
        taskRepository: widget.taskRepository,
        homeKey: _homeKey,
      ),
      NotesScreen(
        taskRepository: widget.noteRepository,
        noteRepository: widget.noteRepository,
      ),
      AnalyticsScreen(taskRepository: widget.taskRepository),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        height: 72,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon: Icons.home_rounded,
              isSelected: _currentIndex == 0,
              onTap: () => setState(() => _currentIndex = 0),
            ),
            _NavItem(
              icon: Icons.description_outlined,
              isSelected: _currentIndex == 1,
              onTap: () => setState(() => _currentIndex = 1),
            ),
            _NavItem(
              icon: Icons.pie_chart_outline_rounded,
              isSelected: _currentIndex == 2,
              onTap: () => setState(() => _currentIndex = 2),
            ),
            _AddButton(onTap: _openAddTask),
          ],
        ),
      ),
    );
  }

  void _openAddTask() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddTaskScreen(taskRepository: widget.taskRepository),
      ),
    );
    if (result == true) {
      _homeKey.currentState?.loadData();
    }
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Icon(
          icon,
          size: 26,
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 26),
      ),
    );
  }
}
