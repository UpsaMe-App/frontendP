import 'package:flutter/material.dart';
import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/main_tabs.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.instance.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AuthService.instance.isLoggedIn,
      builder: (context, loggedIn, _) {
        return MaterialApp(
          title: 'UpsaMe',
          theme: buildAppTheme(),
          debugShowCheckedModeBanner: false,
          home: loggedIn ? const MainTabs() : const LoginScreen(),
        );
      },
    );
  }
}
