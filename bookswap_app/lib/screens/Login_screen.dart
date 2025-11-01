import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../widgets/Button.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.transparent,
                ),
                child: Icon(Icons.book, color: AppColors.primary, size: 80),
              ),

              const SizedBox(height: 24),
              Text(
                'BookSwap',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),
              Text(
                'Swap Your Books\nWith Other Students',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),

              const SizedBox(height: 8),
              Text(
                'Sign in to get started',
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),

              const SizedBox(height: 32),
              Button(
                text: 'Sign In',
                type: ButtonType.signIn,
                onPressed: () {
                  print("Sign In clicked");
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
