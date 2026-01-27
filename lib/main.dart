import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:go_router/go_router.dart';
import 'package:soroban_app/models/level_definitions.dart';
import 'package:soroban_app/screens/flash_menu.dart';
import 'package:soroban_app/screens/flash_problem.dart';
import 'package:soroban_app/screens/paper_problem_menu.dart';
import 'package:soroban_app/screens/paper_results.dart';
import 'screens/home_page.dart';
import 'screens/paper_problem.dart';

void main() async {
  await SoLoud.instance.init(
    sampleRate: 44100, // Audio quality
    bufferSize: 256, // Buffer size affects latency
    channels: Channels.stereo,
  );

  runApp(const AbacusApp());
}

class AbacusApp extends StatefulWidget {
  const AbacusApp({super.key});

  @override
  State<AbacusApp> createState() => _AbacusAppState();
}

class DebugMockData {
  static Map<String, dynamic> get paperResultsState {
    final allProblems = [
      '728 / 8',
      '385 / 5',
      '177 / 3',
      '216 / 9',
      '288 / 4',
      '582 / 6',
      '114 / 2',
      '801 / 9',
      '162 / 6',
      '177 / 3',
      '392 / 4',
      '354 / 6',
      '744 / 8',
      '747 / 9',
      '576 / 6',
    ];

    final allAnswers = [
      '91',
      '77',
      '59',
      '24',
      '72',
      '97',
      '57',
      '89',
      '27',
      '59',
      '98',
      '59',
      '93',
      '83',
      '96',
    ];

    // Mix of correct and incorrect answers
    final answerBools = [
      false,
      false,
      false,
      true,
      true,
      true,
      true,
      true,
      true,
      true,
      true,
      true,
      true,
      true,
      true,
      true,
      true,
    ];

    // Generate TextFieldDataList with user's answers
    final textFieldDataList = List.generate(allProblems.length, (index) {
      final data = TextFieldData();
      if (answerBools[index]) {
        // Correct answer
        data.internalString = allAnswers[index];
        data.formatted = allAnswers[index];
      } else {
        // Wrong answer (off by some amount)
        final wrongAnswer = (int.parse(allAnswers[index]) + 5).toString();
        data.internalString = wrongAnswer;
        data.formatted = wrongAnswer;
      }
      data.beforeCaret = data.internalString;
      data.caretPos = data.internalString.length.toDouble();
      return data;
    });

    return {
      'selectedLevel': DivMultLevel.dk8, // or whatever level
      'allProblems': allProblems,
      'allAnswers': allAnswers,
      'answerBools': answerBools,
      'textFieldDataList': textFieldDataList,
      'elapsed': Duration(minutes: 3, seconds: 45),
    };
  }

  // All correct scenario
  static Map<String, dynamic> get paperResultsAllCorrect {
    final allProblems = ['728 / 8', '385 / 5', '177 / 3'];
    final allAnswers = ['91', '77', '59'];
    final answerBools = List.filled(allProblems.length, true);

    final textFieldDataList = List.generate(
      allProblems.length,
      (index) => TextFieldData()
        ..internalString = allAnswers[index]
        ..formatted = allAnswers[index]
        ..beforeCaret = allAnswers[index]
        ..caretPos = allAnswers[index].length.toDouble(),
    );

    return {
      'selectedLevel': DivMultLevel.dk8,
      'allProblems': allProblems,
      'allAnswers': allAnswers,
      'answerBools': answerBools,
      'textFieldDataList': textFieldDataList,
      'elapsed': Duration(minutes: 1, seconds: 30),
    };
  }
}

class _AbacusAppState extends State<AbacusApp> {
  ThemeMode themeMode = ThemeMode.light;

  late final _router = GoRouter(
    initialLocation: kDebugMode ? '/home' : '/home',
    routes: [
      GoRoute(path: '/home', builder: (context, state) => HomePage()),
      GoRoute(
        path: '/flash-menu',
        builder: (context, state) => FlashMenuPage(),
      ),
      GoRoute(
        path: '/flash-problem',
        pageBuilder: (context, state) {
          final args = state.extra as Map<String, dynamic>?;

          return blackFadeTransition(
            key: state.pageKey,
            child: FlashProblemScreen(
              kuchi: args?['kuchi'],
              digits: args?['digits'],
              secondsPerProblem: args?['secondsPerProblem'],
            ),
          );
        },
      ),
      GoRoute(
        path: '/paper-menu',
        builder: (context, state) => PaperMenuPage(),
      ),
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
          final args =
              state.extra as Map<String, dynamic>? ??
              (kDebugMode ? DebugMockData.paperResultsState : {});

          return blackFadeTransition(
            key: state.pageKey,
            child: PaperResultsScreen(
              selectedLevel: args?['selectedLevel'] ?? DivMultLevel.dk8,
              isExam: args?['isExam'] ?? true,
              allAnswers: args?['allAnswers'],
              allProblems: args?['allProblems'],
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
