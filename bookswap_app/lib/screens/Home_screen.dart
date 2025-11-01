import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Browse Listings')),
      body: Center(
        child: Text('Here you can browse books available for swap.'),
      ),
    );
  }
}
