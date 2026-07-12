import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../data/models/bill_model.dart';
import '../providers/bill_provider.dart';

class BillDetailScreen extends StatelessWidget {
  final BillModel? bill;

  const BillDetailScreen({super.key, this.bill});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<BillProvider>(context);

    if (bill == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Invoice Details')),
        body: const Center(
          child: Text('Billing record not found.'),
        ),
      );
    }

    // Pull real-time data from provider memory list if available
    final bId = bill!.billId;
    final match = provider.allBills.any((b) => b.billId == bId);
    final currentBill = match ? provider.allBills.firstWhere((b) => b.billId == bId) : bill!;

    final formattedDate = currentBill.createdAt != null 
        ? DateFormat('dd MMMM yyyy, hh:mm a').format(currentBill.createdAt!) 
        : 'Today';
    
    final isPaid = currentBill.status == 'Paid';
    final statusColor = isPaid ? Colors.green : Colors.orange;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            color: theme.colorScheme.error,
            onPressed: () => _confirmDelete(context, provider, currentBill),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Clinic metadata
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
                          'FASTCURE CLINIC BILLING',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        Icon(Icons.payment_rounded, color: theme.colorScheme.primary),
                      ],
                    ),
                    const Divider(height: 24),
                    _buildMetaRow(context, 'Invoice ID', currentBill.billId),
                    const SizedBox(height: 8),
                    _buildMetaRow(context, 'Issued Date', formattedDate),
                    const SizedBox(height: 8),
                    _buildMetaRow(context, 'Appointment Ref', currentBill.appointmentId),
                    const SizedBox(height: 8),
                    _buildMetaRow(context, 'Patient Name', currentBill.patientName ?? 'Patient ID: ${currentBill.patientId}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Itemized breakup Table
            Text(
              'Fee Breakdown',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Card(
              clipBehavior: Clip.antiAlias,
              child: Table(
                border: TableBorder.symmetric(
                  inside: BorderSide(color: theme.colorScheme.outlineVariant),
                ),
                children: [
                  // Table Header
                  TableRow(
                    decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.4)),
                    children: [
                      _buildHeaderCell(context, 'Item Description'),
                      _buildHeaderCell(context, 'Charge'),
                    ],
                  ),
                  // Doctor Fee
                  TableRow(
                    children: [
                      _buildTableCell(context, 'Consultation / Doctor Fee'),
                      _buildTableCell(context, '\$${currentBill.doctorFee.toStringAsFixed(2)}'),
                    ],
                  ),
                  // Medicine Fee
                  TableRow(
                    children: [
                      _buildTableCell(context, 'Pharmacy / Medication Fee'),
                      _buildTableCell(context, '\$${currentBill.medicineFee.toStringAsFixed(2)}'),
                    ],
                  ),
                  // Lab Fee
                  TableRow(
                    children: [
                      _buildTableCell(context, 'Diagnostic / Lab Test Fee'),
                      _buildTableCell(context, '\$${currentBill.labFee.toStringAsFixed(2)}'),
                    ],
                  ),
                  // Total Summary
                  TableRow(
                    decoration: BoxDecoration(color: theme.colorScheme.primaryContainer.withOpacity(0.15)),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          'TOTAL AMOUNT DUE',
                          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          '\$${currentBill.total.toStringAsFixed(2)}',
                          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Payment metadata
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('PAYMENT STATUS', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            currentBill.status.toUpperCase(),
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('PAYMENT METHOD', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
                        const SizedBox(height: 4),
                        Text(
                          currentBill.paymentMethod,
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Actions panel
            if (!isPaid) ...[
              ElevatedButton.icon(
                onPressed: () => _showPaymentMethodSelector(context, provider, currentBill),
                icon: const Icon(Icons.payment_rounded),
                label: const Text('Mark as Paid'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
              ),
            ] else ...[
              OutlinedButton.icon(
                onPressed: () => _markAsPending(context, provider, currentBill),
                icon: const Icon(Icons.hourglass_empty_rounded),
                label: const Text('Restore to Pending'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  foregroundColor: theme.colorScheme.error,
                  side: BorderSide(color: theme.colorScheme.error),
                ),
              ),
            ],
            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: () => _printInvoiceMock(context),
              icon: const Icon(Icons.print_rounded),
              label: const Text('Print PDF Invoice'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: theme.colorScheme.secondaryContainer,
                foregroundColor: theme.colorScheme.onSecondaryContainer,
              ),
            ),
            const SizedBox(height: 32),
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

  Widget _buildTableCell(BuildContext context, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Text(value, style: theme.textTheme.bodyMedium),
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

  void _printInvoiceMock(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(Icons.check_circle_rounded, color: Theme.of(context).colorScheme.primary, size: 48),
        title: const Text('PDF Downloaded'),
        content: const Text(
          'Invoice PDF generated and cached to local storage. Ready to print.',
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

  void _showPaymentMethodSelector(BuildContext context, BillProvider provider, BillModel bill) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Select Payment Method',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ...['Cash', 'Card', 'UPI', 'Insurance'].map((method) {
              return ListTile(
                leading: Icon(_getPaymentIcon(method)),
                title: Text(method),
                onTap: () async {
                  Navigator.pop(ctx);
                  final success = await provider.markAsPaid(bill.billId, method);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(success ? 'Invoice updated to Paid.' : 'Failed to update status.')),
                    );
                  }
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  IconData _getPaymentIcon(String method) {
    switch (method) {
      case 'Cash':
        return Icons.money_rounded;
      case 'Card':
        return Icons.credit_card_rounded;
      case 'UPI':
        return Icons.qr_code_scanner_rounded;
      case 'Insurance':
        return Icons.verified_user_rounded;
      default:
        return Icons.payment_rounded;
    }
  }

  Future<void> _markAsPending(BuildContext context, BillProvider provider, BillModel bill) async {
    final success = await provider.markAsPending(bill.billId);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(success ? 'Invoice updated to Pending.' : 'Failed to update status.')),
      );
    }
  }

  void _confirmDelete(BuildContext context, BillProvider provider, BillModel bill) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Invoice?'),
        content: const Text('Are you sure you want to remove this invoice record permanently?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await provider.deleteBill(bill.billId);
              if (context.mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invoice deleted.')),
                  );
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(provider.errorMessage ?? 'Failed to delete invoice.'),
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
