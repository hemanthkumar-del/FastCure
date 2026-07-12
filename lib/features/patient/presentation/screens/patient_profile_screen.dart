import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/routes/app_routes.dart';
import '../../data/models/patient_model.dart';
import '../providers/patient_provider.dart';

class PatientProfileScreen extends StatelessWidget {
  final PatientModel? patient;

  const PatientProfileScreen({super.key, this.patient});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<PatientProvider>(context);

    // If patient argument is null, we redirect to Add/Edit screen
    if (patient == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, AppRoutes.patientAddEdit, arguments: null);
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final pat = patient!;
    final age = DateTime.now().year - pat.dob.year;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Collapsing AppBar
          SliverAppBar.large(
            title: Text(pat.fullName),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_rounded),
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.patientAddEdit, arguments: pat);
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded),
                color: theme.colorScheme.error,
                onPressed: () => _confirmDelete(context, provider, pat),
              ),
            ],
          ),

          // Details List
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Photo Hero
                  Center(
                    child: Hero(
                      tag: 'patient_card_${pat.patientId}',
                      child: CircleAvatar(
                        radius: 64,
                        backgroundColor: theme.colorScheme.primaryContainer,
                        backgroundImage: pat.profileImage != null
                            ? NetworkImage(pat.profileImage!)
                            : null,
                        child: pat.profileImage == null
                            ? Icon(Icons.person_outline_rounded, size: 64, color: theme.colorScheme.onPrimaryContainer)
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Demographic Grid
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard(
                          context,
                          'Age / Gender',
                          '$age Yrs / ${pat.gender}',
                          Icons.face_rounded,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildInfoCard(
                          context,
                          'Blood Group',
                          pat.bloodGroup,
                          Icons.bloodtype_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Core Info Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow(context, Icons.email_outlined, 'Email', pat.email),
                          const Divider(height: 24),
                          _buildDetailRow(context, Icons.phone_android_rounded, 'Phone', pat.phone),
                          const Divider(height: 24),
                          _buildDetailRow(context, Icons.home_outlined, 'Home Address', pat.address),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Medical History
                  Text(
                    'Medical Conditions & History',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (pat.medicalHistory.isEmpty)
                    Text(
                      'No reported medical conditions.',
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    )
                  else
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: pat.medicalHistory.map((item) {
                        return Chip(
                          avatar: const Icon(Icons.assignment_turned_in_rounded, size: 14),
                          label: Text(item),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 24),

                  // Allergies
                  Text(
                    'Allergies',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (pat.allergies.isEmpty)
                    Text(
                      'No known allergies reported.',
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    )
                  else
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: pat.allergies.map((item) {
                        return Chip(
                          avatar: const Icon(Icons.warning_amber_rounded, size: 14, color: Colors.orange),
                          label: Text(item),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, String value, IconData icon) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 20),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              const SizedBox(height: 2),
              Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, PatientProvider provider, PatientModel pat) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Patient Profile?'),
        content: Text('Are you sure you want to delete ${pat.fullName}\'s profile and medical logs permanently?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await provider.deletePatient(pat.patientId);
              if (context.mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Patient profile removed.')),
                  );
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(provider.errorMessage ?? 'Failed to delete profile.'),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
