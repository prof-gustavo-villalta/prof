import 'package:flutter/material.dart';
import '../../domain/diario_de_classe.dart';
import '../design_system/app_colors.dart';
import '../design_system/app_sizes.dart';
import '../design_system/app_spacing.dart';
import '../design_system/app_text_styles.dart';
import '../widgets/page_header.dart';
import '../widgets/shared_ui.dart';

class AddStudentsScreen extends StatefulWidget {
  const AddStudentsScreen({
    super.key,
    required this.diario,
    required this.groupId,
  });

  final DiarioDeClasse diario;
  final String groupId;

  @override
  State<AddStudentsScreen> createState() => _AddStudentsScreenState();
}

class _AddStudentsScreenState extends State<AddStudentsScreen> {
  final _studentsController = TextEditingController();

  @override
  void dispose() {
    _studentsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adicionar alunos')),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView(
                padding: AppSpacing.pageInsets,
                children: [
                  const PageHeader(
                    title: 'Adicionar alunos',
                    icon: Icons.group_add_rounded,
                  ),
                  const SizedBox(height: AppSpacing.page),
                  Text(
                    'Digite ou cole a lista de alunos abaixo, com um aluno por linha.',
                    style: AppTextStyles.support.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.page),
                  MultilineField(
                    key: const ValueKey('add_students_field'),
                    label: 'Um aluno por linha',
                    controller: _studentsController,
                    minLines: 8,
                    maxLines: 15,
                  ),
                ],
              ),
            ),
            BottomActionBar(
              child: AppButton(
                key: const ValueKey('add_students_button'),
                text: 'Adicionar',
                icon: Icons.check_rounded,
                color: AppColors.primaryAction,
                height: AppSizes.actionHeight,
                onPressed: () {
                  if (_studentsController.text.trim().isEmpty) return;
                  widget.diario.addStudents(
                    widget.groupId,
                    _studentsController.text,
                  );
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
