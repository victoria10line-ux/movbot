import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum StatusTone { success, warning, danger, neutral, accent }

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label, this.tone = StatusTone.neutral});
  final String label;
  final StatusTone tone;

  Color get color => switch (tone) {
        StatusTone.success => AppColors.green,
        StatusTone.warning => AppColors.amber,
        StatusTone.danger => AppColors.red,
        StatusTone.accent => AppColors.orange,
        StatusTone.neutral => AppColors.muted,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: .30)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}
