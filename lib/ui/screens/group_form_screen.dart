import 'package:flutter/material.dart';
import '../../domain/models.dart';
import '../design_system.dart';
import '../../domain/diario_de_classe.dart';
import '../widgets/shared_ui.dart';
import '../widgets/single_column_screen.dart';

class GroupFormScreen extends StatefulWidget {
  const GroupFormScreen({
    super.key,
    required this.diario,
    this.group,
    this.term,
  });

  final DiarioDeClasse diario;
  final ClassGroup? group;
  final Term? term;

  @override
  State<GroupFormScreen> createState() => _GroupFormScreenState();
}

class _GroupFormScreenState extends State<GroupFormScreen> {
  late final TextEditingController groupName;
  late final TextEditingController termName;
  late final TextEditingController startDate;
  late final TextEditingController endDate;

  bool get isEditing => widget.group != null;

  @override
  void initState() {
    super.initState();
    groupName = TextEditingController(text: widget.group?.name ?? '');
    termName = TextEditingController(text: widget.term?.name ?? '2026/1');
    startDate = TextEditingController(
      text: widget.term != null ? dateText(widget.term!.startDate) : '',
    );
    endDate = TextEditingController(
      text: widget.term != null ? dateText(widget.term!.endDate) : '',
    );
  }

  @override
  void dispose() {
    groupName.dispose();
    termName.dispose();
    startDate.dispose();
    endDate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = isEditing ? 'Editar turma' : 'Nova turma';

    return SingleColumnScreen(
      appBarTitle: title,
      title: title,
      icon: isEditing ? Icons.edit_rounded : Icons.group_add_rounded,
      bottomActionBar: BottomSplitActionBar(
        left: AppButton(
          text: 'Cancelar',
          icon: Icons.close_rounded,
          color: AppColors.slate950,
          height: AppSizes.actionHeight,
          onPressed: () => Navigator.of(context).pop(),
        ),
        right: AppButton(
          key: const ValueKey('save_group'),
          text: 'Salvar',
          icon: Icons.check_rounded,
          color: AppColors.primaryAction,
          height: AppSizes.actionHeight,
          onPressed: () async {
            if (isEditing) {
              await widget.diario.updateClassGroup(
                classGroupId: widget.group!.id,
                name: groupName.text,
                termName: termName.text,
                termStartDate: parseDate(startDate.text),
                termEndDate: parseDate(endDate.text),
              );
            } else {
              await widget.diario.addClassGroup(
                turma: groupName.text,
                periodo: termName.text,
                termStartDate: parseDate(startDate.text),
                termEndDate: parseDate(endDate.text),
              );
            }
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      children: [
        SectionCard(
          title: 'Dados da turma',
          children: [
            Field(
              label: 'Turma',
              controller: groupName,
              keyName: 'edit_group_name',
            ),
            Field(
              label: 'Periodo letivo',
              controller: termName,
              keyName: 'edit_term_name',
            ),
            Field(
              label: 'Inicio opcional',
              controller: startDate,
              keyName: 'edit_term_start',
            ),
            Field(
              label: 'Fim opcional',
              controller: endDate,
              keyName: 'edit_term_end',
            ),
          ],
        ),
      ],
    );
  }
}
