import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'viewmodels/login_viewmodel.dart';
import 'viewmodels/signup_viewmodel.dart';
import 'viewmodels/forgot_password_viewmodel.dart';
import 'viewmodels/chat_viewmodel.dart';
import 'viewmodels/settings_viewmodel.dart';
import 'viewmodels/job_viewmodel.dart';
import 'viewmodels/notification_viewmodel.dart';
import 'viewmodels/earnings_viewmodel.dart';
import 'utils/screen_unit_util.dart';
import 'resources/themes/app_theme.dart';
import 'routes/app_router.dart';
import 'firebase_options.dart';

// Top-level function for handling background messages
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Handling background message: ${message.messageId}');
  debugPrint('Background message data: ${message.data}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final messaging = FirebaseMessaging.instance;
  final settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
    carPlay: true,
    criticalAlert: true,
    provisional: true,
    announcement: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized ||
      settings.authorizationStatus == AuthorizationStatus.provisional) {
    final token = await messaging.getToken();
    debugPrint('FCM Device Token: $token');
  } else {
    debugPrint('FCM permission not granted: ${settings.authorizationStatus}');
  }

  messaging.onTokenRefresh.listen((newToken) {
    debugPrint('FCM Token refreshed: $newToken');
  });

  // Set up background message handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Check if app was opened from a notification
  messaging.getInitialMessage().then((RemoteMessage? message) {
    if (message != null) {
      debugPrint('App opened from notification: ${message.messageId}');
      debugPrint('Message data: ${message.data}');
    }
  });

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    
    // Set up FCM message handlers after app is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupFirebaseMessaging();
    });
  }

  void _setupFirebaseMessaging() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Received foreground message: ${message.messageId}');
      debugPrint('Message data: ${message.data}');
      
      // Refresh notifications when a push notification is received
      // Access NotificationViewModel through navigator context
      final context = navigatorKey.currentContext;
      if (context != null) {
        final notificationViewModel = Provider.of<NotificationViewModel>(context, listen: false);
        notificationViewModel.checkForNewNotifications();
      }
    });

    // Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Notification opened app: ${message.messageId}');
      debugPrint('Message data: ${message.data}');
      
      // Refresh notifications when notification opens app
      final context = navigatorKey.currentContext;
      if (context != null) {
        final notificationViewModel = Provider.of<NotificationViewModel>(context, listen: false);
        notificationViewModel.loadNotifications(forceRefresh: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => LoginViewModel()),
            ChangeNotifierProvider(create: (_) => SignUpViewModel()),
            ChangeNotifierProvider(create: (_) => ForgotPasswordViewModel()),
            // ChangeNotifierProvider(create: (_) => ProfileViewModel()),
            ChangeNotifierProvider(create: (_) => ChatViewModel()),
            ChangeNotifierProvider(create: (_) => SettingsViewModel()),
            ChangeNotifierProvider(create: (_) => JobViewModel()),
            ChangeNotifierProvider(create: (_) => NotificationViewModel()),
            ChangeNotifierProvider(create: (_) => EarningsViewModel()),
          ],
      child: Consumer<SettingsViewModel>(
        builder: (context, settingsViewModel, child) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            title: 'HR Employee App',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settingsViewModel.themeMode,
            initialRoute: AppRouter.initialRoute,
            onGenerateRoute: AppRouter.generateRoute,
            builder: (context, child) {
              // Initialize ScreenUnitUtil at app level with MediaQuery context
              ScreenUnitUtil.init(context);
              return child!;
            },
          );
        },
      ),
    );
  }
}
