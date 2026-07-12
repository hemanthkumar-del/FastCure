import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../data/models/appointment_model.dart';
import '../providers/appointment_provider.dart';

class AppointmentListView extends StatefulWidget {
  const AppointmentListView({super.key});

  @override
  State<AppointmentListView> createState() => _AppointmentListViewState();
}

class _AppointmentListViewState extends State<AppointmentListView> {
  
  Future<void> _selectCalendarDate(BuildContext context, AppointmentProvider provider) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: provider.selectedCalendarDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      provider.setSelectedCalendarDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<AppointmentProvider>(context);
    final list = provider.calendarAppointments;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.appointmentBook);
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Book New'),
      ),
      body: Column(
        children: [
          // M3 Calendar Header Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Date: ${DateFormat('dd MMM yyyy').format(provider.selectedCalendarDate)}',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: () => _selectCalendarDate(context, provider),
                  icon: const Icon(Icons.calendar_month_rounded, size: 18),
                  label: const Text('Change Date'),
                ),
              ],
            ),
          ),

          // Main Schedule Directory
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => provider.loadAppointments(),
              child: _buildListContent(provider, list, theme),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListContent(AppointmentProvider provider, List<AppointmentModel> list, ThemeData theme) {
    if (provider.isLoading) {
      return const Center(child: LoadingIndicator(message: 'Syncing schedule...'));
    }

    if (provider.errorMessage != null) {
      return Center(
        child: CustomErrorWidget(
          errorMessage: provider.errorMessage!,
          onRetry: () => provider.loadAppointments(),
        ),
      );
    }

    if (list.isEmpty) {
      return const Center(
        child: EmptyStateWidget(
          title: 'No Appointments Scheduled',
          message: 'No appointments scheduled for this date.',
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final app = list[index];
        final isPending = app.status == 'Pending';
        
        Color statusColor = Colors.orange;
        if (app.status == 'Approved') {
          statusColor = Colors.green;
        } else if (app.status == 'Cancelled' || app.status == 'Rejected') {
          statusColor = theme.colorScheme.error;
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 16.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row: Patient / Doc
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Icon(Icons.person_rounded, color: theme.colorScheme.onPrimaryContainer, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            app.patientName ?? 'Patient ID: ${app.patientId}',
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Consultant: ${app.doctorName ?? "Doctor ID: " + app.doctorId}',
                            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        app.status,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),

                // Timing & Reason details
                Row(
                  children: [
                    Icon(Icons.access_time_rounded, size: 16, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      app.time,
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Reason: ${app.reason}',
                  style: theme.textTheme.bodyMedium,
                ),
                if (app.notes.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Notes: ${app.notes}',
                    style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                  ),
                ],

                // Action Buttons for Approval Flow
                if (isPending) ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => provider.rejectAppointment(app.appointmentId),
                        icon: const Icon(Icons.close_rounded, size: 16),
                        label: const Text('Reject'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.colorScheme.error,
                          side: BorderSide(color: theme.colorScheme.error),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () => provider.approveAppointment(app.appointmentId),
                        icon: const Icon(Icons.check_rounded, size: 16),
                        label: const Text('Approve'),
                      ),
                    ],
                  ),
                ] else if (app.status == 'Approved') ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () => provider.cancelAppointment(app.appointmentId),
                        icon: const Icon(Icons.cancel_rounded, size: 16),
                        label: const Text('Cancel Appointment'),
                        style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
