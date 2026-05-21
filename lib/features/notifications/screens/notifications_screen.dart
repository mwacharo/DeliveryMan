import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Notifications',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
              onPressed: () {},
              child: const Text('Mark all read',
                  style: TextStyle(color: AppTheme.primary, fontSize: 12))),
        ],
      ),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.notifications_none_outlined,
              size: 72,
              color: AppTheme.textSecondary.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text('No notifications yet',
              style: TextStyle(
                  color: AppTheme.textSecondary.withOpacity(0.5),
                  fontSize: 16)),
          const SizedBox(height: 8),
          Text('New order assignments will appear here',
              style: TextStyle(
                  color: AppTheme.textSecondary.withOpacity(0.4),
                  fontSize: 13)),
        ]),
      ),
    );
  }
}
