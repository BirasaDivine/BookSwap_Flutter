import 'package:bookswap_app/screens/Chats_screen.dart';
import 'package:bookswap_app/screens/Listings_screen.dart';
import 'package:bookswap_app/screens/Login_screen.dart';
import 'package:bookswap_app/screens/home_screen.dart';
import 'package:bookswap_app/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import '../constants/colors.dart';

/// Entry point of the Study Planner App
void main() async {
  // Ensure Flutter engine is initialized before any async operations
  WidgetsFlutterBinding.ensureInitialized();

  // Run the main app widget
  runApp(const MyApp());
}

/// The root widget of the Study Planner App
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Hide the debug banner
      debugShowCheckedModeBanner: false,
      title: 'Study Planner App',
      theme: ThemeData(cardColor: AppColors.primary),
      // The default landing screen
      home: const LoginScreen(),
      // Named routes for navigation
      routes: {
        '/home': (ctx) => const HomeScreen(),
        '/listings': (ctx) => const ListingsScreen(),
        '/chats': (ctx) => const ChatsScreen(),
        '/settings': (ctx) => const SettingsScreen(),
      },
    );
  }
}
