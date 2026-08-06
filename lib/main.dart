import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:go_router/go_router.dart';
import 'package:soroban_app/models/level_definitions.dart';
import 'package:soroban_app/models/singer_config.dart';
import 'package:soroban_app/screens/aloud_free_menu.dart';
import 'package:soroban_app/screens/aloud_level_menu.dart';
import 'package:soroban_app/screens/aloud_problem.dart';
import 'package:soroban_app/screens/components/keypad.dart';
import 'package:soroban_app/screens/credits.dart';
import 'package:soroban_app/screens/flash_free_menu.dart';
import 'package:soroban_app/screens/flash_level_menu.dart';
import 'package:soroban_app/screens/flash_problem.dart';
import 'package:soroban_app/screens/paper_menu.dart';
import 'package:soroban_app/screens/paper_results.dart';
import 'package:soroban_app/screens/paper_review.dart';
import 'package:soroban_app/screens/settings.dart';
import 'package:soroban_app/src/voicevox_paths.dart';
import 'screens/home_page.dart';
import 'screens/paper_problem.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  VoicevoxService.paths = await extractVoicevoxAssets();
  final appController = AppController();
  await SoLoud.instance.init(
    sampleRate: 44100,
    bufferSize: 256,
    channels: Channels.stereo,
  );
  await appController.ready;

  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      color: Colors.red,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            details.exceptionAsString(),
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      ),
    );
  };
  runZonedGuarded(
    () {
      runApp(AbacusApp(appController: appController));
    },
    (error, stack) {
      debugPrint('UNCAUGHT: $error\n$stack');
    },
  );
}

class VoicevoxService {
  VoicevoxService._();
  static late VoicevoxPaths paths;
}

class AbacusApp extends StatefulWidget {
  const AbacusApp({super.key, required this.appController});
  final AppController appController;

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
      '288 / 4',
      '288 / 4',
      '288 / 4',
      '288 / 4',
      '288 / 4',
      '288 / 4',
      '288 / 4',
      '288 / 4',
      '288 / 4',
      '288 / 4',
      '288 / 4',
      '288 / 4',
      '288 / 4',
      '288 / 4',
      '288 / 4',
      '288 / 4',
      '288 / 4',
      '288 / 4',
      '288 / 4',
      '288 / 4',
      '288 / 4',
      '288 / 4',
      '288 / 4',
      '288 / 4',
      '288 / 4',
    ];

    final allAnswers = [
      '91',
      '77',
      '59',
      '24',
      '96',
      '96',
      '96',
      '96',
      '96',
      '96',
      '96',
      '96',
      '96',
      '96',
      '96',
      '96',
      '96',
      '96',
      '96',
      '96',
      '96',
      '96',
      '96',
      '96',
      '96',
      '96',
      '96',
      '96',
      '96',
      '96',
    ];

    // Mix of correct and incorrect answers
    final answerBools = [
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
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
      'selectedLevel': DivMultLevel.nsdk3,
      'allProblems': allProblems,
      'allAnswers': allAnswers,
      'textFieldDataList': textFieldDataList,
      'character': Character.shikokuMetan,
      'elapsed': Duration(minutes: 1, seconds: 30),
    };
  }

  // All correct scenario
  static Map<String, dynamic> get paperResultsAllCorrect {
    final allProblems = ['728 / 8', '385 / 5', '177 / 3'];
    final allAnswers = ['91', '77', '59'];

    final textFieldDataList = List.generate(
      allProblems.length,
      (index) => TextFieldData()
        ..internalString = allAnswers[index]
        ..formatted = allAnswers[index]
        ..beforeCaret = allAnswers[index]
        ..caretPos = allAnswers[index].length.toDouble(),
    );

    return {
      'selectedLevel': DivMultLevel.zsdk8,
      'allProblems': allProblems,
      'allAnswers': allAnswers,
      'textFieldDataList': textFieldDataList,
      'elapsed': Duration(minutes: 1, seconds: 30),
    };
  }
}

