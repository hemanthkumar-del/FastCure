import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../data/models/medicine_model.dart';
import '../providers/medicine_provider.dart';

class MedicineListScreen extends StatefulWidget {
  const MedicineListScreen({super.key});

  @override
  State<MedicineListScreen> createState() => _MedicineListScreenState();
}

class _MedicineListScreenState extends State<MedicineListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      Provider.of<MedicineProvider>(context, listen: false)
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
    final provider = Provider.of<MedicineProvider>(context);
    final list = provider.medicines;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pharmacy Inventory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => provider.loadMedicines(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Search medicines, manufacturers...',
              leading: const Icon(Icons.search_rounded),
              padding: const WidgetStatePropertyAll(
                EdgeInsets.symmetric(horizontal: 12.0),
              ),
              elevation: const WidgetStatePropertyAll(1.0),
            ),
          ),

          // Main Inventory Grid
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => provider.loadMedicines(),
              child: _buildListContent(provider, list, theme),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddMedicineDialog(context, provider),
        icon: const Icon(Icons.add_to_photos_rounded),
        label: const Text('Add Item'),
      ),
    );
  }

  Widget _buildListContent(MedicineProvider provider, List<MedicineModel> list, ThemeData theme) {
    if (provider.isLoading) {
      return const Center(child: LoadingIndicator(message: 'Syncing pharmacy stock...'));
    }

    if (provider.errorMessage != null) {
      return Center(
        child: CustomErrorWidget(
          errorMessage: provider.errorMessage!,
          onRetry: () => provider.loadMedicines(),
        ),
      );
    }

    if (list.isEmpty) {
      return const Center(
        child: EmptyStateWidget(
          title: 'Empty Inventory',
          message: 'No medicines match your search. Add a new pharmacy record.',
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final med = list[index];
        final isLowStock = med.stock <= 20;
        final stockColor = isLowStock ? theme.colorScheme.error : Colors.green;

        return Card(
          margin: const EdgeInsets.only(bottom: 12.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Medical bottle design icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    med.type == 'Syrup' ? Icons.liquor_rounded : Icons.vaccines_rounded,
                    color: theme.colorScheme.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),

                // Specs Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${med.name} (${med.dosage})',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Manufacturer: ${med.manufacturer}',
                        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: stockColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Stock: ${med.stock} pcs',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: stockColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Category: ${med.category}',
                            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Pricing & Edit Menu
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${med.price.toStringAsFixed(2)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    IconButton(
                      icon: const Icon(Icons.edit_note_rounded),
                      onPressed: () => _showAddMedicineDialog(context, provider, existing: med),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddMedicineDialog(BuildContext context, MedicineProvider provider, {MedicineModel? existing}) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: existing?.name ?? '');
    final manController = TextEditingController(text: existing?.manufacturer ?? '');
    final dosageController = TextEditingController(text: existing?.dosage ?? '');
    final stockController = TextEditingController(text: existing?.stock.toString() ?? '');
    final priceController = TextEditingController(text: existing?.price.toString() ?? '');
    
    String category = existing?.category ?? 'General';
    String type = existing?.type ?? 'Tablet';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null ? 'Add Medicine' : 'Edit Medicine Details'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  controller: nameController,
                  label: 'Medicine Name',
                  hintText: 'e.g. Paracetamol',
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: manController,
                  label: 'Manufacturer',
                  hintText: 'e.g. Pfizer',
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: dosageController,
                        label: 'Dosage',
                        hintText: 'e.g. 500mg',
                        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: type,
                        decoration: const InputDecoration(labelText: 'Type'),
                        items: const [
                          DropdownMenuItem(value: 'Tablet', child: Text('Tablet')),
                          DropdownMenuItem(value: 'Capsule', child: Text('Capsule')),
                          DropdownMenuItem(value: 'Syrup', child: Text('Syrup')),
                          DropdownMenuItem(value: 'Inhaler', child: Text('Inhaler')),
                        ],
                        onChanged: (val) {
                          if (val != null) type = val;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: stockController,
                        label: 'Stock Count',
                        hintText: 'e.g. 100',
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Required';
                          final num = int.tryParse(v);
                          if (num == null || num < 0) return 'Must be positive';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CustomTextField(
                        controller: priceController,
                        label: 'Unit Price',
                        hintText: 'e.g. 5.50',
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Required';
                          final num = double.tryParse(v);
                          if (num == null || num < 0) return 'Must be positive';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: const [
                    DropdownMenuItem(value: 'General', child: Text('General')),
                    DropdownMenuItem(value: 'Antibiotics', child: Text('Antibiotics')),
                    DropdownMenuItem(value: 'Analgesics', child: Text('Analgesics')),
                    DropdownMenuItem(value: 'Cardiovascular', child: Text('Cardiovascular')),
                  ],
                  onChanged: (val) {
                    if (val != null) category = val;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                Navigator.pop(ctx);
                final med = MedicineModel(
                  medicineId: existing?.medicineId ?? 'med_${DateTime.now().millisecondsSinceEpoch}',
                  name: nameController.text.trim(),
                  manufacturer: manController.text.trim(),
                  dosage: dosageController.text.trim(),
                  stock: int.parse(stockController.text),
                  price: double.parse(priceController.text),
                  category: category,
                  type: type,
                );

                final success = existing == null
                    ? await provider.addMedicine(med)
                    : await provider.updateMedicine(med);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(success ? 'Inventory updated.' : 'Failed to update inventory.')),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
