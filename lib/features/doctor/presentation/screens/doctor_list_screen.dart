import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../data/models/doctor_model.dart';
import '../providers/doctor_provider.dart';

class DoctorListScreen extends StatefulWidget {
  const DoctorListScreen({super.key});

  @override
  State<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      Provider.of<DoctorProvider>(context, listen: false)
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
    final provider = Provider.of<DoctorProvider>(context);
    final list = provider.doctors;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => provider.loadDoctors(),
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
                    hintText: 'Search doctors, specialties...',
                    leading: const Icon(Icons.search_rounded),
                    padding: const WidgetStatePropertyAll(
                      EdgeInsets.symmetric(horizontal: 12.0),
                    ),
                    elevation: const WidgetStatePropertyAll(1.0),
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<DoctorSortOption>(
                  icon: const Icon(Icons.sort_by_alpha_rounded),
                  tooltip: 'Sort Doctors',
                  onSelected: (option) => provider.setSortOption(option),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: DoctorSortOption.name,
                      child: Text('Sort by Name'),
                    ),
                    const PopupMenuItem(
                      value: DoctorSortOption.experience,
                      child: Text('Sort by Experience'),
                    ),
                    const PopupMenuItem(
                      value: DoctorSortOption.consultationFee,
                      child: Text('Sort by Fee'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Filters indicator row
          if (provider.filterSpecialization != 'All' || provider.searchQuery.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Text(
                    'Active Filters: ',
                    style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  if (provider.filterSpecialization != 'All')
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Chip(
                        label: Text(provider.filterSpecialization),
                        onDeleted: () => provider.setFilterSpecialization('All'),
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

          // Main Directory List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => provider.loadDoctors(),
              child: _buildListContent(provider, list, theme),
            ),
          ),

          // Pagination Controls
          if (provider.allDoctors.isNotEmpty && !provider.isLoading && provider.errorMessage == null)
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
          Navigator.pushNamed(context, AppRoutes.doctorDetail, arguments: null);
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Doctor'),
      ),
    );
  }

  Widget _buildListContent(DoctorProvider provider, List<DoctorModel> list, ThemeData theme) {
    if (provider.isLoading) {
      return const Center(child: LoadingIndicator(message: 'Loading clinical directory...'));
    }

    if (provider.errorMessage != null) {
      return Center(
        child: CustomErrorWidget(
          errorMessage: provider.errorMessage!,
          onRetry: () => provider.loadDoctors(),
        ),
      );
    }

    if (list.isEmpty) {
      return const Center(
        child: EmptyStateWidget(
          title: 'No Doctors Found',
          message: 'Try modifying your filters or add a new doctor record.',
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final doc = list[index];
        return Hero(
          tag: 'doc_card_${doc.doctorId}',
          child: Card(
            margin: const EdgeInsets.only(bottom: 12.0),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.pushNamed(
                  context, 
                  AppRoutes.doctorDetail, 
                  arguments: doc,
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
                      backgroundImage: doc.profileImage != null 
                          ? NetworkImage(doc.profileImage!) 
                          : null,
                      child: doc.profileImage == null
                          ? Icon(Icons.person_rounded, color: theme.colorScheme.onPrimaryContainer)
                          : null,
                    ),
                    const SizedBox(width: 16),

                    // Info Column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doc.fullName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${doc.specialization} • ${doc.experience} Yrs Exp',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            doc.hospitalName,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Consultation Fee & Status indicator
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${doc.consultationFee.toStringAsFixed(0)}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: doc.status == 'Active'
                                ? Colors.green.withOpacity(0.1)
                                : theme.colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            doc.status,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: doc.status == 'Active' ? Colors.green : theme.colorScheme.onErrorContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showFilterDialog(BuildContext context, DoctorProvider provider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filter Doctors'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: provider.filterSpecialization,
                decoration: const InputDecoration(labelText: 'Specialization'),
                items: provider.specializations.map((spec) {
                  return DropdownMenuItem(value: spec, child: Text(spec));
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    provider.setFilterSpecialization(value);
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