class _AbacusAppState extends State<AbacusApp> {
  late final AppController _appController = widget.appController;
  late final _router = GoRouter(
    initialLocation: kDebugMode ? '/paper-results' : '/home',
    routes: [
      GoRoute(path: '/home', builder: (context, state) => HomePage()),
      GoRoute(path: '/credits', builder: (context, state) => CreditsPage()),
      GoRoute(
        path: '/flash-level-menu',
        builder: (context, state) => FlashLevelMenuPage(),
      ),
      GoRoute(
        path: '/flash-free-menu',
        builder: (context, state) => FlashFreeMenuPage(),
      ),
      GoRoute(
        path: '/flash-problem',
        pageBuilder: (context, state) {
          final args = state.extra as Map<String, dynamic>?;

          return blackFadeTransition(
            key: state.pageKey,
            child: FlashProblemScreen(
              isSingleProblem: args?['isSingleProblem'],
              selectedLevel: args?['selectedLevel'],
              examDisplayString: args?['examDisplayString'],
            ),
          );
        },
      ),
      GoRoute(
        path: '/paper-menu',
        builder: (context, state) => PaperMenuPage(),
      ),
      GoRoute(
        path: '/paper-review',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>?;

          return PaperReviewScreen(
            selectedLevel: args?['selectedLevel'],
            problemScorerList: args?['problemScorerList'],
          );
        },
      ),
      GoRoute(
        path: '/aloud-level-menu',
        builder: (context, state) => AloudLevelMenuPage(),
      ),
      GoRoute(
        path: '/aloud-free-menu',
        builder: (context, state) => AloudFreeMenuPage(),
      ),
      GoRoute(
        path: '/aloud-problem',
        pageBuilder: (context, state) {
          final args = state.extra as Map<String, dynamic>?;

          return blackFadeTransition(
            key: state.pageKey,
            child: AloudProblemScreen(
              isSingleProblem: args?['isSingleProblem'],
              selectedLevel: args?['selectedLevel'],
              examDisplayString: args?['examDisplayString'],
              character: args?['character'],
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
            child: ResultsScreen(
              selectedLevel: args['selectedLevel'] ?? DivMultLevel.zsdk8,
              isExam: args['isExam'] ?? true,
              examDisplayString: args['examDisplayString'],
              allAnswers: args['allAnswers'],
              allProblems: args['allProblems'],
              textFieldDataList: args['textFieldDataList'],
              elapsed: args['elapsed'],
              character: args['character'],
            ),
          );
        },
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
              examDisplayString: args?['examDisplayString'],
            ),
          );
        },
      ),
    ],
  );

  @override
  void initState() {
    super.initState();
    _appController.addListener(_onThemeChanged);
  }

  void _onThemeChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _appController.removeListener(_onThemeChanged);
    _appController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData buildTheme(Brightness brightness) {
      final colorScheme = ColorScheme.fromSeed(
        seedColor: _appController.seedColor,
        brightness: brightness,
        dynamicSchemeVariant: DynamicSchemeVariant.tonalSpot,
      );

      return ThemeData(
        fontFamily: 'mPlus',
        colorScheme: colorScheme,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
        ),
        dialogTheme: DialogThemeData(
          titleTextStyle: TextStyle(
            fontSize: 28,
            color: colorScheme.onSurface,
            fontFamily: 'mPlus',
          ),
          contentTextStyle: TextStyle(
            fontSize: 20,
            color: colorScheme.onSurface,
            fontFamily: 'mPlus',
          ),
          alignment: Alignment.center,
        ),
      );
    }

    return InheritedAppController(
      controller: _appController,
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: _router,
        themeMode: _appController.themeMode,
        theme: buildTheme(Brightness.light),
        darkTheme: buildTheme(Brightness.dark),
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
      final animValue = animation.value;

      double blackOpacity;
      double childOpacity;

      if (animValue < midPoint) {
        blackOpacity = animValue / midPoint;
        childOpacity = 0.0;
      } else {
        blackOpacity = 1.0;
        childOpacity = (animValue - midPoint) / midPoint;
      }

      final int blackAlpha = (blackOpacity * 255).round();

      return Stack(
        children: [
          Container(color: Colors.black.withAlpha(blackAlpha)),
          Opacity(opacity: childOpacity, child: child),
        ],
      );
    },
    transitionDuration: const Duration(milliseconds: 1000),
    reverseTransitionDuration: const Duration(milliseconds: 1000),
  );
}

Future<void> showExitDialog(
  BuildContext context, {
  required String homeRoute,
  VoidCallback? onSubmit,
}) async {
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('終了しますか？'),
      content: const Text('提出するか、途中でやめるか選んでください。'),
      actionsAlignment: .center,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('キャンセル'),
        ),
        if (onSubmit != null)
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onSubmit();
            },
            child: const Text('提出'),
          ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            GoRouter.of(context).go(homeRoute);
          },
          child: const Text('やめる'),
        ),
      ],
    ),
  );
}
