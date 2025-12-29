import 'package:flutter/material.dart';
import 'services/database_service.dart';
import 'screens/splash_screen.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize database with better error handling
  try {
    print('🔄 Initializing database...');
    await DatabaseService().init().timeout(
      const Duration(seconds: 15),
      onTimeout: () {
        print('⚠️ Database initialization timeout - continuing anyway');
      },
    );
    print('✅ Database initialization complete');
  } catch (e, stackTrace) {
    // Log error but continue - app can work without pre-loaded data
    print('⚠️ Database initialization error: $e');
    print('Stack trace: $stackTrace');
  }
  
  runApp(const FishCareSaaSApp());
}

class FishCareSaaSApp extends StatelessWidget {
  const FishCareSaaSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fish Care - Solution of Fish Medicine',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
