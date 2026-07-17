import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../doctor/presentation/providers/doctor_provider.dart';
import '../../../doctor/data/models/doctor_model.dart';
import '../../../patient/presentation/providers/patient_provider.dart';
import '../../../patient/data/models/patient_model.dart';
import '../../data/models/appointment_model.dart';
import '../providers/appointment_provider.dart';

class AppointmentDetailScreen extends StatefulWidget {
  final AppointmentModel appointment;
  const AppointmentDetailScreen({super.key, required this.appointment});

  @override
  State<AppointmentDetailScreen> createState() => _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState extends State<AppointmentDetailScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final appProvider = Provider.of<AppointmentProvider>(context);
    final docProv = Provider.of<DoctorProvider>(context, listen: false);
    final patProv = Provider.of<PatientProvider>(context, listen: false);

    // Resolve doctor and patient details dynamically
    DoctorModel? doctor;
    try {
      doctor = docProv.allDoctors.firstWhere((d) => d.doctorId == widget.appointment.doctorId);
    } catch (_) {
      doctor = docProv.allDoctors.isNotEmpty ? docProv.allDoctors.first : null;
    }

    PatientModel? patient;
    try {
      patient = patProv.allPatients.firstWhere((p) => p.patientId == widget.appointment.patientId);
    } catch (_) {
      patient = patProv.allPatients.isNotEmpty ? patProv.allPatients.first : null;
    }

    // Determine status colors
    Color statusColor = Colors.orange;
    if (widget.appointment.status == 'Approved') {
      statusColor = const Color(0xFF10B981);
    } else if (widget.appointment.status == 'Cancelled' || widget.appointment.status == 'Rejected') {
      statusColor = const Color(0xFFEF4444);
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Appointment Details',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        actions: [
          // Status Chip in Header
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.appointment.status,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Doctor Information Card
                  _buildDoctorCard(theme, doctor, isDark),
                  const SizedBox(height: 16),

                  // 2. Appointment Schedule details card
                  _buildAppointmentInfoCard(theme, isDark),
                  const SizedBox(height: 16),

                  // 3. Patient Info Card
                  _buildPatientCard(theme, patient, isDark),
                  const SizedBox(height: 16),

                  // 4. Symptoms / Notes Card
                  _buildSymptomsCard(theme, isDark),
                  const SizedBox(height: 24),

                  // 5. Vertical Status Timeline
                  _buildStatusTimeline(theme, isDark),
                  const SizedBox(height: 32),

                  // 6. Action buttons
                  _buildActionsSection(context, appProvider, theme, statusColor),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorCard(ThemeData theme, dynamic doctor, bool isDark) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              backgroundImage: doctor?.profileImage != null
                  ? NetworkImage(doctor!.profileImage!)
                  : null,
              child: doctor?.profileImage == null
                  ? Icon(Icons.person_rounded, size: 28, color: theme.colorScheme.primary)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.appointment.doctorName ?? (doctor?.fullName ?? 'Doctor Specialist'),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.appointment.doctorSpecialty ?? (doctor?.specialization ?? 'General Practitioner'),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF2563EB),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.local_hospital_outlined, size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          doctor?.hospitalName ?? 'FastCure Health Center',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentInfoCard(ThemeData theme, bool isDark) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Schedule Details',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              theme,
              Icons.calendar_month_rounded,
              'Date',
              DateFormat('EEEE, dd MMMM yyyy').format(widget.appointment.date),
              isDark,
            ),
            const Divider(height: 24),
            _buildDetailRow(
              theme,
              Icons.access_time_rounded,
              'Time Slot',
              widget.appointment.time,
              isDark,
            ),
            const Divider(height: 24),
            _buildDetailRow(
              theme,
              Icons.tag_rounded,
              'Appointment ID',
              widget.appointment.appointmentId,
              isDark,
            ),
            const Divider(height: 24),
            _buildDetailRow(
              theme,
              Icons.online_prediction_rounded,
              'Consultation Type',
              'In-person Visit',
              isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientCard(ThemeData theme, dynamic patient, bool isDark) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Patient Information',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              theme,
              Icons.person_outline_rounded,
              'Full Name',
              widget.appointment.patientName ?? (patient?.fullName ?? 'Patient File'),
              isDark,
            ),
            const Divider(height: 24),
            _buildDetailRow(
              theme,
              Icons.email_outlined,
              'Email Address',
              patient?.email ?? 'Unavailable',
              isDark,
            ),
            const Divider(height: 24),
            _buildDetailRow(
              theme,
              Icons.phone_outlined,
              'Contact Number',
              patient?.phone ?? 'Unavailable',
              isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSymptomsCard(ThemeData theme, bool isDark) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reason for Visit',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.appointment.reason,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.grey[300] : const Color(0xFF334155),
              ),
            ),
            if (widget.appointment.notes.isNotEmpty) ...[
              const Divider(height: 24),
              Text(
                'Clinical Notes',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.appointment.notes,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTimeline(ThemeData theme, bool isDark) {
    final status = widget.appointment.status;

    final bool step1 = true; // Booked
    final bool step2 = status == 'Approved'; // Confirmed
    final bool step3 = status == 'Approved'; // Consultation Pending / Completed

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Timeline Status',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 20),
          _buildTimelineItem(theme, 'Appointment Booked', 'Request received successfully', step1, true, isDark),
          _buildTimelineItem(theme, 'Confirmed by Staff', 'Slot scheduled with consultant', step2, step2, isDark),
          _buildTimelineItem(theme, 'Consultation Pending', 'Awaiting appointment slot time', step3, false, isDark),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    ThemeData theme,
    String title,
    String subtitle,
    bool isCompleted,
    bool showLine,
    bool isDark,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? const Color(0xFF10B981)
                    : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
              ),
              child: Icon(
                isCompleted ? Icons.check_rounded : Icons.pending_rounded,
                color: Colors.white,
                size: 14,
              ),
            ),
            if (showLine)
              Container(
                width: 2,
                height: 40,
                color: isCompleted
                    ? const Color(0xFF10B981)
                    : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isCompleted ? (isDark ? Colors.white : const Color(0xFF0F172A)) : Colors.grey[500],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(ThemeData theme, IconData icon, String label, String value, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: const Color(0xFF2563EB)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionsSection(
    BuildContext context,
    AppointmentProvider provider,
    ThemeData theme,
    Color statusColor,
  ) {
    final status = widget.appointment.status;
    final isPending = status == 'Pending';

    if (isPending) {
      return Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 52,
              child: OutlinedButton(
                onPressed: () async {
                  await provider.rejectAppointment(widget.appointment.appointmentId);
                  if (context.mounted) Navigator.pop(context);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFEF4444),
                  side: const BorderSide(color: Color(0xFFEF4444)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Reject Request', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF14B8A6)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ElevatedButton(
                onPressed: () async {
                  await provider.approveAppointment(widget.appointment.appointmentId);
                  if (context.mounted) Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Approve Slot',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    } else if (status == 'Approved') {
      return Container(
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEF4444)),
        ),
        child: TextButton.icon(
          onPressed: () async {
            await provider.cancelAppointment(widget.appointment.appointmentId);
            if (context.mounted) Navigator.pop(context);
          },
          icon: const Icon(Icons.cancel_rounded, color: Color(0xFFEF4444)),
          label: const Text(
            'Cancel Appointment',
            style: TextStyle(
              color: Color(0xFFEF4444),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
