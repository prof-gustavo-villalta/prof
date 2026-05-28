import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/diario_storage.dart';
import 'ui/home_shell.dart';

import 'ui/screens/onboarding_screen.dart';
import 'domain/diario_de_classe.dart';
import 'ui/design_system/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(ProfApp(storage: SharedPreferencesDiarioStorage(prefs)));
}

class ProfApp extends StatefulWidget {
  const ProfApp({super.key, required this.storage, this.now});

  final DiarioStorage storage;
  final DateTime? now;

  @override
  State<ProfApp> createState() => _ProfAppState();
}

class _ProfAppState extends State<ProfApp> {
  late final DiarioDeClasseImpl diario;

  @override
  void initState() {
    super.initState();
    diario = DiarioDeClasseImpl(storage: widget.storage);
    diario.load();
  }

  @override
  void dispose() {
    diario.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prof',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: ListenableBuilder(
        listenable: diario,
        builder: (context, _) {
          if (!diario.isLoaded) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (!diario.hasMinimumSetup) {
            return OnboardingScreen(diario: diario);
          }
          return HomeShell(diario: diario, now: widget.now ?? DateTime.now());
        },
      ),
    );
  }
}
