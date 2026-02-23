import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: navigate to settings
              // context.go('/settings');
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // App title image
              AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text(
                      'App Title Image',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // Buttons
              ElevatedButton(
                onPressed: () {
                  // TODO: button 1 action
                },
                child: const Text('Make A Problem Sheet'),
              ),

              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: () {
                  context.push('/flash-menu');
                },
                child: const Text('Flash Anzan'),
              ),

              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: () {
                  context.push('/paper-menu');
                },
                child: const Text('Train In The App'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  context.push('/aloud-menu');
                },
                child: const Text('Aloud Problem'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
