import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/custom_button.dart';

class DoctorDetailScreen extends StatelessWidget {
  const DoctorDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Standard mock doctor arguments could be retrieved here
    // final Map<String, dynamic>? doctor = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header card
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingL),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(AppConstants.radiusXL),
                  bottomRight: Radius.circular(AppConstants.radiusXL),
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 54,
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                    child: Icon(
                      Icons.person_rounded,
                      size: 64,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Dr. Sarah Jenkins',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Cardiologist • MD, FACC',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildRatingStat(context, Icons.star_rounded, '4.9', 'Reviews (120)'),
                      const SizedBox(width: 24),
                      _buildRatingStat(context, Icons.work_rounded, '12 Yrs', 'Experience'),
                    ],
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(AppConstants.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // About Section
                  Text(
                    'Biography',
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Dr. Sarah Jenkins is an award-winning Cardiologist with over 12 years of experience in clinical practice. She specializes in cardiac surgery, heart valve disease, and prevention strategies. She is dedicated to providing high-quality, patient-centric care.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),

                  // Info card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.paddingM),
                      child: Column(
                        children: [
                          _buildInfoRow(context, Icons.access_time_filled_rounded, 'Working Hours', 'Mon - Fri, 09:00 AM - 05:00 PM'),
                          const Divider(height: 24),
                          _buildInfoRow(context, Icons.monetization_on_rounded, 'Consultation Fee', '\$150.00'),
                          const Divider(height: 24),
                          _buildInfoRow(context, Icons.location_on_rounded, 'Location', 'FastCure Health Center, Clinic B, Floor 2'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Book Appointment button
                  CustomButton(
                    text: 'Book Consultation',
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.appointmentBook);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingStat(BuildContext context, IconData icon, String value, String label) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, color: AppColors.secondaryEmerald, size: 20),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            Text(label, style: theme.textTheme.bodySmall),
          ],
        )
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppConstants.radiusS),
          ),
          child: Icon(icon, color: theme.colorScheme.primary, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.bodySmall),
              const SizedBox(height: 2),
              Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
        )
      ],
    );
  }
}
