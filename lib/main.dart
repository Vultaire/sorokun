import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:soroban_app/screens/paper_problem_menu.dart';
import 'screens/home_page.dart';
import 'screens/paper_problem.dart';

void main() {
  runApp(const AbacusApp());
}

class AbacusApp extends StatefulWidget {
  const AbacusApp({super.key});

  @override
  State<AbacusApp> createState() => _AbacusAppState();
}

class _AbacusAppState extends State<AbacusApp> {
  ThemeMode themeMode = ThemeMode.light;

  late final _router = GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(path: '/home', builder: (context, state) => HomePage()),
      GoRoute(path: '/paperconf', builder: (context, state) => PaperConfPage()),
      GoRoute(
        path: '/paper-problem',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>?;
          return PaperProblemScreen(
            selectedLevel: args?['selectedLevel'],
            isExam: args?['isExam'] ?? false,
            time: args?['time'],
            appBarTitle: args?['appBarTitle'],
          );
        },
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      theme: ThemeData(
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
