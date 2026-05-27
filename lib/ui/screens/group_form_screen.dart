import 'package:flutter/material.dart';
import '../../domain/models.dart';
import '../design_system/app_colors.dart';
import '../prof_controller.dart';
import '../widgets/page_header.dart';
import '../widgets/shared_ui.dart';

class GroupFormScreen extends StatefulWidget {
  const GroupFormScreen({
    super.key,
    required this.controller,
    this.group,
    this.term,
  });

  final ProfController controller;
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
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar turma' : 'Nova turma'),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                children: [
                  PageHeader(
                    title: isEditing ? 'Editar turma' : 'Nova turma',
                    icon: isEditing ? Icons.edit_rounded : Icons.group_add_rounded,
                  ),
                  const SizedBox(height: 28),
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
            ),
            SizedBox(
              height: 66,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 50,
                    child: AppButton(
                      text: 'Cancelar',
                      icon: Icons.close_rounded,
                      color: AppColors.slate950,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  Container(width: 2, color: AppColors.slate950),
                  Expanded(
                    flex: 50,
                    child: AppButton(
                      key: const ValueKey('save_group'),
                      text: 'Salvar',
                      icon: Icons.check_rounded,
                      color: AppColors.primaryAction,
                      onPressed: () async {
                        if (isEditing) {
                          await widget.controller.updateClassGroup(
                            classGroupId: widget.group!.id,
                            name: groupName.text,
                            termName: termName.text,
                            termStartDate: parseDate(startDate.text),
                            termEndDate: parseDate(endDate.text),
                          );
                        } else {
                          widget.controller.addClassGroup(
                            turma: groupName.text,
                            periodo: termName.text,
                          );
                        }
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
