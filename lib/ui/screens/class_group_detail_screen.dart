import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/diario_de_classe.dart';
import '../../domain/models.dart';
import '../design_system/app_colors.dart';
import '../design_system/app_spacing.dart';
import '../design_system/app_text_styles.dart';
import '../widgets/bordered_container.dart';
import '../widgets/shared_ui.dart';
import '../widgets/single_column_screen.dart';
import '../widgets/student_avatar.dart';
import 'add_students_screen.dart';
import 'class_group_schedule_screen.dart';

class ClassGroupDetailScreen extends StatefulWidget {
  const ClassGroupDetailScreen({
    super.key,
    required this.diario,
    required this.groupId,
  });

  final DiarioDeClasse diario;
  final String groupId;

  @override
  State<ClassGroupDetailScreen> createState() => _ClassGroupDetailScreenState();
}

class _ClassGroupDetailScreenState extends State<ClassGroupDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.diario,
      builder: (context, _) {
        final group = widget.diario.classGroup(widget.groupId);
        final term = widget.diario.term(group.termId);
        final students = widget.diario.studentsForClass(widget.groupId);

        return SingleColumnScreen(
          appBarTitle: '${group.name} | ${term.name}',
          title: 'Alunos',
          icon: Icons.groups_rounded,
          paddingPreset: AppScreenPadding.list,
          spacingAfterHeader: AppSpacing.xl,
          bottomActionBar: BottomSplitActionBar(
            left: AppButton(
              text: 'Grade',
              icon: Icons.calendar_month_rounded,
              color: AppColors.slate950,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ClassGroupScheduleScreen(
                      diario: widget.diario,
                      groupId: widget.groupId,
                    ),
                  ),
                );
              },
            ),
            right: AppButton(
              text: 'Adicionar',
              icon: Icons.person_add_rounded,
              color: AppColors.primaryAction,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => AddStudentsScreen(
                      diario: widget.diario,
                      groupId: widget.groupId,
                    ),
                  ),
                );
              },
            ),
          ),
          children: [
            if (students.isEmpty)
              const EmptyCard(
                text: 'Nenhum aluno cadastrado.',
                noSideBorders: true,
              )
            else
              for (final entry in students.indexed)
                Builder(
                  builder: (context) {
                    final student = entry.$2;
                    final isLast = entry.$1 == students.length - 1;

                    return BorderedContainer(
                      isLast: isLast,
                      padding: AppSpacing.compactRow,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 20,
                            child: StudentAvatar(student: student),
                          ),
                          Expanded(
                            flex: 50,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                right: AppSpacing.md,
                              ),
                              child: Text(
                                student.name,
                                style: AppTextStyles.rowTitle.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 30,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                AppIconButton(
                                  icon: Icons.camera_rounded,
                                  onTap: () => _pickPhoto(
                                    context,
                                    widget.diario,
                                    student,
                                    ImageSource.camera,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                AppIconButton(
                                  icon: Icons.add_photo_alternate_rounded,
                                  onTap: () => _pickPhoto(
                                    context,
                                    widget.diario,
                                    student,
                                    ImageSource.gallery,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
          ],
        );
      },
    );
  }

  Future<void> _pickPhoto(
    BuildContext context,
    DiarioDeClasse diario,
    Student student,
    ImageSource source,
  ) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: source, maxWidth: 1024);
    if (image == null) {
      if (context.mounted) showAppSnackBar(context, 'Foto não alterada');
      return;
    }
    final bytes = await image.readAsBytes();
    await diario.saveStudentPhotoBase64(student, base64Encode(bytes));
    if (context.mounted) showAppSnackBar(context, 'Foto atualizada');
  }
}
