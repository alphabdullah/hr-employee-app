import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/login_viewmodel.dart';
import 'viewmodels/signup_viewmodel.dart';
import 'viewmodels/forgot_password_viewmodel.dart';
import 'viewmodels/profile_viewmodel.dart';
import 'viewmodels/chat_viewmodel.dart';
import 'viewmodels/settings_viewmodel.dart';
import 'viewmodels/job_viewmodel.dart';
import 'viewmodels/notification_viewmodel.dart';
import 'utils/screen_unit_util.dart';
import 'resources/themes/app_theme.dart';
import 'routes/app_router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => LoginViewModel()),
            ChangeNotifierProvider(create: (_) => SignUpViewModel()),
            ChangeNotifierProvider(create: (_) => ForgotPasswordViewModel()),
            ChangeNotifierProvider(create: (_) => ProfileViewModel()),
            ChangeNotifierProvider(create: (_) => ChatViewModel()),
            ChangeNotifierProvider(create: (_) => SettingsViewModel()),
            ChangeNotifierProvider(create: (_) => JobViewModel()),
            ChangeNotifierProvider(create: (_) => NotificationViewModel()),
          ],
      child: Consumer<SettingsViewModel>(
        builder: (context, settingsViewModel, child) {
          return MaterialApp(
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
