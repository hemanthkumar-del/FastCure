import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../appointment/presentation/widgets/appointment_list_view.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../doctor/presentation/screens/doctor_list_screen.dart';
import '../../../prescription/presentation/widgets/prescription_list_view.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../widgets/dashboard_home_view.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    final isAdmin = user?.role == 'Admin';

    // Role-based views & items
    final List<Widget> views = [];
    final List<BottomNavigationBarItem> navItems = [];

    if (isAdmin) {
      views.addAll([
        DashboardHomeView(onTabSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        }),
        const DoctorListScreen(),
        const AppointmentListView(),
        const PrescriptionListView(),
        const ProfileScreen(),
      ]);
      navItems.addAll(const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          activeIcon: Icon(Icons.dashboard_rounded),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people_outline_rounded),
          activeIcon: Icon(Icons.people_rounded),
          label: 'Doctors',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today_outlined),
          activeIcon: Icon(Icons.calendar_today_rounded),
          label: 'Schedule',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long_outlined),
          activeIcon: Icon(Icons.receipt_long_rounded),
          label: 'Rx',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline_rounded),
          activeIcon: Icon(Icons.person_rounded),
          label: 'Profile',
        ),
      ]);
    } else {
      views.addAll([
        DashboardHomeView(onTabSelected: (index) {
          // Switch to Profile (index 1 in the patient view list)
          if (index == 4) {
            setState(() {
              _currentIndex = 1;
            });
          }
        }),
        const ProfileScreen(),
      ]);
      navItems.addAll(const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          activeIcon: Icon(Icons.dashboard_rounded),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline_rounded),
          activeIcon: Icon(Icons.person_rounded),
          label: 'Profile',
        ),
      ]);
    }

    // Guard out of bounds index after role change
    if (_currentIndex >= views.length) {
      _currentIndex = 0;
    }

    return Scaffold(
      appBar: _currentIndex == 0
          ? null
          : AppBar(
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.healing_rounded, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(isAdmin
                      ? (const [
                          AppStrings.appName,
                          AppStrings.doctors,
                          AppStrings.appointments,
                          AppStrings.prescriptions,
                          AppStrings.profile
                        ])[_currentIndex]
                      : (const [AppStrings.appName, AppStrings.profile])[_currentIndex]),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.notifications);
                  },
                ),
                if (isAdmin)
                  IconButton(
                    icon: const Icon(Icons.settings_outlined),
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.settings);
                    },
                  ),
              ],
            ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: views[_currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: navItems,
      ),
    );
  }
}
