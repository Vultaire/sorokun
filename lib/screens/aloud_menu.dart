import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soroban_app/models/level_definitions.dart';
import 'package:soroban_app/screens/components/navigation_button.dart';
import 'package:soroban_app/screens/paper_problem_menu.dart';
import 'package:soroban_app/src/voicevox_paths.dart';

class AloudMenuPage extends StatefulWidget {
  const AloudMenuPage({super.key, required this.voicevoxPaths});
  final VoicevoxPaths voicevoxPaths;

  @override
  State<AloudMenuPage> createState() => _AloudMenuPageState();
}

class _AloudMenuPageState extends State<AloudMenuPage> {
  Kyuui _kyuui = .zsk9;
  KyuuiDenomination _kyuuiDenomination = .zsAloud;
  int _currentIndex = 0;
  late final SharedPreferencesWithCache _prefs;
  @override
  Widget build(BuildContext context) {
    final List<Kyuui> kyuuiList = [
      _kyuuiDenomination.k10,
      _kyuuiDenomination.k9,
      _kyuuiDenomination.k8,
      _kyuuiDenomination.k7,
      _kyuuiDenomination.k6,
      _kyuuiDenomination.k5,
      _kyuuiDenomination.k4,
      _kyuuiDenomination.k3,
      _kyuuiDenomination.k2,
      _kyuuiDenomination.k1,
      _kyuuiDenomination.d1,
      _kyuuiDenomination.d2,
      _kyuuiDenomination.d3,
      _kyuuiDenomination.d4,
      _kyuuiDenomination.d5,
      _kyuuiDenomination.d6,
      _kyuuiDenomination.d7,
      _kyuuiDenomination.d8,
      _kyuuiDenomination.d9,
      _kyuuiDenomination.d10,
    ].whereType<Kyuui>().toList();
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          KyuuiSelector(
            kyuuiList: kyuuiList,
            currentIndex: _currentIndex,
            onChanged: (index, kyuui) {
              setState(() {
                _currentIndex = index;
                _kyuui = kyuui;
              });
            },
          ),
          NavigationButton(
            onPressed: () {
              context.push(
                '/aloud-problem',
                extra: {
                  'voicevoxPaths': widget.voicevoxPaths,
                  'isSingleProblem': false,
                  'selectedLevel': _kyuui.aloud,
                },
              );
            },
            label: Text('スタート', style: Theme.of(context).textTheme.titleLarge),
          ),
        ],
      ),
    );
  }
}
