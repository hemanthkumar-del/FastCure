import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../appointment/presentation/providers/appointment_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../billing/presentation/providers/bill_provider.dart';
import '../../../doctor/presentation/providers/doctor_provider.dart';
import '../../../doctor/presentation/screens/doctor_list_screen.dart';
import '../../../patient/presentation/providers/patient_provider.dart';
import '../../../prescription/presentation/widgets/prescription_list_view.dart';
import '../../../../core/widgets/user_avatar.dart';

class DashboardHomeView extends StatefulWidget {
  final Function(int)? onTabSelected;
  const DashboardHomeView({super.key, this.onTabSelected});

  @override
  State<DashboardHomeView> createState() => _DashboardHomeViewState();
}

class _DashboardHomeViewState extends State<DashboardHomeView> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeHeader;
  late Animation<Offset> _slideHeader;
  late Animation<double> _fadeSummary;
  late Animation<Offset> _slideSummary;
  late Animation<double> _fadeGrid;
  late Animation<Offset> _slideGrid;
  late Animation<double> _fadeAppointment;
  late Animation<Offset> _slideAppointment;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    final curve = CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic);

    _fadeHeader = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: const Interval(0.0, 0.5, curve: Curves.easeOut)),
    );
    _slideHeader = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic)),
    );

    _fadeSummary = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: const Interval(0.2, 0.7, curve: Curves.easeOut)),
    );
    _slideSummary = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: const Interval(0.2, 0.7, curve: Curves.easeOutCubic)),
    );

    _fadeGrid = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: const Interval(0.4, 0.9, curve: Curves.easeOut)),
    );
    _slideGrid = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: const Interval(0.4, 0.9, curve: Curves.easeOutCubic)),
    );

    _fadeAppointment = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: const Interval(0.6, 1.0, curve: Curves.easeOut)),
    );
    _slideAppointment = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: const Interval(0.6, 1.0, curve: Curves.easeOutCubic)),
    );

    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DoctorProvider>(context, listen: false).loadDoctors();
      Provider.of<PatientProvider>(context, listen: false).loadPatients();
      Provider.of<AppointmentProvider>(context, listen: false).loadAppointments();
      Provider.of<BillProvider>(context, listen: false).loadBills();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    final isAdmin = user?.role == 'Admin';

    return RefreshIndicator(
      onRefresh: () async {
        await Provider.of<DoctorProvider>(context, listen: false).loadDoctors();
        await Provider.of<PatientProvider>(context, listen: false).loadPatients();
        await Provider.of<AppointmentProvider>(context, listen: false).loadAppointments();
        await Provider.of<BillProvider>(context, listen: false).loadBills();
      },
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: isAdmin
                ? _buildAdminDashboard(context, theme, isDark, user?.fullName ?? 'Administrator')
                : _buildPatientDashboard(context, theme, isDark, user?.fullName ?? 'User'),
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------
  // PATIENT DASHBOARD LAYOUT
  // ----------------------------------------------------
  Widget _buildPatientDashboard(BuildContext context, ThemeData theme, bool isDark, String userName) {
    final user = Provider.of<AuthProvider>(context).currentUser;
    final appProv = Provider.of<AppointmentProvider>(context);
    final upcomingApps = appProv.allAppointments
        .where((a) => a.date.isAfter(DateTime.now().subtract(const Duration(hours: 2))))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    final nextApp = upcomingApps.isNotEmpty ? upcomingApps.first : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Header (Greeting + User Profile + Bell)
        FadeTransition(
          opacity: _fadeHeader,
          child: SlideTransition(
            position: _slideHeader,
            child: Row(
              children: [
                UserAvatar(
                  photoUrl: user?.photoUrl,
                  radius: 26,
                  name: userName,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getGreeting(),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        userName,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.notifications);
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // 2. Health Summary Card (Beautiful Gradient Card)
        FadeTransition(
          opacity: _fadeSummary,
          child: SlideTransition(
            position: _slideSummary,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF14B8A6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Health Overview',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Icon(Icons.favorite_rounded, color: Colors.white, size: 24),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'All Health Systems Normal',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Your diagnostics match your clinical profile. Keep tracking your metrics to sync your records.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildMetricBadge('Pulse: 72 bpm', Icons.bolt_rounded),
                      const SizedBox(width: 12),
                      _buildMetricBadge('Sync: Active', Icons.sync_rounded),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // 3. Quick Actions Grid
        FadeTransition(
          opacity: _fadeGrid,
          child: SlideTransition(
            position: _slideGrid,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Actions',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.35,
                  children: [
                    _buildActionCard(
                      context,
                      'Book Appointment',
                      Icons.calendar_month_rounded,
                      const Color(0xFF2563EB),
                      () => Navigator.pushNamed(context, AppRoutes.appointmentBook),
                    ),
                    _buildActionCard(
                      context,
                      'Find Doctor',
                      Icons.search_rounded,
                      const Color(0xFF14B8A6),
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Scaffold(
                            body: DoctorListScreen(),
                          ),
                        ),
                      ),
                    ),
                    _buildActionCard(
                      context,
                      'Prescriptions',
                      Icons.receipt_long_rounded,
                      const Color(0xFF10B981),
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Scaffold(
                            appBar: AppBar(title: const Text('My Prescriptions')),
                            body: const PrescriptionListView(),
                          ),
                        ),
                      ),
                    ),
                    _buildActionCard(
                      context,
                      'AI Assistant',
                      Icons.assistant_rounded,
                      Colors.purple,
                      () => Navigator.pushNamed(context, AppRoutes.aiChat),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // 4. Upcoming Appointment Card
        FadeTransition(
          opacity: _fadeAppointment,
          child: SlideTransition(
            position: _slideAppointment,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upcoming Schedule',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 12),
                if (nextApp == null)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: const Center(
                      child: Text('No upcoming approved actions found.'),
                    ),
                  )
                else
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                      side: BorderSide(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.appointmentDetail,
                          arguments: nextApp,
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                              child: Icon(Icons.person_rounded, color: theme.colorScheme.primary, size: 28),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    nextApp.doctorName ?? 'Doctor Specialist',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    nextApp.doctorSpecialty ?? 'General Health',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.access_time_rounded,
                                        size: 16,
                                        color: theme.colorScheme.primary,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${DateFormat('dd MMM').format(nextApp.date)} • ${nextApp.time}',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? Colors.grey[300] : const Color(0xFF334155),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: nextApp.status == 'Approved'
                                    ? const Color(0xFFD1FAE5)
                                    : const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                nextApp.status,
                                style: TextStyle(
                                  color: nextApp.status == 'Approved'
                                      ? const Color(0xFF065F46)
                                      : const Color(0xFF92400E),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricBadge(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------
  // ADMIN DASHBOARD LAYOUT (Clinic Management Statistics)
  // ----------------------------------------------------
  Widget _buildAdminDashboard(BuildContext context, ThemeData theme, bool isDark, String adminName) {
    final docProv = Provider.of<DoctorProvider>(context);
    final patProv = Provider.of<PatientProvider>(context);
    final appProv = Provider.of<AppointmentProvider>(context);
    final billProv = Provider.of<BillProvider>(context);

    // Compute clinic metrics
    final totalDoctors = docProv.allDoctors.length;
    final totalPatients = patProv.allPatients.length;
    final todayApps = appProv.todayAppointments.length;
    final totalRevenue = billProv.allBills
        .where((b) => b.status == 'Paid')
        .fold<double>(0.0, (sum, bill) => sum + bill.total);

    // Slices for lists
    final recentPatients = List.from(patProv.allPatients)
      ..sort((a, b) => (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now()));
    final patientsSlice = recentPatients.take(3).toList();

    final upcomingApps = appProv.allAppointments
        .where((a) => a.date.isAfter(DateTime.now().subtract(const Duration(hours: 2))) && a.status == 'Approved')
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    final appsSlice = upcomingApps.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Welcome admin header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FastCure Central Admin',
                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[500], fontWeight: FontWeight.bold),
                ),
                Text(
                  'Welcome, Administrator',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.settings);
              },
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Clinic Stats Grid
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.4,
          children: [
            _buildAdminStatCard('Total Doctors', '$totalDoctors', Icons.people_rounded, const Color(0xFF2563EB), theme, isDark),
            _buildAdminStatCard('Active Patients', '$totalPatients', Icons.assignment_ind_rounded, const Color(0xFF14B8A6), theme, isDark),
            _buildAdminStatCard('Today Visits', '$todayApps', Icons.event_available_rounded, Colors.orange, theme, isDark),
            _buildAdminStatCard('Total Net Revenue', '\$${totalRevenue.toStringAsFixed(0)}', Icons.payments_rounded, Colors.purple, theme, isDark),
          ],
        ),
        const SizedBox(height: 24),

        // Charts
        _buildPieChartCard(context, appProv.allAppointments),
        const SizedBox(height: 16),
        _buildBarChartCard(context, billProv.allBills),
        const SizedBox(height: 24),

        // Lists Detail Section
        _buildUpcomingAppointmentsCard(context, appsSlice, theme, isDark),
        const SizedBox(height: 16),
        _buildRecentPatientsCard(context, patientsSlice, theme, isDark),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildAdminStatCard(String label, String value, IconData icon, Color color, ThemeData theme, bool isDark) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
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
    final isDark = theme.brightness == Brightness.dark;
    final total = apps.length;
    final approved = apps.where((a) => a.status == 'Approved').length;
    final pending = apps.where((a) => a.status == 'Pending').length;
    final cancelled = apps.where((a) => a.status == 'Cancelled' || a.status == 'Rejected').length;

    final double approvedPercent = total > 0 ? approved / total : 0;
    final double pendingPercent = total > 0 ? pending / total : 0;
    final double cancelledPercent = total > 0 ? cancelled / total : 0;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
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
                SizedBox(
                  width: 100,
                  height: 100,
                  child: CustomPaint(
                    painter: _PieChartPainter(
                      percentages: [approvedPercent, pendingPercent, cancelledPercent],
                      colors: [const Color(0xFF10B981), Colors.orange, const Color(0xFFEF4444)],
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLegendItem('Approved ($approved)', const Color(0xFF10B981)),
                      const SizedBox(height: 8),
                      _buildLegendItem('Pending ($pending)', Colors.orange),
                      const SizedBox(height: 8),
                      _buildLegendItem('Cancelled ($cancelled)', const Color(0xFFEF4444)),
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
    final isDark = theme.brightness == Brightness.dark;

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
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
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
                      decoration: const BoxDecoration(
                        color: Color(0xFF2563EB),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
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

  Widget _buildUpcomingAppointmentsCard(BuildContext context, List<dynamic> apps, ThemeData theme, bool isDark) {
    return Card(
      elevation: 0,
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
                  trailing: Text(app.doctorSpecialty ?? 'Cardio', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentPatientsCard(BuildContext context, List<dynamic> patients, ThemeData theme, bool isDark) {
    return Card(
      elevation: 0,
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
