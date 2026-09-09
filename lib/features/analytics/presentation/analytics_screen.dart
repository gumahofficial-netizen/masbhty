import 'package:flutter/material.dart';
import 'package:masbhty/core/constants/app_colors.dart';
import 'package:masbhty/core/services/storage_service.dart';

class AnalyticsScreen extends StatelessWidget {
  final StorageService storageService;

  const AnalyticsScreen({Key? key, required this.storageService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sessions = storageService.getSessions();
    final streak = storageService.getStreakCount();
    final dailyGoal = storageService.getDailyGoal();

    int totalCountAllTime = 0;
    for (var s in sessions) {
      totalCountAllTime += s.count;
    }

    // Calculate today's count
    final todayStr = DateTime.now().toIso8601String().substring(0, 10);
    int todayCount = 0;
    for (var s in sessions) {
      if (s.timestamp.toIso8601String().startsWith(todayStr)) {
        todayCount += s.count;
      }
    }

    final goalProgress = (todayCount / dailyGoal).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('إحصائيات المسبحة والنشاط', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Overview Cards Row
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    context,
                    title: 'الأيام المتتالية',
                    value: '$streak أيام',
                    icon: Icons.local_fire_department,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    context,
                    title: 'إجمالي التسابيح',
                    value: '$totalCountAllTime',
                    icon: Icons.insights,
                    color: AppColors.emeraldPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Daily Goal Progress Card
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'الهدف اليومي',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('$todayCount / $dailyGoal تسبيحة', style: const TextStyle(fontWeight: FontWeight.w600)),
                        Text('${(goalProgress * 100).toInt()}%', style: const TextStyle(color: AppColors.goldPrimary, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: goalProgress,
                      backgroundColor: AppColors.goldPrimary.withOpacity(0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.emeraldPrimary),
                      minHeight: 12,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Recent Sessions History Header
            const Text(
              'سجل الجلسات الأخيرة',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            sessions.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text('لا توجد جلسات مسجلة بعد. ابدأ التسبيح لتظهر الإحصائيات!'),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: sessions.length > 10 ? 10 : sessions.length,
                    itemBuilder: (context, index) {
                      final session = sessions[sessions.length - 1 - index]; // Latest first
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: AppColors.emeraldPrimary,
                            child: Icon(Icons.check, color: Colors.white),
                          ),
                          title: Text(session.dhikrTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('العدد: ${session.count} تسبيحة'),
                          trailing: Text(
                            '${session.timestamp.hour}:${session.timestamp.minute.toString().padLeft(2, '0')}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(BuildContext context, {required String title, required String value, required IconData icon, required Color color}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(title, style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
