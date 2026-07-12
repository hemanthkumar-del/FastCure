import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/routes/app_routes.dart';

class AppointmentListView extends StatelessWidget {
  const AppointmentListView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final List<Map<String, dynamic>> appointments = [
      {
        'doctorName': 'Dr. Sarah Jenkins',
        'specialty': 'Cardiologist',
        'dateTime': 'Tomorrow, 09:00 AM',
        'status': 'Confirmed',
        'statusColor': AppColors.secondaryEmerald,
      },
      {
        'doctorName': 'Dr. Michael Chen',
        'specialty': 'Pediatrician',
        'dateTime': '24 June 2026, 11:30 AM',
        'status': 'Completed',
        'statusColor': theme.colorScheme.outline,
      },
      {
        'doctorName': 'Dr. Emily Watson',
        'specialty': 'Dermatologist',
        'dateTime': '10 Jan 2026, 04:00 PM',
        'status': 'Completed',
        'statusColor': theme.colorScheme.outline,
      },
    ];

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.appointmentBook);
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Book New'),
        backgroundColor: theme.colorScheme.primaryContainer,
        foregroundColor: theme.colorScheme.onPrimaryContainer,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          final item = appointments[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.paddingM),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: item['statusColor'].withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.event_available_rounded, color: item['statusColor']),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['doctorName'],
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(item['specialty'], style: theme.textTheme.bodyMedium),
                        const SizedBox(height: 6),
                        Text(
                          item['dateTime'],
                          style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: item['statusColor'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppConstants.radiusS),
                    ),
                    child: Text(
                      item['status'],
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: item['statusColor'],
                        fontWeight: FontWeight.bold,
                      ),
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
