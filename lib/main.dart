import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_strings.dart';
import 'core/routes/app_router.dart';
import 'core/routes/app_routes.dart';
import 'core/services/firebase_service.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/logger.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/doctor/data/repositories/doctor_repository_impl.dart';
import 'features/doctor/presentation/providers/doctor_provider.dart';
import 'features/patient/data/repositories/patient_repository_impl.dart';
import 'features/patient/presentation/providers/patient_provider.dart';
import 'features/appointment/data/repositories/appointment_repository_impl.dart';
import 'features/appointment/presentation/providers/appointment_provider.dart';
import 'features/medicine/data/repositories/medicine_repository_impl.dart';
import 'features/medicine/presentation/providers/medicine_provider.dart';
import 'features/prescription/data/repositories/prescription_repository_impl.dart';
import 'features/prescription/presentation/providers/prescription_provider.dart';
import 'features/settings/presentation/providers/settings_provider.dart';
import 'features/billing/data/repositories/bill_repository_impl.dart';
import 'features/billing/presentation/providers/bill_provider.dart';
import 'features/ai/presentation/providers/chat_provider.dart';

void main() async {
  // Ensure Flutter widgets are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (wrapped in a robust fallback setup)
  await FirebaseService.initialize();

  AppLogger.info('Application bootstrap initialized.');

  runApp(const FastCureApp());
}

class FastCureApp extends StatelessWidget {
  const FastCureApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider(AuthRepositoryImpl())),
        ChangeNotifierProvider(create: (_) => DoctorProvider(DoctorRepositoryImpl())),
        ChangeNotifierProvider(create: (_) => PatientProvider(PatientRepositoryImpl())),
        ChangeNotifierProvider(create: (_) => AppointmentProvider(AppointmentRepositoryImpl())),
        ChangeNotifierProvider(create: (_) => MedicineProvider(MedicineRepositoryImpl())),
        ChangeNotifierProvider(create: (_) => PrescriptionProvider(PrescriptionRepositoryImpl())),
        ChangeNotifierProvider(create: (_) => BillProvider(BillRepositoryImpl())),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: AppStrings.appName,
            debugShowCheckedModeBanner: false,
            
            // Themes
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            
            // Routing
            initialRoute: AppRoutes.splash,
            onGenerateRoute: AppRouter.generateRoute,
          );
        },
      ),
    );
  }
}
