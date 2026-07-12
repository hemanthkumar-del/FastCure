import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../firebase_options.dart';
import '../utils/logger.dart';

class FirebaseService {
  FirebaseService._();

  static Future<void> initialize() async {
    try {
      AppLogger.info('Initializing Firebase...');
      
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      AppLogger.info('Firebase Core initialized successfully.');

      // Configure Firestore Offline Cache / Persistence
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
      AppLogger.info('Firestore offline persistence configured.');

      // Setup FCM (Firebase Cloud Messaging) stub
      await _setupFCM();

    } catch (e) {
      AppLogger.warning(
        'Firebase initialization failed. Ensure you configure google-services.json / firebase_options.dart. '
        'Application will proceed in Mock/Offline mode.\nError: $e'
      );
    }
  }

  static Future<void> _setupFCM() async {
    try {
      final messaging = FirebaseMessaging.instance;
      
      // Request permissions (needed on iOS)
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        provisional: false,
        sound: true,
      );
      
      AppLogger.info('User notification permission status: ${settings.authorizationStatus}');

      // Get device FCM token
      final token = await messaging.getToken();
      AppLogger.info('Device FCM Token: $token');
      
      // Listen to foreground notifications
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        AppLogger.info('Foreground notification received: ${message.notification?.title}');
      });

    } catch (e) {
      AppLogger.warning('Failed to initialize FCM settings: $e');
    }
  }
}
