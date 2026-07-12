import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/routes/app_routes.dart';

class DoctorListView extends StatelessWidget {
  const DoctorListView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final List<Map<String, dynamic>> doctors = [
      {
        'name': 'Dr. Sarah Jenkins',
        'specialty': 'Cardiologist',
        'rating': '4.9',
        'experience': '12 years',
      },
      {
        'name': 'Dr. Michael Chen',
        'specialty': 'Pediatrician',
        'rating': '4.8',
        'experience': '9 years',
      },
      {
        'name': 'Dr. Emily Watson',
        'specialty': 'Dermatologist',
        'rating': '4.7',
        'experience': '15 years',
      },
      {
        'name': 'Dr. Robert Patel',
        'specialty': 'General Physician',
        'rating': '4.6',
        'experience': '8 years',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      itemCount: doctors.length,
      itemBuilder: (context, index) {
        final doc = doctors[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: InkWell(
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.doctorDetail);
            },
            borderRadius: BorderRadius.circular(AppConstants.radiusL),
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.paddingM),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                    child: Icon(Icons.person, color: theme.colorScheme.primary, size: 36),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doc['name'],
                          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          doc['specialty'],
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.star_rounded, size: 16, color: AppColors.secondaryEmerald),
                            const SizedBox(width: 4),
                            Text(
                              doc['rating'],
                              style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 12),
                            Icon(Icons.work_history_rounded, size: 14, color: theme.colorScheme.outline),
                            const SizedBox(width: 4),
                            Text(
                              doc['experience'],
                              style: theme.textTheme.bodySmall,
                            ),
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
