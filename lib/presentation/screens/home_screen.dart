import 'package:flutter/material.dart';
import '../../domain/models/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../../theme/app_colors.dart';
import '../widgets/circular_progress_widget.dart';
import '../widgets/task_card.dart';
import 'add_task_screen.dart';
import 'analytics_screen.dart';
import 'notes_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.taskRepository});

  final TaskRepository taskRepository;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Task> _todayTasks = [];
  int _weeklyTotal = 0;
  int _weeklyCompleted = 0;
  int _weeklyPercentage = 0;
  bool _isLoading = true;
  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final today = DateTime.now();
      final tasks = await widget.taskRepository.getTasksByDate(today);
      final stats = await widget.taskRepository.getWeeklyStats();
      setState(() {
        _todayTasks = tasks;
        _weeklyTotal = stats['total'] as int;
        _weeklyCompleted = stats['completed'] as int;
        _weeklyPercentage = stats['percentage'] as int;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleTask(Task task) async {
    await widget.taskRepository.toggleTaskCompletion(
      task.id,
      !task.isCompleted,
    );
    await _loadData();
  }

  Future<void> _deleteTask(String id) async {
    await widget.taskRepository.deleteTask(id);
    await _loadData();
  }

  void _openAddTask() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddTaskScreen(taskRepository: widget.taskRepository),
      ),
    );
    if (result == true) _loadData();
  }

  void _onNavTap(int index) {
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              AnalyticsScreen(taskRepository: widget.taskRepository),
        ),
      );
      return;
    }
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => NotesScreen(taskRepository: widget.taskRepository),
        ),
      );
      return;
    }
    if (index == 3) {
      _openAddTask();
      return;
    }
    setState(() => _currentNavIndex = index);
  }

  int get _completedCount => _todayTasks.where((t) => t.isCompleted).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _isLoading
            ? const Center(
            child: CircularProgressIndicator(color: AppColors.primary))
            : RefreshIndicator(
          onRefresh: _loadData,
          color: AppColors.primary,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildWeeklyCard()),
              SliverToBoxAdapter(child: _buildTodayHeader()),
              SliverToBoxAdapter(child: _buildProgressBar()),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              if (_todayTasks.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline,
                            size: 56,
                            color: AppColors.primary.withValues(
                                alpha: 0.4)),
                        const SizedBox(height: 12),
                        Text(
                          'No hay tareas para hoy',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(
                              color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Pulsa + para agregar una',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                              color: AppColors.textHint),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final task = _todayTasks[index];
                        return Padding(
                          padding:
                          const EdgeInsets.only(bottom: 10),
                          child: TaskCard(
                            task: task,
                            onToggle: () => _toggleTask(task),
                            onDelete: () => _deleteTask(task.id),
                          ),
                        );
                      },
                      childCount: _todayTasks.length,
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildWeeklyCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircularProgressWidget(
              percentage: _weeklyPercentage,
              size: 84,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Weekly Tasks',
                        style:
                        Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.arrow_forward,
                          size: 16, color: AppColors.textPrimary),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _StatBadge(
                        value: '$_weeklyTotal',
                        color: AppColors.textPrimary,
                      ),
                      const SizedBox(width: 8),
                      _StatBadge(
                        value: '${_weeklyTotal - _weeklyCompleted}',
                        color: AppColors.danger,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Today Tasks',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          Text(
            '$_completedCount of ${_todayTasks.length}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress =
    _todayTasks.isEmpty ? 0.0 : _completedCount / _todayTasks.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: LinearProgressIndicator(
          value: progress,
          minHeight: 8,
          backgroundColor: AppColors.progressTrack,
          valueColor:
          const AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
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
            isSelected: _currentNavIndex == 0,
            onTap: () => _onNavTap(0),
          ),
          _NavItem(
            icon: Icons.insert_chart_outlined_rounded,
            isSelected: false,
            onTap: () => _onNavTap(1),
          ),
          _NavItem(
            icon: Icons.description_outlined,
            isSelected: false,
            onTap: () => _onNavTap(2),
          ),
          _AddButton(onTap: _openAddTask),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String value;
  final Color color;

  const _StatBadge({required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border, width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        value,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
    );
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
