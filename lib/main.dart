// Modified by Vultaire on 2026-11-02.
// Fork: https://github.com/Vultaire/sorokun
import 'dart:async';

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:go_router/go_router.dart';
import 'package:soroban_app/l10n/generated/app_localizations.dart';
import 'package:soroban_app/models/hands_free_anzan_setup.dart';
import 'package:soroban_app/models/holistic_hands_free_practice.dart';
import 'package:soroban_app/models/level_definitions.dart';
import 'package:soroban_app/screens/components/keypad.dart';
import 'package:soroban_app/screens/credits.dart';
import 'package:soroban_app/screens/flash_free_menu.dart';
import 'package:soroban_app/screens/flash_level_menu.dart';
import 'package:soroban_app/screens/flash_problem.dart';
import 'package:soroban_app/screens/hands_free_anzan_setup.dart';
import 'package:soroban_app/screens/hands_free_anzan_session.dart';
import 'package:soroban_app/screens/holistic_hands_free_practice_setup.dart';
import 'package:soroban_app/screens/paper_menu.dart';
import 'package:soroban_app/screens/paper_results.dart';
import 'package:soroban_app/screens/paper_review.dart';
import 'package:soroban_app/screens/settings.dart';
import 'package:soroban_app/screens/welcome_screen.dart';
import 'screens/home_page.dart';
import 'screens/paper_problem.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appController = AppController();
  await SoLoud.instance.init(
    sampleRate: 44100,
    bufferSize: 256,
    channels: Channels.stereo,
  );
  await appController.ready;

  runApp(AbacusApp(appController: appController));
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
    ];

    // Mix of correct and incorrect answers
    final answerBools = [
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
    initialLocation: _appController.shouldShowWelcomeScreen
        ? '/welcome'
        : '/home',
    redirect: (context, state) {
      if (!_appController.shouldShowWelcomeScreen ||
          state.matchedLocation == '/welcome') {
        return null;
      }

      return Uri(
        path: '/welcome',
        queryParameters: {'continueTo': state.uri.toString()},
      ).toString();
    },
    routes: [
      GoRoute(
        path: '/welcome',
        builder: (context, state) {
          final isReview = state.extra == true;
          final continueTo = state.uri.queryParameters['continueTo'];

          return WelcomeScreen(
            showDoNotShowAgain: !isReview,
            onContinue: (doNotShowAgain) async {
              if (isReview) {
                if (context.mounted) context.pop();
                return;
              }

              await _appController.completeWelcome(
                doNotShowAgain: doNotShowAgain,
              );
              if (context.mounted) {
                context.go(_safeWelcomeDestination(continueTo));
              }
            },
          );
        },
      ),
      GoRoute(
        path: '/home',
        pageBuilder: (context, state) =>
            blackFadeTransition(key: state.pageKey, child: HomePage()),
      ),
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
              isHandsFree: args?['isHandsFree'] as bool? ?? false,
              handsFreeThinkTimeSeconds:
                  args?['handsFreeThinkTimeSeconds'] as int? ?? 5,
              handsFreeAnswerDisplaySeconds:
                  args?['handsFreeAnswerDisplaySeconds'] as int? ?? 5,
            ),
          );
        },
      ),
      GoRoute(
        path: '/paper-menu',
        builder: (context, state) => PaperMenuPage(),
      ),
      GoRoute(
        path: '/hands-free-anzan-setup',
        redirect: (context, state) =>
            state.extra is HandsFreeAnzanSetupRequest ? null : '/home',
        builder: (context, state) {
          final request = state.extra as HandsFreeAnzanSetupRequest;
          return HandsFreeAnzanSetupPage(
            kyuui: request.kyuui,
            denomination: request.denomination,
            onContinue: (configuration) => context.pop(configuration),
          );
        },
      ),
      GoRoute(
        path: '/hands-free-anzan-session',
        redirect: (context, state) =>
            state.extra is HandsFreeAnzanSetupConfig ? null : '/paper-menu',
        builder: (context, state) => HandsFreeAnzanSessionPage(
          config: state.extra as HandsFreeAnzanSetupConfig,
        ),
      ),
      GoRoute(
        path: '/holistic-hands-free-setup',
        builder: (context, state) => const HolisticHandsFreePracticeSetupPage(),
      ),
      GoRoute(
        path: '/holistic-hands-free-handoff',
        redirect: (context, state) =>
            state.extra is HolisticHandsFreePracticeConfig ? null : '/home',
        builder: (context, state) => HolisticHandsFreeHandoffPage(
          config: state.extra as HolisticHandsFreePracticeConfig,
          onBack: () => context.pop(),
        ),
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
      final isDark = brightness == Brightness.dark;

      final baseTheme = isDark
          ? FlexThemeData.dark(
              scheme: _appController.flexScheme,
              swapLegacyOnMaterial3: true,
              // Convenience direct styling properties.
              bottomAppBarElevation: 0.5,
              // Component theme configurations for dark mode.
              subThemesData: const FlexSubThemesData(
                interactionEffects: true,
                blendOnLevel: 20,
                blendOnColors: true,
                useM2StyleDividerInM3: true,
                splashType: FlexSplashType.instantSplash,
                splashTypeAdaptive: FlexSplashType.instantSplash,
                adaptiveElevationShadowsBack: FlexAdaptive.all(),
                adaptiveAppBarScrollUnderOff: FlexAdaptive.all(),
                defaultRadius: 6.0,
                elevatedButtonSchemeColor: SchemeColor.onPrimaryContainer,
                elevatedButtonSecondarySchemeColor:
                    SchemeColor.primaryContainer,
                outlinedButtonSchemeColor: SchemeColor.onSurface,
                outlinedButtonOutlineSchemeColor: SchemeColor.outlineVariant,
                toggleButtonsBorderSchemeColor: SchemeColor.outlineVariant,
                segmentedButtonSchemeColor: SchemeColor.primary,
                segmentedButtonBorderSchemeColor: SchemeColor.outlineVariant,
                switchThumbSchemeColor: SchemeColor.onPrimaryContainer,
                switchAdaptiveCupertinoLike: FlexAdaptive.all(),
                unselectedToggleIsColored: true,
                sliderValueTinted: true,
                sliderTrackHeight: 8,
                inputDecoratorIsDense: true,
                inputDecoratorContentPadding: EdgeInsetsDirectional.fromSTEB(
                  12,
                  12,
                  12,
                  12,
                ),
                inputDecoratorBorderSchemeColor: SchemeColor.primary,
                inputDecoratorBorderType: FlexInputBorderType.outline,
                inputDecoratorRadius: 8.0,
                inputDecoratorBorderWidth: 0.5,
                inputDecoratorFocusedBorderWidth: 2.0,
                fabUseShape: true,
                fabAlwaysCircular: true,
                chipSchemeColor: SchemeColor.secondaryContainer,
                chipSelectedSchemeColor: SchemeColor.primaryContainer,
                chipFontSize: 12,
                chipIconSize: 16,
                chipPadding: EdgeInsetsDirectional.fromSTEB(4, 4, 4, 4),
                cardRadius: 12.0,
                popupMenuRadius: 6.0,
                popupMenuElevation: 4.0,
                alignedDropdown: true,
                tooltipRadius: 6,
                tooltipSchemeColor: SchemeColor.surfaceContainerHigh,
                tooltipOpacity: 0.96,
                dialogBackgroundSchemeColor: SchemeColor.surfaceContainerHigh,
                dialogRadius: 12.0,
                snackBarRadius: 6,
                snackBarElevation: 6,
                snackBarBackgroundSchemeColor: SchemeColor.surfaceContainerLow,
                appBarBackgroundSchemeColor: SchemeColor.surfaceContainerLowest,
                appBarScrolledUnderElevation: 2.5,
                bottomAppBarHeight: 60,
                tabBarIndicatorWeight: 4,
                tabBarIndicatorTopRadius: 4,
                tabBarDividerColor: Color(0x00000000),
                drawerRadius: 0.0,
                drawerElevation: 2.0,
                drawerIndicatorOpacity: 0.5,
                bottomSheetBackgroundColor: SchemeColor.surfaceContainerHigh,
                bottomSheetModalBackgroundColor: SchemeColor.surfaceContainer,
                bottomSheetRadius: 12.0,
                bottomSheetElevation: 4.0,
                bottomSheetModalElevation: 6.0,
                bottomNavigationBarSelectedLabelSchemeColor:
                    SchemeColor.primary,
                bottomNavigationBarMutedUnselectedLabel: true,
                bottomNavigationBarSelectedIconSchemeColor: SchemeColor.primary,
                bottomNavigationBarMutedUnselectedIcon: true,
                bottomNavigationBarBackgroundSchemeColor:
                    SchemeColor.surfaceContainer,
                bottomNavigationBarElevation: 0.0,
                menuRadius: 6.0,
                menuElevation: 4.0,
                menuSchemeColor: SchemeColor.surfaceContainerLowest,
                menuPadding: EdgeInsetsDirectional.fromSTEB(6, 10, 5, 10),
                menuBarRadius: 0.0,
                menuBarElevation: 0.0,
                menuBarShadowColor: Color(0x00000000),
                menuIndicatorBackgroundSchemeColor:
                    SchemeColor.surfaceContainerHigh,
                menuIndicatorRadius: 6.0,
                searchBarElevation: 0.0,
                searchViewElevation: 0.0,
                navigationBarIndicatorSchemeColor:
                    SchemeColor.secondaryContainer,
                navigationBarBackgroundSchemeColor:
                    SchemeColor.surfaceContainer,
                navigationBarElevation: 0.0,
                navigationBarHeight: 72.0,
                navigationRailUseIndicator: true,
                navigationRailIndicatorSchemeColor:
                    SchemeColor.secondaryContainer,
                navigationRailIndicatorOpacity: 1.00,
                navigationRailBackgroundSchemeColor:
                    SchemeColor.surfaceContainer,
              ),
              // ColorScheme seed configuration setup for dark mode.
              keyColors: const FlexKeyColors(
                useSecondary: true,
                useTertiary: true,
                useError: true,
                keepPrimary: true,
                keepSecondary: true,
                keepError: true,
                keepTertiaryContainer: true,
              ),
              tones: FlexSchemeVariant.chroma
                  .tones(Brightness.dark)
                  .higherContrastFixed()
                  .monochromeSurfaces(),
              // Direct ThemeData properties.
              visualDensity: FlexColorScheme.comfortablePlatformDensity,
              materialTapTargetSize: MaterialTapTargetSize.padded,
              cupertinoOverrideTheme: const CupertinoThemeData(
                applyThemeToAll: true,
              ),
              fontFamily: 'mPlus',
            )
          : FlexThemeData.light(
              scheme: _appController.flexScheme,
              swapLegacyOnMaterial3: true,
              // Surface color adjustments.
              lightIsWhite: true,
              // Convenience direct styling properties.
              bottomAppBarElevation: 0.5,
              // Component theme configurations for light mode.
              subThemesData: const FlexSubThemesData(
                interactionEffects: true,
                blendOnLevel: 10,
                useM2StyleDividerInM3: true,
                splashType: FlexSplashType.instantSplash,
                splashTypeAdaptive: FlexSplashType.instantSplash,
                adaptiveElevationShadowsBack: FlexAdaptive.all(),
                adaptiveAppBarScrollUnderOff: FlexAdaptive.all(),
                defaultRadius: 6.0,
                elevatedButtonSchemeColor: SchemeColor.onPrimaryContainer,
                elevatedButtonSecondarySchemeColor:
                    SchemeColor.primaryContainer,
                outlinedButtonSchemeColor: SchemeColor.onSurface,
                outlinedButtonOutlineSchemeColor: SchemeColor.outlineVariant,
                toggleButtonsBorderSchemeColor: SchemeColor.outlineVariant,
                segmentedButtonSchemeColor: SchemeColor.primary,
                segmentedButtonBorderSchemeColor: SchemeColor.outlineVariant,
                switchThumbSchemeColor: SchemeColor.onPrimaryContainer,
                switchAdaptiveCupertinoLike: FlexAdaptive.all(),
                unselectedToggleIsColored: true,
                sliderValueTinted: true,
                sliderTrackHeight: 8,
                inputDecoratorIsDense: true,
                inputDecoratorContentPadding: EdgeInsetsDirectional.fromSTEB(
                  12,
                  12,
                  12,
                  12,
                ),
                inputDecoratorBorderSchemeColor: SchemeColor.primary,
                inputDecoratorBorderType: FlexInputBorderType.outline,
                inputDecoratorRadius: 8.0,
                inputDecoratorBorderWidth: 0.5,
                inputDecoratorFocusedBorderWidth: 2.0,
                fabUseShape: true,
                fabAlwaysCircular: true,
                chipSchemeColor: SchemeColor.secondaryContainer,
                chipSelectedSchemeColor: SchemeColor.primaryContainer,
                chipFontSize: 12,
                chipIconSize: 16,
                chipPadding: EdgeInsetsDirectional.fromSTEB(4, 4, 4, 4),
                cardRadius: 12.0,
                popupMenuRadius: 6.0,
                popupMenuElevation: 4.0,
                alignedDropdown: true,
                tooltipRadius: 6,
                tooltipSchemeColor: SchemeColor.surfaceContainerHigh,
                tooltipOpacity: 0.96,
                dialogBackgroundSchemeColor: SchemeColor.surfaceContainerHigh,
                dialogRadius: 12.0,
                snackBarRadius: 6,
                snackBarElevation: 6,
                snackBarBackgroundSchemeColor: SchemeColor.surfaceContainerLow,
                appBarBackgroundSchemeColor: SchemeColor.surfaceContainerLowest,
                appBarScrolledUnderElevation: 0.5,
                bottomAppBarHeight: 60,
                tabBarIndicatorWeight: 4,
                tabBarIndicatorTopRadius: 4,
                tabBarDividerColor: Color(0x00000000),
                drawerRadius: 0.0,
                drawerElevation: 2.0,
                drawerIndicatorOpacity: 0.5,
                bottomSheetBackgroundColor: SchemeColor.surfaceContainerHigh,
                bottomSheetModalBackgroundColor: SchemeColor.surfaceContainer,
                bottomSheetRadius: 12.0,
                bottomSheetElevation: 4.0,
                bottomSheetModalElevation: 6.0,
                bottomNavigationBarSelectedLabelSchemeColor:
                    SchemeColor.primary,
                bottomNavigationBarMutedUnselectedLabel: true,
                bottomNavigationBarSelectedIconSchemeColor: SchemeColor.primary,
                bottomNavigationBarMutedUnselectedIcon: true,
                bottomNavigationBarBackgroundSchemeColor:
                    SchemeColor.surfaceContainer,
                bottomNavigationBarElevation: 0.0,
                menuRadius: 6.0,
                menuElevation: 4.0,
                menuSchemeColor: SchemeColor.surfaceContainerLowest,
                menuPadding: EdgeInsetsDirectional.fromSTEB(6, 10, 5, 10),
                menuBarRadius: 0.0,
                menuBarElevation: 0.0,
                menuBarShadowColor: Color(0x00000000),
                menuIndicatorBackgroundSchemeColor:
                    SchemeColor.surfaceContainerHigh,
                menuIndicatorRadius: 6.0,
                searchBarElevation: 0.0,
                searchViewElevation: 0.0,
                navigationBarIndicatorSchemeColor:
                    SchemeColor.secondaryContainer,
                navigationBarBackgroundSchemeColor:
                    SchemeColor.surfaceContainer,
                navigationBarElevation: 0.0,
                navigationBarHeight: 72.0,
                navigationRailUseIndicator: true,
                navigationRailIndicatorSchemeColor:
                    SchemeColor.secondaryContainer,
                navigationRailIndicatorOpacity: 1.00,
                navigationRailBackgroundSchemeColor:
                    SchemeColor.surfaceContainer,
              ),
              // ColorScheme seed generation configuration for light mode.
              keyColors: const FlexKeyColors(
                useSecondary: true,
                useTertiary: true,
                useError: true,
                keepPrimary: true,
                keepSecondary: true,
                keepError: true,
                keepTertiaryContainer: true,
              ),
              tones: FlexSchemeVariant.chroma
                  .tones(Brightness.light)
                  .higherContrastFixed()
                  .monochromeSurfaces(),
              // Direct ThemeData properties.
              visualDensity: FlexColorScheme.comfortablePlatformDensity,
              materialTapTargetSize: MaterialTapTargetSize.padded,
              cupertinoOverrideTheme: const CupertinoThemeData(
                applyThemeToAll: true,
              ),
              fontFamily: 'mPlus',
            );

      // Your existing per-widget theme overrides layer on top unchanged.
      return baseTheme.copyWith(
        dialogTheme: DialogThemeData(
          titleTextStyle: TextStyle(
            fontSize: 28,
            color: baseTheme.colorScheme.onSurface,
            fontFamily: 'mPlus',
          ),
          contentTextStyle: TextStyle(
            fontSize: 20,
            color: baseTheme.colorScheme.onSurface,
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
        onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
        locale: _appController.locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        localeResolutionCallback: (locale, supportedLocales) =>
            resolveAppLocale(locale),
        themeMode: _appController.themeMode,
        theme: buildTheme(Brightness.light),
        darkTheme: buildTheme(Brightness.dark),
      ),
    );
  }
}

String _safeWelcomeDestination(String? destination) {
  if (destination == null) return '/home';
  final uri = Uri.tryParse(destination);
  const directEntryRoutes = {
    '/home',
    '/credits',
    '/paper-menu',
    '/flash-level-menu',
    '/flash-free-menu',
    '/holistic-hands-free-setup',
  };
  if (uri == null ||
      uri.hasScheme ||
      uri.hasAuthority ||
      !directEntryRoutes.contains(uri.path)) {
    return '/home';
  }
  return uri.toString();
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
  VoidCallback? onSubmit,
}) async {
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(AppLocalizations.of(context).exitDialogTitle),
      content: Text(AppLocalizations.of(context).exitDialogMessage),
      actionsAlignment: .center,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context).cancel),
        ),
        if (onSubmit != null)
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onSubmit();
            },
            child: Text(AppLocalizations.of(context).submit),
          ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            GoRouter.of(context).pop();
          },
          child: Text(AppLocalizations.of(context).quit),
        ),
      ],
    ),
  );
}
