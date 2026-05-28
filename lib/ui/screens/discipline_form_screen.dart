import 'package:flutter/material.dart';
import '../../domain/diario_de_classe.dart';
import '../design_system/app_colors.dart';
import '../design_system/app_sizes.dart';
import '../widgets/shared_ui.dart';
import '../widgets/single_column_screen.dart';

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
    return SingleColumnScreen(
      appBarTitle: 'Nova disciplina',
      title: 'Nova disciplina',
      icon: Icons.menu_book_rounded,
      bottomActionBar: BottomActionBar(
        child: AppButton(
          key: const ValueKey('add_discipline'),
          text: 'Adicionar',
          icon: Icons.check_rounded,
          color: AppColors.primaryAction,
          height: AppSizes.actionHeight,
          onPressed: () {
            if (disciplina.text.trim().isNotEmpty) {
              widget.diario.addDiscipline(disciplina.text);
            }
            Navigator.of(context).pop();
          },
        ),
      ),
      children: [
        Field(
          label: 'Disciplina',
          controller: disciplina,
          keyName: 'new_discipline_name',
        ),
      ],
    );
  }
}
