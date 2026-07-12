import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/custom_button.dart';

class PrescriptionDetailScreen extends StatelessWidget {
  const PrescriptionDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prescription Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Medical Letterhead Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.healing_rounded, color: theme.colorScheme.primary, size: 28),
                        const SizedBox(width: 8),
                        Text(
                          'FastCure Health Center',
                          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    _buildMetaText(context, 'Doctor', 'Dr. Sarah Jenkins (Cardiology)'),
                    _buildMetaText(context, 'Patient', 'John Doe (Age: 34)'),
                    _buildMetaText(context, 'Date Issued', '12 July 2026'),
                    _buildMetaText(context, 'Diagnosis', 'Essential Hypertension (Stage 1)'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Rx icon & Medication Section
            Row(
              children: [
                Icon(Icons.receipt_long_rounded, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Prescribed Medicines (Rx)',
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Card(
              child: ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildMedicationTile(context, 'Atorvastatin 20mg', '1 Tablet daily', 'Bedtime', 'Duration: 30 Days'),
                  const Divider(height: 1),
                  _buildMedicationTile(context, 'Lisinopril 10mg', '1 Tablet daily', 'Morning (with water)', 'Duration: 90 Days'),
                  const Divider(height: 1),
                  _buildMedicationTile(context, 'Omega-3 Fish Oil 1000mg', '1 Capsule twice daily', 'Breakfast & Dinner', 'Duration: 60 Days'),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Download/Share buttons
            CustomButton(
              text: 'Download PDF Copy',
              onPressed: () {
                // Stub action
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Downloading prescription PDF...')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaText(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationTile(
    BuildContext context, 
    String medName, 
    String frequency, 
    String timing, 
    String duration,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            medName,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.restore_rounded, size: 14, color: theme.colorScheme.outline),
              const SizedBox(width: 4),
              Text(frequency, style: theme.textTheme.bodyMedium),
              const SizedBox(width: 12),
              const Icon(Icons.circle, size: 4, color: Colors.grey),
              const SizedBox(width: 12),
              Icon(Icons.wb_sunny_outlined, size: 14, color: theme.colorScheme.outline),
              const SizedBox(width: 4),
              Text(timing, style: theme.textTheme.bodyMedium),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            duration,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.secondaryEmerald,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
