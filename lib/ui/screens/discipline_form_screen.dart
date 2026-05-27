import 'package:flutter/material.dart';
import '../../domain/diario_de_classe.dart';
import '../design_system/app_colors.dart';
import '../widgets/page_header.dart';
import '../widgets/shared_ui.dart';

class DisciplineFormScreen extends StatefulWidget {
  const DisciplineFormScreen({super.key, required this.diario});

  final DiarioDeClasse diario;

  @override
  State<DisciplineFormScreen> createState() => _DisciplineFormScreenState();
}

class _DisciplineFormScreenState extends State<DisciplineFormScreen> {
  final disciplina = TextEditingController();

  @override
  void dispose() {
    disciplina.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova disciplina')),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                children: [
                  const PageHeader(
                    title: 'Nova disciplina',
                    icon: Icons.menu_book_rounded,
                  ),
                  const SizedBox(height: 28),
                  Field(
                    label: 'Disciplina',
                    controller: disciplina,
                    keyName: 'new_discipline_name',
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 66,
              child: AppButton(
                key: const ValueKey('add_discipline'),
                text: 'Adicionar',
                icon: Icons.check_rounded,
                color: AppColors.primaryAction,
                onPressed: () {
                  if (disciplina.text.trim().isNotEmpty) {
                    widget.diario.addDiscipline(disciplina.text);
                  }
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
