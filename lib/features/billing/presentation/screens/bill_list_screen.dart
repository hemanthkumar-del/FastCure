import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../data/models/bill_model.dart';
import '../providers/bill_provider.dart';

class BillListScreen extends StatefulWidget {
  const BillListScreen({super.key});

  @override
  State<BillListScreen> createState() => _BillListScreenState();
}

class _BillListScreenState extends State<BillListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      Provider.of<BillProvider>(context, listen: false)
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
    final provider = Provider.of<BillProvider>(context);
    final list = provider.bills;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => provider.loadBills(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.billGenerate);
        },
        icon: const Icon(Icons.add_card_rounded),
        label: const Text('New Invoice'),
      ),
      body: Column(
        children: [
          // Search Box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Search invoice by patient...',
              leading: const Icon(Icons.search_rounded),
              padding: const WidgetStatePropertyAll(
                EdgeInsets.symmetric(horizontal: 12.0),
              ),
              elevation: const WidgetStatePropertyAll(1.0),
            ),
          ),

          // Filters status chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: ['All', 'Paid', 'Pending'].map((status) {
                final isSelected = provider.statusFilter == status;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    selected: isSelected,
                    label: Text(status),
                    onSelected: (selected) {
                      if (selected) {
                        provider.setStatusFilter(status);
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),

          // Main Invoices List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => provider.loadBills(),
              child: _buildListContent(provider, list, theme),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListContent(BillProvider provider, List<BillModel> list, ThemeData theme) {
    if (provider.isLoading) {
      return const Center(child: LoadingIndicator(message: 'Syncing ledger status...'));
    }

    if (provider.errorMessage != null) {
      return Center(
        child: CustomErrorWidget(
          errorMessage: provider.errorMessage!,
          onRetry: () => provider.loadBills(),
        ),
      );
    }

    if (list.isEmpty) {
      return const Center(
        child: EmptyStateWidget(
          title: 'No Invoices Found',
          message: 'No billing records match your search query.',
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final bill = list[index];
        final isPaid = bill.status == 'Paid';
        final statusColor = isPaid ? Colors.green : Colors.orange;
        final formattedDate = bill.createdAt != null 
            ? DateFormat('dd MMM yyyy').format(bill.createdAt!) 
            : 'Today';

        return Card(
          margin: const EdgeInsets.only(bottom: 12.0),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.billDetail,
                arguments: bill,
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Circular bill badge
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.request_quote_rounded,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Metadata details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bill.patientName ?? 'Patient ID: ${bill.patientId}',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'ID: ${bill.billId} • $formattedDate',
                          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                bill.status,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Via: ${bill.paymentMethod}',
                              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Pricing total
                  Text(
                    '\$${bill.total.toStringAsFixed(2)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
