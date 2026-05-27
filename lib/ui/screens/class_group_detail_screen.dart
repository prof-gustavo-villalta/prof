import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/models.dart';
import '../design_system/app_colors.dart';
import '../../domain/diario_de_classe.dart';
import '../widgets/animated_tap_scale.dart';
import '../widgets/bordered_container.dart';
import '../widgets/shared_ui.dart';
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
  final _studentsController = TextEditingController();

  @override
  void dispose() {
    _studentsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.diario,
      builder: (context, _) {
        final group = widget.diario.classGroup(widget.groupId);
        final term = widget.diario.term(group.termId);
        final students = widget.diario.studentsForClass(widget.groupId);

        return Scaffold(
          appBar: AppBar(
            title: Text('${group.name} | ${term.name}'),
          ),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Alunos',
                          style:
                              Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (students.isEmpty)
                        const EmptyCard(
                          text: 'Nenhum aluno cadastrado.',
                          noSideBorders: true,
                        )
                      else
                        for (final entry in students.indexed)
                          Builder(builder: (context) {
                            final student = entry.$2;
                            final isLast = entry.$1 == students.length - 1;
                            
                            return BorderedContainer(
                              isLast: isLast,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 14,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 20,
                                    child: StudentAvatar(student: student),
                                  ),
                                  Expanded(
                                    flex: 50,
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: Text(
                                        student.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 15,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
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
                                        _ActionIconButton(
                                          icon: Icons.camera_rounded,
                                          onTap: () => _pickPhoto(
                                            context,
                                            widget.diario,
                                            student,
                                            ImageSource.camera,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        _ActionIconButton(
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
                          }),
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
                      ),
                      Container(width: 2, color: AppColors.slate950),
                      Expanded(
                        flex: 50,
                        child: AppButton(
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
                    ],
                  ),
                ),
              ],
            ),
          ),
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
      if (context.mounted) _showSnackBar(context, 'Foto não alterada');
      return;
    }
    final bytes = await image.readAsBytes();
    await diario.saveStudentPhotoBase64(student, base64Encode(bytes));
    if (context.mounted) _showSnackBar(context, 'Foto atualizada');
  }

  void _showSnackBar(BuildContext context, String message) {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: theme.colorScheme.onInverseSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: theme.colorScheme.inverseSurface,
      ),
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  const _ActionIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedTapScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.slate950, width: 2),
        ),
        child: Icon(
          icon,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          size: 18,
        ),
      ),
    );
  }
}
