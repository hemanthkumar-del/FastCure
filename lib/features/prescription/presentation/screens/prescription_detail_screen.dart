import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../data/models/prescription_model.dart';
import '../providers/prescription_provider.dart';

class PrescriptionDetailScreen extends StatelessWidget {
  final PrescriptionModel? prescription;

  const PrescriptionDetailScreen({super.key, this.prescription});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<PrescriptionProvider>(context);

    if (prescription == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Prescription Details')),
        body: const Center(
          child: Text('Prescription record not found.'),
        ),
      );
    }

    final pres = prescription!;
    final formattedDate = pres.createdAt != null 
        ? DateFormat('dd MMMM yyyy, hh:mm a').format(pres.createdAt!) 
        : 'Today';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prescription Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            color: theme.colorScheme.error,
            onPressed: () => _confirmDelete(context, provider, pres),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Clinic Metadata
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'FASTCURE MEDICAL CENTER',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        Icon(Icons.healing_rounded, color: theme.colorScheme.primary),
                      ],
                    ),
                    const Divider(height: 24),
                    _buildMetaRow(context, 'Prescription ID', pres.prescriptionId),
                    const SizedBox(height: 8),
                    _buildMetaRow(context, 'Date Issued', formattedDate),
                    const SizedBox(height: 8),
                    _buildMetaRow(context, 'Appointment ID', pres.appointmentId),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Doctor & Patient demographics Card
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('DOCTOR', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(pres.doctorName ?? 'N/A', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                          Text(pres.doctorSpecialty ?? 'Specialist', style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('PATIENT', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(pres.patientName ?? 'N/A', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                          Text('Patient ID: ${pres.patientId}', style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Medicines Table title
            Text(
              'Prescribed Medications',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Table Grid Card
            Card(
              clipBehavior: Clip.antiAlias,
              child: Table(
                border: TableBorder.symmetric(
                  inside: BorderSide(color: theme.colorScheme.outlineVariant),
                ),
                columnWidths: const {
                  0: FlexColumnWidth(3),
                  1: FlexColumnWidth(2),
                  2: FlexColumnWidth(1.2),
                },
                children: [
                  // Table Header
                  TableRow(
                    decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.4)),
                    children: [
                      _buildHeaderCell(context, 'Medicine'),
                      _buildHeaderCell(context, 'Dosage / Instruction'),
                      _buildHeaderCell(context, 'Qty'),
                    ],
                  ),
                  // Table Rows
                  ...pres.medicines.map((item) {
                    return TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(item.name, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(item.dosage, style: theme.textTheme.bodySmall),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text('${item.quantity} pcs', style: theme.textTheme.bodyMedium),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Notes Section
            Text(
              'Advice / Notes',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  pres.notes.isNotEmpty ? pres.notes : 'No extra notes provided by consultant.',
                  style: theme.textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Print button mockup
            ElevatedButton.icon(
              onPressed: () => _printMockup(context),
              icon: const Icon(Icons.print_rounded),
              label: const Text('Export Prescription PDF'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCell(BuildContext context, String label) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildMetaRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  void _printMockup(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(Icons.check_circle_rounded, color: Theme.of(context).colorScheme.primary, size: 48),
        title: const Text('PDF Generated'),
        content: const Text(
          'FastCure clinical prescription PDF compiled successfully. Sent to system printers.',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Dismiss'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, PrescriptionProvider provider, PrescriptionModel pres) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Prescription?'),
        content: const Text('Are you sure you want to delete this prescription history permanently?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await provider.deletePrescription(pres.prescriptionId);
              if (context.mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Prescription removed.')),
                  );
                  Navigator.pop(context);
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
