import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/camera_permission_screen.dart';
import 'screens/home_screen.dart';
import 'screens/camera_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const ChromaLensApp());
}

class ChromaLensApp extends StatelessWidget {
  const ChromaLensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChromaLens',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/permissions': (context) => const CameraPermissionScreen(),
        '/home': (context) => const HomeScreen(),
        '/camera': (context) => const CameraScreen(),
        '/signin': (context) => const SignInScreen(),
      },
    );
  }
}

// Placeholder Sign In Screen
class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: const Text('Sign In'),
      ),
      body: const Center(
        child: Text(
          'Sign In Screen',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
    );
  }
}
