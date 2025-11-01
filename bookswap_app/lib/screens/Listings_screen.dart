import 'package:flutter/material.dart';

class ListingsScreen extends StatelessWidget {
  const ListingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Listings')),
      body: Center(
        child: Text('Here you can view the books you have listed for swap.'),
      ),
    );
  }
}
