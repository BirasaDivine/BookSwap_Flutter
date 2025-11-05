import 'package:bookswap_app/providers/auth_provider.dart';
import 'package:bookswap_app/providers/book_provider.dart';
import 'package:bookswap_app/providers/chat_provider.dart';
import 'package:bookswap_app/providers/swap_provider.dart';
import 'package:bookswap_app/screens/auth/login_screen.dart';
import 'package:bookswap_app/screens/auth/verification_screen.dart';
import 'package:bookswap_app/screens/main_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants/colors.dart';

/// Entry point of the BookSwap App
void main() async {
  // Ensure Flutter engine is initialized before any async operations
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Run the main app widget
  runApp(const MyApp());
}

/// The root widget of the BookSwap App
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BookProvider()),
        ChangeNotifierProvider(create: (_) => SwapProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: MaterialApp(
        // Hide the debug banner
        debugShowCheckedModeBanner: false,
        title: 'BookSwap App',
        theme: ThemeData(
          primaryColor: AppColors.primary,
          scaffoldBackgroundColor: Colors.white,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            primary: AppColors.primary,
            secondary: AppColors.yellow,
          ),
          useMaterial3: true,
        ),
        // Use auth state to determine initial route
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            // Not authenticated - show login
            if (!authProvider.isAuthenticated) {
              return const LoginScreen();
            }

            // Authenticated but email not verified - show verification screen
            if (!authProvider.isEmailVerified) {
              return const VerificationScreen();
            }

            // Authenticated and verified - show main app
            return const MainScreen();
          },
        ),
      ),
    );
  }
}
