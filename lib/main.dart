import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// Root widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Main Menu Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MainMenu(),
    );
  }
}

// Main menu page
class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  // Helper to create menu buttons
  Widget _buildMenuButton(BuildContext context, String title, Widget page) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 100),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
        child: Text(title),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Main Menu')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildMenuButton(
              context,
              'Page 1',
              const SimplePage(title: 'Page 1'),
            ),
            _buildMenuButton(
              context,
              'Page 2',
              const SimplePage(title: 'Page 2'),
            ),
            _buildMenuButton(
              context,
              'Page 3',
              const SimplePage(title: 'Page 3'),
            ),
            _buildMenuButton(
              context,
              'Page 4',
              const SimplePage(title: 'Page 4'),
            ),
            _buildMenuButton(
              context,
              'Page 5',
              const SimplePage(title: 'Page 5'),
            ),
            _buildMenuButton(
              context,
              'Page 6',
              const SimplePage(title: 'Page 6'),
            ),
          ],
        ),
      ),
    );
  }
}

// Simple placeholder page
class SimplePage extends StatelessWidget {
  final String title;

  const SimplePage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text('Welcome to $title!', style: const TextStyle(fontSize: 24)),
      ),
    );
  }
}
