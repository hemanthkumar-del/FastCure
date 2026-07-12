import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/custom_text_field.dart';

class MedicineListScreen extends StatefulWidget {
  const MedicineListScreen({super.key});

  @override
  State<MedicineListScreen> createState() => _MedicineListScreenState();
}

class _MedicineListScreenState extends State<MedicineListScreen> {
  final _searchController = TextEditingController();
  final List<Map<String, dynamic>> _allMedicines = [
    {
      'name': 'Amoxicillin 500mg',
      'category': 'Antibiotic',
      'type': 'Capsule',
      'stock': 'In Stock',
      'dosage': '3 times daily after meals',
    },
    {
      'name': 'Atorvastatin 20mg',
      'category': 'Cardiovascular',
      'type': 'Tablet',
      'stock': 'In Stock',
      'dosage': '1 tablet at bedtime',
    },
    {
      'name': 'Metformin 850mg',
      'category': 'Antidiabetic',
      'type': 'Tablet',
      'stock': 'Low Stock',
      'dosage': '2 times daily with breakfast & dinner',
    },
    {
      'name': 'Albuterol Inhaler',
      'category': 'Respiratory',
      'type': 'Inhaler',
      'stock': 'In Stock',
      'dosage': '2 puffs every 4-6 hours as needed',
    },
    {
      'name': 'Ibuprofen 400mg',
      'category': 'Analgesic',
      'type': 'Tablet',
      'stock': 'Out of Stock',
      'dosage': '1 tablet every 6 hours as needed for pain',
    },
  ];

  List<Map<String, dynamic>> _filteredMedicines = [];

  @override
  void initState() {
    super.initState();
    _filteredMedicines = _allMedicines;
  }

  void _filterSearch(String query) {
    setState(() {
      _filteredMedicines = _allMedicines
          .where((med) =>
              med['name'].toLowerCase().contains(query.toLowerCase()) ||
              med['category'].toLowerCase().contains(query.toLowerCase()))
          .toList();
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicine Catalog'),
      ),
      body: Column(
        children: [
          // Search input bar
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            child: CustomTextField(
              controller: _searchController,
              label: 'Search Medicine',
              hintText: 'Search by name or category...',
              prefixIcon: Icons.search_rounded,
              onChanged: _filterSearch,
            ),
          ),
          
          // List
          Expanded(
            child: _filteredMedicines.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 48, color: theme.colorScheme.outline),
                        const SizedBox(height: 12),
                        const Text('No medicines found match your search.'),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingM),
                    itemCount: _filteredMedicines.length,
                    itemBuilder: (context, index) {
                      final item = _filteredMedicines[index];
                      final isLow = item['stock'] == 'Low Stock';
                      final isOut = item['stock'] == 'Out of Stock';
                      final badgeColor = isOut
                          ? AppColors.alertCoral
                          : isLow
                              ? Colors.orange
                              : AppColors.secondaryEmerald;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(AppConstants.paddingM),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    item['name'],
                                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: badgeColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(AppConstants.radiusS),
                                    ),
                                    child: Text(
                                      item['stock'],
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: badgeColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(item['category'], style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.primary)),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.circle, size: 4, color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Text(item['type'], style: theme.textTheme.bodyMedium),
                                ],
                              ),
                              const Divider(height: 24),
                              Row(
                                children: [
                                  Icon(Icons.info_outline_rounded, size: 16, color: theme.colorScheme.outline),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Dosage: ${item['dosage']}',
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
