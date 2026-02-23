import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:soroban_app/screens/components/navigation_button.dart';
import 'package:soroban_app/src/voicevox_paths.dart';

class AloudMenuPage extends StatefulWidget {
  const AloudMenuPage({super.key, required this.voicevoxPaths});
  final VoicevoxPaths voicevoxPaths;

  @override
  State<AloudMenuPage> createState() => _AloudMenuPageState();
}

class _AloudMenuPageState extends State<AloudMenuPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: NavigationButton(
        onPressed: () {
          context.go(
            '/aloud-problem',
            extra: {'voicevoxPaths': widget.voicevoxPaths},
          );
        },
        label: Text('スタート', style: Theme.of(context).textTheme.titleLarge),
      ),
    );
  }
}
