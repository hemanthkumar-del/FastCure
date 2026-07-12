import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../data/models/patient_model.dart';
import '../providers/patient_provider.dart';

class PatientListScreen extends StatefulWidget {
  const PatientListScreen({super.key});

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      Provider.of<PatientProvider>(context, listen: false)
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
    final provider = Provider.of<PatientProvider>(context);
    final list = provider.patients;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Directory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => provider.loadPatients(),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () => _showFilterDialog(context, provider),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Sort Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: SearchBar(
                    controller: _searchController,
                    hintText: 'Search patients, emails, phone...',
                    leading: const Icon(Icons.search_rounded),
                    padding: const WidgetStatePropertyAll(
                      EdgeInsets.symmetric(horizontal: 12.0),
                    ),
                    elevation: const WidgetStatePropertyAll(1.0),
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<PatientSortOption>(
                  icon: const Icon(Icons.sort_by_alpha_rounded),
                  tooltip: 'Sort Patients',
                  onSelected: (option) => provider.setSortOption(option),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: PatientSortOption.name,
                      child: Text('Sort by Name'),
                    ),
                    const PopupMenuItem(
                      value: PatientSortOption.registrationDate,
                      child: Text('Sort by Reg Date'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Active filter chip row
          if (provider.filterGender != 'All' || provider.filterBloodGroup != 'All' || provider.searchQuery.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Text(
                    'Active Filters: ',
                    style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  if (provider.filterGender != 'All')
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Chip(
                        label: Text(provider.filterGender),
                        onDeleted: () => provider.setFilterGender('All'),
                      ),
                    ),
                  if (provider.filterBloodGroup != 'All')
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Chip(
                        label: Text('Blood: ${provider.filterBloodGroup}'),
                        onDeleted: () => provider.setFilterBloodGroup('All'),
                      ),
                    ),
                  if (provider.searchQuery.isNotEmpty)
                    Chip(
                      label: const Text('Search Active'),
                      onDeleted: () {
                        _searchController.clear();
                        provider.setSearchQuery('');
                      },
                    ),
                ],
              ),
            ),

          // Main Listing
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => provider.loadPatients(),
              child: _buildListContent(provider, list, theme),
            ),
          ),

          // Pagination Controls
          if (provider.allPatients.isNotEmpty && !provider.isLoading && provider.errorMessage == null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: provider.hasPreviousPage ? () => provider.previousPage() : null,
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
                    label: const Text('Prev'),
                  ),
                  Text(
                    'Page ${provider.currentPage}',
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: provider.hasNextPage ? () => provider.nextPage() : null,
                    icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    label: const Text('Next'),
                  ),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.patientProfile, arguments: null);
        },
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Add Patient'),
      ),
    );
  }

  Widget _buildListContent(PatientProvider provider, List<PatientModel> list, ThemeData theme) {
    if (provider.isLoading) {
      return const Center(child: LoadingIndicator(message: 'Loading patient records...'));
    }

    if (provider.errorMessage != null) {
      return Center(
        child: CustomErrorWidget(
          errorMessage: provider.errorMessage!,
          onRetry: () => provider.loadPatients(),
        ),
      );
    }

    if (list.isEmpty) {
      return const Center(
        child: EmptyStateWidget(
          title: 'No Patients Found',
          message: 'Try modifying your filters or register a new patient profile.',
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final pat = list[index];
        final age = DateTime.now().year - pat.dob.year;
        return Hero(
          tag: 'patient_card_${pat.patientId}',
          child: Card(
            margin: const EdgeInsets.only(bottom: 12.0),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.patientProfile,
                  arguments: pat,
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    // Profile Photo
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      backgroundImage: pat.profileImage != null
                          ? NetworkImage(pat.profileImage!)
                          : null,
                      child: pat.profileImage == null
                          ? Icon(Icons.person_outline_rounded, color: theme.colorScheme.onPrimaryContainer)
                          : null,
                    ),
                    const SizedBox(width: 16),

                    // Info Columns
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pat.fullName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${pat.gender} • $age Yrs Old • Blood Group: ${pat.bloodGroup}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            pat.phone,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded, size: 16, color: theme.colorScheme.outline),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showFilterDialog(BuildContext context, PatientProvider provider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filter Patients'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: provider.filterGender,
                decoration: const InputDecoration(labelText: 'Gender'),
                items: const [
                  DropdownMenuItem(value: 'All', child: Text('All')),
                  DropdownMenuItem(value: 'Male', child: Text('Male')),
                  DropdownMenuItem(value: 'Female', child: Text('Female')),
                  DropdownMenuItem(value: 'Other', child: Text('Other')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    provider.setFilterGender(value);
                    Navigator.pop(context);
                  }
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: provider.filterBloodGroup,
                decoration: const InputDecoration(labelText: 'Blood Group'),
                items: provider.bloodGroups.map((group) {
                  return DropdownMenuItem(value: group, child: Text(group));
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    provider.setFilterBloodGroup(value);
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                provider.resetFilters();
                _searchController.clear();
                Navigator.pop(context);
              },
              child: const Text('Reset Filters'),
            ),
          ],
        );
      },
    );
  }
}
