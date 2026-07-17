import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/doctor_model.dart';
import '../providers/doctor_provider.dart';

class DoctorDetailScreen extends StatelessWidget {
  final DoctorModel? doctor;

  const DoctorDetailScreen({super.key, this.doctor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<DoctorProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isAdmin = authProvider.currentUser?.role == 'Admin';

    // If doctor is null, we redirect to Add/Edit screen directly
    if (doctor == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, AppRoutes.doctorAddEdit, arguments: null);
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final doc = doctor!;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // M3 Collapsing Header
          SliverAppBar.large(
            title: Text(doc.fullName),
            actions: [
              if (isAdmin) ...[
                IconButton(
                  icon: const Icon(Icons.edit_rounded),
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.doctorAddEdit, arguments: doc);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded),
                  color: theme.colorScheme.error,
                  onPressed: () => _confirmDelete(context, provider, doc),
                ),
              ],
            ],
          ),

          // Detail list
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Profile Photo Hero & Card
                  Center(
                    child: Hero(
                      tag: 'doc_card_${doc.doctorId}',
                      child: CircleAvatar(
                        radius: 64,
                        backgroundColor: theme.colorScheme.primaryContainer,
                        backgroundImage: doc.profileImage != null
                            ? NetworkImage(doc.profileImage!)
                            : null,
                        child: doc.profileImage == null
                            ? Icon(Icons.person_rounded, size: 64, color: theme.colorScheme.onPrimaryContainer)
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Specialty & Hospital title
                  Text(
                    doc.specialization,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${doc.qualification} • ${doc.hospitalName}',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Info grid stats cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          context,
                          'Experience',
                          '${doc.experience} Years',
                          Icons.workspace_premium_rounded,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatCard(
                          context,
                          'Consultation Fee',
                          '\$${doc.consultationFee.toStringAsFixed(0)}',
                          Icons.payments_outlined,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatCard(
                          context,
                          'Department',
                          doc.department,
                          Icons.domain_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Bio Section
                  Text(
                    'Biography',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    doc.bio.isNotEmpty ? doc.bio : 'No biography available for this doctor.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Availability Days Section
                  Text(
                    'Available Work Days',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: doc.availableDays.map((day) {
                      return Chip(
                        avatar: const Icon(Icons.calendar_today_rounded, size: 14),
                        label: Text(day),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Time slots availability
                  Text(
                    'Time Slots',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: doc.availableTimeSlots.map((slot) {
                      return Chip(
                        avatar: const Icon(Icons.access_time_rounded, size: 14),
                        label: Text(slot),
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

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon) {
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

  void _confirmDelete(BuildContext context, DoctorProvider provider, DoctorModel doc) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Doctor Record?'),
        content: Text('Are you sure you want to remove Dr. ${doc.fullName} permanently from the directory?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx); // Close dialog
              final success = await provider.deleteDoctor(doc.doctorId);
              if (context.mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Doctor record deleted.')),
                  );
                  Navigator.pop(context); // Exit details
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(provider.errorMessage ?? 'Failed to delete record.'),
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
