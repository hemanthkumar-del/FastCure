import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../appointment/presentation/providers/appointment_provider.dart';
import '../../../billing/presentation/providers/bill_provider.dart';
import '../../../doctor/presentation/providers/doctor_provider.dart';
import '../../../patient/presentation/providers/patient_provider.dart';

class DashboardHomeView extends StatefulWidget {
  const DashboardHomeView({super.key});

  @override
  State<DashboardHomeView> createState() => _DashboardHomeViewState();
}

class _DashboardHomeViewState extends State<DashboardHomeView> {
  @override
  void initState() {
    super.initState();
    // Proactively refresh data streams
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DoctorProvider>(context, listen: false).loadDoctors();
      Provider.of<PatientProvider>(context, listen: false).loadPatients();
      Provider.of<AppointmentProvider>(context, listen: false).loadAppointments();
      Provider.of<BillProvider>(context, listen: false).loadBills();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final docProv = Provider.of<DoctorProvider>(context);
    final patProv = Provider.of<PatientProvider>(context);
    final appProv = Provider.of<AppointmentProvider>(context);
    final billProv = Provider.of<BillProvider>(context);

    // Compute stats
    final totalDoctors = docProv.allDoctors.length;
    final totalPatients = patProv.allPatients.length;
    final todayApps = appProv.todayAppointments.length;
    
    // Revenue: Sum of all Paid bills
    final totalRevenue = billProv.allBills
        .where((b) => b.status == 'Paid')
        .fold<double>(0.0, (sum, bill) => sum + bill.total);

    // Sort recent patient registration
    final recentPatients = List.from(patProv.allPatients)
      ..sort((a, b) => (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now()));
    final patientsSlice = recentPatients.take(3).toList();

    // Sort upcoming appointments
    final upcomingApps = appProv.allAppointments
        .where((a) => a.date.isAfter(DateTime.now().subtract(const Duration(hours: 2))) && a.status == 'Approved')
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    final appsSlice = upcomingApps.take(3).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 720;
        final horizontalPadding = isDesktop ? 24.0 : 16.0;

        return RefreshIndicator(
          onRefresh: () async {
            await docProv.loadDoctors();
            await patProv.loadPatients();
            await appProv.loadAppointments();
            await billProv.loadBills();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Welcome card
                _buildWelcomeCard(context, totalPatients),
                const SizedBox(height: 24),

                // Responsive stats grids
                isDesktop
                    ? Row(
                        children: [
                          Expanded(child: _buildStatCard(context, 'Total Doctors', '$totalDoctors', Icons.people_rounded, AppColors.primaryBlue)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildStatCard(context, 'Active Patients', '$totalPatients', Icons.assignment_ind_rounded, AppColors.secondaryEmerald)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildStatCard(context, 'Appointments Today', '$todayApps', Icons.event_available_rounded, Colors.orange)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildStatCard(context, 'Net Revenue', '\$${totalRevenue.toStringAsFixed(0)}', Icons.payments_rounded, Colors.purple)),
                        ],
                      )
                    : GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.4,
                        children: [
                          _buildStatCard(context, 'Total Doctors', '$totalDoctors', Icons.people_rounded, AppColors.primaryBlue),
                          _buildStatCard(context, 'Patients', '$totalPatients', Icons.assignment_ind_rounded, AppColors.secondaryEmerald),
                          _buildStatCard(context, 'Appointments Today', '$todayApps', Icons.event_available_rounded, Colors.orange),
                          _buildStatCard(context, 'Revenue', '\$${totalRevenue.toStringAsFixed(0)}', Icons.payments_rounded, Colors.purple),
                        ],
                      ),
                const SizedBox(height: 24),

                // Charts Section
                isDesktop
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildPieChartCard(context, appProv.allAppointments)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildBarChartCard(context, billProv.allBills)),
                        ],
                      )
                    : Column(
                        children: [
                          _buildPieChartCard(context, appProv.allAppointments),
                          const SizedBox(height: 16),
                          _buildBarChartCard(context, billProv.allBills),
                        ],
                      ),
                const SizedBox(height: 24),

                // Lists details
                isDesktop
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildUpcomingAppointmentsCard(context, appsSlice, theme)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildRecentPatientsCard(context, patientsSlice, theme)),
                        ],
                      )
                    : Column(
                        children: [
                          _buildUpcomingAppointmentsCard(context, appsSlice, theme),
                          const SizedBox(height: 16),
                          _buildRecentPatientsCard(context, patientsSlice, theme),
                        ],
                      ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeCard(BuildContext context, int count) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.primaryContainer.withOpacity(0.25),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back, Dr. Administrator!',
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Your clinic has $count active patient records registered. Manage your operations from this central panel.',
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Icon(Icons.healing_rounded, size: 64, color: theme.colorScheme.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, IconData icon, Color color) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChartCard(BuildContext context, List<dynamic> apps) {
    final theme = Theme.of(context);
    final total = apps.length;
    final approved = apps.where((a) => a.status == 'Approved').length;
    final pending = apps.where((a) => a.status == 'Pending').length;
    final cancelled = apps.where((a) => a.status == 'Cancelled' || a.status == 'Rejected').length;

    final double approvedPercent = total > 0 ? approved / total : 0;
    final double pendingPercent = total > 0 ? pending / total : 0;
    final double cancelledPercent = total > 0 ? cancelled / total : 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Appointments Status',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                // Custom Pie Draw
                SizedBox(
                  width: 100,
                  height: 100,
                  child: CustomPaint(
                    painter: _PieChartPainter(
                      percentages: [approvedPercent, pendingPercent, cancelledPercent],
                      colors: [Colors.green, Colors.orange, theme.colorScheme.error],
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLegendItem('Approved ($approved)', Colors.green),
                      const SizedBox(height: 8),
                      _buildLegendItem('Pending ($pending)', Colors.orange),
                      const SizedBox(height: 8),
                      _buildLegendItem('Cancelled ($cancelled)', theme.colorScheme.error),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }

  Widget _buildBarChartCard(BuildContext context, List<dynamic> bills) {
    final theme = Theme.of(context);
    
    // Group monthly billing sums
    final Map<String, double> monthlyRev = {'Apr': 200, 'May': 450, 'Jun': 650, 'Jul': 0.0};
    
    for (var b in bills) {
      if (b.status == 'Paid' && b.createdAt != null) {
        final month = DateFormat('MMM').format(b.createdAt!);
        if (monthlyRev.containsKey(month)) {
          monthlyRev[month] = monthlyRev[month]! + b.total;
        }
      }
    }

    final maxVal = monthlyRev.values.fold<double>(0.0, max);
    final limit = maxVal > 0 ? maxVal : 100.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Earnings (\$)',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: monthlyRev.entries.map((entry) {
                final barHeight = limit > 0 ? (entry.value / limit) * 80 : 0.0;
                return Column(
                  children: [
                    Text('\$${entry.value.toStringAsFixed(0)}', style: theme.textTheme.bodySmall?.copyWith(fontSize: 10)),
                    const SizedBox(height: 6),
                    Container(
                      width: 20,
                      height: barHeight,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(entry.key, style: theme.textTheme.bodySmall),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingAppointmentsCard(BuildContext context, List<dynamic> apps, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Upcoming Approved Actions', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (apps.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24.0),
                child: Center(child: Text('No upcoming approved actions.')),
              )
            else
              ...apps.map((app) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(child: Icon(Icons.alarm_rounded)),
                  title: Text(app.patientName ?? 'Patient'),
                  subtitle: Text('${DateFormat('dd MMM').format(app.date)} • ${app.time}'),
                  trailing: Text(app.doctorSpecialty ?? 'Cardio', style: const TextStyle(fontWeight: FontWeight.bold)),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentPatientsCard(BuildContext context, List<dynamic> patients, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recent Registered Patients', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (patients.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24.0),
                child: Center(child: Text('No registered patient files.')),
              )
            else
              ...patients.map((pat) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(child: Icon(Icons.person_rounded)),
                  title: Text(pat.fullName),
                  subtitle: Text('Blood Group: ${pat.bloodGroup}'),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.patientProfile, arguments: pat);
                  },
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _PieChartPainter extends CustomPainter {
  final List<double> percentages;
  final List<Color> colors;

  _PieChartPainter({required this.percentages, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2);
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 0.0;

    double startAngle = -pi / 2;

    for (int i = 0; i < percentages.length; i++) {
      final sweepAngle = percentages[i] * 2 * pi;
      if (sweepAngle > 0) {
        paint.color = colors[i];
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          sweepAngle,
          true,
          paint,
        );
        startAngle += sweepAngle;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
