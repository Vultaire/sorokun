import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:soroban_app/screens/paper_problem_menu.dart';
import 'package:soroban_app/screens/paper_results.dart';
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
        pageBuilder: (context, state) {
          final args = state.extra as Map<String, dynamic>?;

          return blackFadeTransition(
            key: state.pageKey,
            child: PaperProblemScreen(
              selectedLevel: args?['selectedLevel'],
              isExam: args?['isExam'] ?? false,
              time: args?['time'],
              appBarTitle: args?['appBarTitle'],
            ),
          );
        },
      ),
      GoRoute(
        path: '/paper-results',
        pageBuilder: (context, state) {
          final args = state.extra as Map<String, dynamic>?;

          return blackFadeTransition(
            key: state.pageKey,
            child: PaperResultsScreen(
              allAnswers: args?['allAnswers'],
              answerBools: args?['answerBools'],
              textFieldDataList: args?['textFieldDataList'],
              elapsed: args?['elapsed'],
            ),
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

CustomTransitionPage blackFadeTransition({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage(
    key: key,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const double midPoint = 0.5;

      return AnimatedBuilder(
        animation: animation,
        builder: (context, _) {
          if (animation.value < midPoint) {
            return Container(
              color: Colors.black.withValues(alpha: animation.value / midPoint),
            );
          } else {
            double fadeIn = (animation.value - midPoint) / midPoint;
            return Stack(
              children: [
                Container(color: Colors.black),
                Opacity(opacity: fadeIn, child: child),
              ],
            );
          }
        },
      );
    },
    transitionDuration: const Duration(milliseconds: 1000),
    reverseTransitionDuration: const Duration(milliseconds: 1000),
  );
}
