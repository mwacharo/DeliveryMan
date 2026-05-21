import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final String statusName;
  final String statusColor;

  const StatusBadge({
    super.key,
    required this.statusName,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.fromApiColor(statusColor);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(statusName,
          style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3)),
    );
  }
}
