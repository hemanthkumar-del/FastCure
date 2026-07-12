import 'package:flutter/material.dart';
import '../../features/appointment/presentation/screens/book_appointment_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/email_verification_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/doctor/data/models/doctor_model.dart';
import '../../features/doctor/presentation/screens/doctor_detail_screen.dart';
import '../../features/doctor/presentation/screens/add_edit_doctor_screen.dart';
import '../../features/medicine/presentation/screens/medicine_list_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/patient/data/models/patient_model.dart';
import '../../features/patient/presentation/screens/patient_profile_screen.dart';
import '../../features/patient/presentation/screens/add_edit_patient_screen.dart';
import '../../features/patient/presentation/screens/patient_list_screen.dart';
import '../../features/prescription/data/models/prescription_model.dart';
import '../../features/prescription/presentation/screens/prescription_detail_screen.dart';
import '../../features/prescription/presentation/screens/add_edit_prescription_screen.dart';
import '../../features/billing/data/models/bill_model.dart';
import '../../features/billing/presentation/screens/bill_list_screen.dart';
import '../../features/billing/presentation/screens/bill_detail_screen.dart';
import '../../features/billing/presentation/screens/generate_bill_screen.dart';
import '../../features/ai/presentation/screens/ai_chat_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import 'app_routes.dart';

class AppRouter {
  AppRouter._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return _buildFadeRoute(const SplashScreen(), settings);
      case AppRoutes.login:
        return _buildFadeRoute(const LoginScreen(), settings);
      case AppRoutes.register:
        return _buildFadeRoute(const RegisterScreen(), settings);
      case AppRoutes.forgotPassword:
        return _buildFadeRoute(const ForgotPasswordScreen(), settings);
      case AppRoutes.verifyEmail:
        return _buildFadeRoute(const EmailVerificationScreen(), settings);
      case AppRoutes.dashboard:
        return _buildFadeRoute(const DashboardScreen(), settings);
      case AppRoutes.doctorDetail:
        final doctor = settings.arguments as DoctorModel?;
        return _buildFadeRoute(DoctorDetailScreen(doctor: doctor), settings);
      case AppRoutes.doctorAddEdit:
        final doctor = settings.arguments as DoctorModel?;
        return _buildFadeRoute(AddEditDoctorScreen(doctor: doctor), settings);
      case AppRoutes.patientProfile:
        final patient = settings.arguments as PatientModel?;
        return _buildFadeRoute(PatientProfileScreen(patient: patient), settings);
      case AppRoutes.patientAddEdit:
        final patient = settings.arguments as PatientModel?;
        return _buildFadeRoute(AddEditPatientScreen(patient: patient), settings);
      case AppRoutes.patientList:
        return _buildFadeRoute(const PatientListScreen(), settings);
      case AppRoutes.appointmentBook:
        return _buildFadeRoute(const BookAppointmentScreen(), settings);
      case AppRoutes.medicineList:
        return _buildFadeRoute(const MedicineListScreen(), settings);
      case AppRoutes.prescriptionDetail:
        final prescription = settings.arguments as PrescriptionModel?;
        return _buildFadeRoute(PrescriptionDetailScreen(prescription: prescription), settings);
      case AppRoutes.prescriptionAddEdit:
        return _buildFadeRoute(const AddEditPrescriptionScreen(), settings);
      case AppRoutes.billList:
        return _buildFadeRoute(const BillListScreen(), settings);
      case AppRoutes.billDetail:
        final bill = settings.arguments as BillModel?;
        return _buildFadeRoute(BillDetailScreen(bill: bill), settings);
      case AppRoutes.billGenerate:
        return _buildFadeRoute(const GenerateBillScreen(), settings);
      case AppRoutes.aiChat:
        return _buildFadeRoute(const AIChatScreen(), settings);
      case AppRoutes.settings:
        return _buildFadeRoute(const SettingsScreen(), settings);
      case AppRoutes.notifications:
        return _buildFadeRoute(const NotificationsScreen(), settings);
      case AppRoutes.profile:
        return _buildFadeRoute(const ProfileScreen(), settings);
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }

  static PageRouteBuilder _buildFadeRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 250),
    );
  }
}
