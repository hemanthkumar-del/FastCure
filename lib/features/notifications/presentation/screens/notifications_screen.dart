import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final List<Map<String, dynamic>> notifications = [
      {
        'title': 'Appointment Confirmed',
        'body': 'Your appointment with Dr. Sarah Jenkins is scheduled for tomorrow at 09:00 AM.',
        'time': '2 hours ago',
        'type': 'appointment',
        'isRead': false,
      },
      {
        'title': 'New Prescription Issued',
        'body': 'Dr. Sarah Jenkins has uploaded a new prescription (Essential Hypertension treatment).',
        'time': '5 hours ago',
        'type': 'prescription',
        'isRead': false,
      },
      {
        'title': 'Lab Results Ready',
        'body': 'Your blood report from FastCure Diagnostic Labs is now available in your health records.',
        'time': '1 day ago',
        'type': 'lab',
        'isRead': true,
      },
      {
        'title': 'Medicine Reminder',
        'body': 'It is time to take your Lisinopril 10mg tablet.',
        'time': '2 days ago',
        'type': 'medicine',
        'isRead': true,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () {
              // Mark all read action
            },
            child: const Text('Mark all read'),
          ),
        ],
      ),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none_rounded, size: 64, color: theme.colorScheme.outline),
                  const SizedBox(height: 16),
                  Text('No notifications yet', style: theme.textTheme.headlineSmall),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppConstants.paddingM),
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = notifications[index];
                IconData typeIcon = Icons.notifications_rounded;
                Color iconColor = theme.colorScheme.primary;

                switch (item['type']) {
                  case 'appointment':
                    typeIcon = Icons.calendar_today_rounded;
                    iconColor = AppColors.secondaryEmerald;
                    break;
                  case 'prescription':
                    typeIcon = Icons.receipt_long_rounded;
                    iconColor = Colors.purple;
                    break;
                  case 'lab':
                    typeIcon = Icons.science_rounded;
                    iconColor = Colors.orange;
                    break;
                  case 'medicine':
                    typeIcon = Icons.medication_rounded;
                    iconColor = AppColors.alertCoral;
                    break;
                }

                return Card(
                  color: item['isRead'] ? theme.cardTheme.color : theme.colorScheme.primaryContainer.withOpacity(0.05),
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.paddingM),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon badge
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: iconColor.withOpacity(0.1),
                          child: Icon(typeIcon, color: iconColor, size: 20),
                        ),
                        const SizedBox(width: 16),
                        // Text block
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item['title'],
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: item['isRead'] ? FontWeight.w600 : FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  if (!item['isRead'])
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: AppColors.primaryBlue,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item['body'],
                                style: theme.textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item['time'],
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
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
}
