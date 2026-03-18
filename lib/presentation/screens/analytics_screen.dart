import 'package:flutter/material.dart';
import '../../domain/repositories/task_repository.dart';
import '../../theme/app_colors.dart';
import '../widgets/circular_progress_widget.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key, required this.taskRepository});

  final TaskRepository taskRepository;

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _weeklyStats = {};
  List<Map<String, dynamic>> _dailyStats = [];

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    try {
      final weekly = await widget.taskRepository.getWeeklyStats();
      final daily =
      await widget.taskRepository.getDailyCompletionStats(days: 7);
      setState(() {
        _weeklyStats = weekly;
        _dailyStats = daily;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  String _shortDay(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[dt.weekday - 1];
    } catch (_) {
      return dateStr.substring(8);
    }
  }

  @override
  Widget build(BuildContext context) {
    final percentage = _weeklyStats['percentage'] as int? ?? 0;
    final total = _weeklyStats['total'] as int? ?? 0;
    final completed = _weeklyStats['completed'] as int? ?? 0;
    final remaining = total - completed;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Analytics',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
          child:
          CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
        onRefresh: _loadStats,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWeeklySummary(
                  percentage, total, completed, remaining),
              const SizedBox(height: 24),
              _buildBarChart(),
              const SizedBox(height: 24),
              _buildCategoryBreakdown(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklySummary(
      int percentage, int total, int completed, int remaining) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryExtraLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircularProgressWidget(percentage: percentage, size: 90),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This Week',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                _SummaryRow(
                    label: 'Total', value: '$total', color: AppColors.primary),
                const SizedBox(height: 6),
                _SummaryRow(
                    label: 'Done',
                    value: '$completed',
                    color: AppColors.primary),
                const SizedBox(height: 6),
                _SummaryRow(
                    label: 'Pending',
                    value: '$remaining',
                    color: AppColors.danger),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    if (_dailyStats.isEmpty) {
      return Container(
        height: 180,
        alignment: Alignment.center,
        child: Text(
          'Sin datos aún',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: AppColors.textSecondary),
        ),
      );
    }

    // Find max for scaling
    final maxTotal = _dailyStats.fold<int>(
        1, (prev, e) => (e['total'] as int) > prev ? e['total'] as int : prev);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daily Activity (Last 7 days)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _dailyStats.map((day) {
              final total = day['total'] as int;
              final comp = day['completed'] as int;
              final heightFactor = maxTotal > 0 ? total / maxTotal : 0.0;
              final compFactor = total > 0 ? comp / total : 0.0;
              final barHeight = 120.0 * heightFactor;

              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '$comp/$total',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Stacked bar
                  Container(
                    width: 28,
                    height: barHeight.clamp(20.0, 140.0),
                    decoration: BoxDecoration(
                      color: AppColors.analyticsBarLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: FractionallySizedBox(
                        heightFactor: compFactor,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _shortDay(day['date'] as String),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryBreakdown() {
    // Placeholder motivational card
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.emoji_events_rounded,
              color: Colors.white, size: 36),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¡Sigue así!',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Completa todas tus tareas de hoy para\nmantener el streak de la semana.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(color: AppColors.textSecondary),
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}
