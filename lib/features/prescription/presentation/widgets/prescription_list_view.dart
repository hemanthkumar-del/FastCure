import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../data/models/prescription_model.dart';
import '../providers/prescription_provider.dart';

class PrescriptionListView extends StatefulWidget {
  const PrescriptionListView({super.key});

  @override
  State<PrescriptionListView> createState() => _PrescriptionListViewState();
}

class _PrescriptionListViewState extends State<PrescriptionListView> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      Provider.of<PrescriptionProvider>(context, listen: false)
          .setSearchQuery(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<PrescriptionProvider>(context);
    final list = provider.prescriptions;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.prescriptionAddEdit);
        },
        icon: const Icon(Icons.note_add_rounded),
        label: const Text('New Rx'),
      ),
      body: Column(
        children: [
          // Search box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Search prescriptions by patient, doctor...',
              leading: const Icon(Icons.search_rounded),
              padding: const WidgetStatePropertyAll(
                EdgeInsets.symmetric(horizontal: 12.0),
              ),
              elevation: const WidgetStatePropertyAll(1.0),
            ),
          ),

          // Main Directory List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => provider.loadPrescriptions(),
              child: _buildListContent(provider, list, theme),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListContent(PrescriptionProvider provider, List<PrescriptionModel> list, ThemeData theme) {
    if (provider.isLoading) {
      return const Center(child: LoadingIndicator(message: 'Loading clinical prescriptions...'));
    }

    if (provider.errorMessage != null) {
      return Center(
        child: CustomErrorWidget(
          errorMessage: provider.errorMessage!,
          onRetry: () => provider.loadPrescriptions(),
        ),
      );
    }

    if (list.isEmpty) {
      return const Center(
        child: EmptyStateWidget(
          title: 'No Prescriptions Found',
          message: 'No issued prescriptions match your search criteria.',
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final pres = list[index];
        final formattedDate = pres.createdAt != null 
            ? DateFormat('dd MMM yyyy').format(pres.createdAt!) 
            : 'Today';

        return Card(
          margin: const EdgeInsets.only(bottom: 12.0),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.prescriptionDetail,
                arguments: pres,
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.receipt_long_rounded, color: theme.colorScheme.primary),
                  ),
                  const SizedBox(width: 16),

                  // Detail labels
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pres.patientName ?? 'Patient ID: ${pres.patientId}',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Issued By: ${pres.doctorName ?? "Doctor ID: " + pres.doctorId}',
                          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Date: $formattedDate • Medications: ${pres.medicines.length} items',
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
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
