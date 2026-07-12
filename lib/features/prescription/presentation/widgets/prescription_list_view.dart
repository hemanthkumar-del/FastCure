import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/routes/app_routes.dart';

class PrescriptionListView extends StatelessWidget {
  const PrescriptionListView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final List<Map<String, dynamic>> prescriptions = [
      {
        'doctor': 'Dr. Sarah Jenkins',
        'date': '12 July 2026',
        'diagnosis': 'Essential Hypertension',
        'medCount': 3,
      },
      {
        'doctor': 'Dr. Michael Chen',
        'date': '04 April 2026',
        'diagnosis': 'Acute Rhinopharyngitis',
        'medCount': 2,
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      itemCount: prescriptions.length,
      itemBuilder: (context, index) {
        final item = prescriptions[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: InkWell(
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.prescriptionDetail);
            },
            borderRadius: BorderRadius.circular(AppConstants.radiusL),
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.paddingM),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.receipt_long_rounded, color: theme.colorScheme.primary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['diagnosis'],
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(item['doctor'], style: theme.textTheme.bodyMedium),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.calendar_today_rounded, size: 12, color: theme.colorScheme.outline),
                            const SizedBox(width: 4),
                            Text(item['date'], style: theme.textTheme.bodySmall),
                            const SizedBox(width: 16),
                            Icon(Icons.medication_rounded, size: 12, color: theme.colorScheme.outline),
                            const SizedBox(width: 4),
                            Text('${item['medCount']} Medicines', style: theme.textTheme.bodySmall),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded, size: 16, color: theme.colorScheme.outline),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
