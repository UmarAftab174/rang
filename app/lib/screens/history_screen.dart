import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/mock_data_service.dart';

// ── Screen ────────────────────────────────────────────────────────────────────

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        bottom: false,
        child: ValueListenableBuilder<List<ScanResultData>>(
          valueListenable: MockDataService.instance.history,
          builder: (context, scanHistory, _) {
            final completedCount = scanHistory.where((s) => s.status == 'completed').length;
            final processingCount = scanHistory.where((s) => s.status == 'processing').length;
            final totalColors = scanHistory.fold(0, (sum, s) => sum + s.colorCount);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Scan History',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Your color segmentation results',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.filter_list, color: AppTheme.primaryLight, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '${scanHistory.length}',
                              style: const TextStyle(
                                color: AppTheme.primaryLight,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Stats bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: Row(
                    children: [
                      _buildStatChip(Icons.check_circle_outline, 'Completed', '$completedCount', AppTheme.accentGreen),
                      const SizedBox(width: 8),
                      _buildStatChip(Icons.hourglass_top, 'Processing', '$processingCount', AppTheme.accentOrange),
                      const SizedBox(width: 8),
                      _buildStatChip(Icons.palette_outlined, 'Colors Found', '$totalColors', AppTheme.accentCyan),
                    ],
                  ),
                ),

                // Scan list
                Expanded(
                  child: scanHistory.isEmpty
                      ? const Center(
                          child: Text(
                            'No scans yet. Try scanning something!',
                            style: TextStyle(color: AppTheme.textSecondary),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                          itemCount: scanHistory.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) => _buildScanCard(scanHistory[index]),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 9,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanCard(ScanResultData scan) {
    final isProcessing = scan.status == 'processing';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isProcessing
              ? AppTheme.accentOrange.withOpacity(0.2)
              : AppTheme.primaryPurple.withOpacity(0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: title + status
          Row(
            children: [
              // Color preview circles
              SizedBox(
                width: 48,
                height: 48,
                child: Stack(
                  children: [
                    for (int i = 0; i < scan.dominantColors.length && i < 3; i++)
                      Positioned(
                        left: i * 14.0,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: scan.dominantColors[i],
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.backgroundCard,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      scan.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      scan.timeAgo,
                      style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isProcessing
                      ? AppTheme.accentOrange.withOpacity(0.1)
                      : AppTheme.accentGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isProcessing ? Icons.hourglass_top : Icons.check_circle,
                      color: isProcessing ? AppTheme.accentOrange : AppTheme.accentGreen,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isProcessing ? 'Processing' : 'Done',
                      style: TextStyle(
                        color: isProcessing ? AppTheme.accentOrange : AppTheme.accentGreen,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Color strip
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 8,
              child: Row(
                children: scan.dominantColors
                    .map((c) => Expanded(child: ColoredBox(color: c)))
                    .toList(),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Bottom stats
          Row(
            children: [
              _buildInfoTag(Icons.palette_outlined, '${scan.colorCount} colors'),
              const SizedBox(width: 12),
              if (!isProcessing)
                _buildInfoTag(Icons.speed, '${(scan.confidence * 100).toInt()}% confidence'),
              if (isProcessing)
                _buildInfoTag(Icons.sync, 'Analyzing...'),
              const Spacer(),
              Icon(
                Icons.chevron_right,
                color: AppTheme.textMuted.withOpacity(0.5),
                size: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTag(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.textSecondary, size: 14),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
