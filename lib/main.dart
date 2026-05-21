import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/services/auth_service.dart';
import 'features/dashboard/screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  final loggedIn = await AuthService.isLoggedIn();
  runApp(BringitRiderApp(loggedIn: loggedIn));
}

class BringitRiderApp extends StatelessWidget {
  final bool loggedIn;
  const BringitRiderApp({super.key, required this.loggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bringit Rider',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: loggedIn ? const DashboardScreen() : const LoginScreen(),
    );
  }
}
