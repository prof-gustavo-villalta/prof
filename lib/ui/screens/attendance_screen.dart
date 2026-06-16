import 'package:flutter/material.dart';

import '../../domain/models.dart';
import '../../domain/diario_de_classe.dart';
import '../design_system.dart';
import '../widgets/animated_tap_scale.dart';
import '../widgets/bordered_container.dart';
import '../widgets/student_avatar.dart';
import '../widgets/shared_ui.dart';
import '../widgets/single_column_screen.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({
    super.key,
    required this.diario,
    required this.lesson,
    required this.attendanceId,
  });

  final DiarioDeClasse diario;
  final LessonOccurrence lesson;
  final String attendanceId;

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  String statusFilter = 'Todos';
  String studentQuery = '';

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.diario,
      builder: (context, _) {
        final attendance = widget.diario.attendanceById(widget.attendanceId)!;
        final group = widget.diario.classGroup(
          widget.lesson.weeklyClass.classGroupId,
        );
        final discipline = widget.diario.discipline(
          widget.lesson.weeklyClass.disciplineId,
        );

        final students = _filteredStudents(attendance, group.id);

        return SingleColumnScreen(
          appBarTitle: '${group.name} - ${discipline.name}',
          padding: const EdgeInsets.only(
            top: AppSpacing.gutter,
            bottom: AppSpacing.loose,
          ),
          bottomActionBar: BottomActionBar(
            child: attendance.isClosed
                ? AppButton(
                    key: const ValueKey('reopen_attendance'),
                    text: 'Reabrir chamada',
                    color: AppColors.primaryAction,
                    height: AppSizes.actionHeight,
                    onPressed: () => widget.diario.reopenAttendance(attendance),
                  )
                : AppButton(
                    key: const ValueKey('close_attendance'),
                    text: 'Fechar chamada',
                    color: AppColors.primaryAction,
                    height: AppSizes.actionHeight,
                    onPressed: () async {
                      await widget.diario.closeAttendance(attendance);
                      if (context.mounted) Navigator.of(context).pop();
                    },
                  ),
          ),
          children: [
            AppSearchBar(
              hintText: 'Buscar aluno',
              onChanged: (value) {
                setState(() {
                  studentQuery = value;
                });
              },
            ),
            const SizedBox(height: AppSpacing.gutter),
            AppFilterRow(
              filters: const [
                'Todos',
                'Presentes',
                'Ausentes',
                'Atrasos',
                'Justificados',
              ],
              filterColors: {
                'Todos': AppColors.slate500,
                'Presentes': _statusFilterColor(AttendanceStatus.present),
                'Ausentes': _statusFilterColor(AttendanceStatus.absent),
                'Atrasos': _statusFilterColor(AttendanceStatus.late),
                'Justificados': _statusFilterColor(AttendanceStatus.justified),
              },
              selectedFilter: statusFilter,
              onSelected: (value) {
                setState(() {
                  statusFilter = value;
                });
              },
            ),
            const SizedBox(height: AppSpacing.page),
            if (students.isEmpty)
              const EmptyCard(
                text:
                    'Sem alunos com esse filtro. Limpe a busca ou altere o filtro.',
                noSideBorders: true,
              )
            else
              for (final entry in students.indexed)
                StudentAttendanceCard(
                  key: ValueKey('student_card_${entry.$2.id}'),
                  diario: widget.diario,
                  attendance: attendance,
                  student: entry.$2,
                  isLast: entry.$1 == students.length - 1,
                ),
          ],
        );
      },
    );
  }

  List<Student> _filteredStudents(Attendance attendance, String groupId) {
    final query = studentQuery.trim().toLowerCase();
    return widget.diario.studentsForClass(groupId).where((student) {
      final matchesQuery =
          query.isEmpty || student.name.toLowerCase().contains(query);
      final status =
          attendance.statusByStudentId[student.id] ?? AttendanceStatus.absent;
      return matchesQuery && matchesAttendanceFilter(status, statusFilter);
    }).toList();
  }
}

class StudentAttendanceCard extends StatelessWidget {
  const StudentAttendanceCard({
    super.key,
    required this.diario,
    required this.attendance,
    required this.student,
    required this.isLast,
  });

  final DiarioDeClasse diario;
  final Attendance attendance;
  final Student student;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final status =
        attendance.statusByStudentId[student.id] ?? AttendanceStatus.absent;
    final style = resolveAttendanceStatusStyle(status);

    return BorderedContainer(
      isLast: isLast,
      backgroundColor: Theme.of(context).cardTheme.color,
      child: InkWell(
        key: ValueKey('student_${student.name}'),
        onTap: attendance.isClosed
            ? null
            : () => diario.togglePresence(attendance, student.id),
        child: Row(
          children: [
            _AttendanceStatusRail(
              label: style.label.toUpperCase(),
              color: style.accentColor,
            ),
            Expanded(
              flex: 80,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.page,
                  vertical: AppSpacing.gutter,
                ),
                child: Row(
                  children: [
                    Expanded(flex: 20, child: StudentAvatar(student: student)),
                    const SizedBox(width: AppSpacing.xl),
                    Expanded(
                      flex: 30,
                      child: Text(
                        student.name,
                        style: AppTextStyles.titleLarge.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      flex: 30,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _StatusToggleButton(
                            icon: Icons.hourglass_empty_rounded,
                            targetStatus: AttendanceStatus.late,
                            isActive: status == AttendanceStatus.late,
                            onTap: attendance.isClosed
                                ? null
                                : () => diario.markStudent(
                                    attendance,
                                    student.id,
                                    status == AttendanceStatus.late
                                        ? AttendanceStatus.absent
                                        : AttendanceStatus.late,
                                  ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          _StatusToggleButton(
                            icon: Icons.verified_user_rounded,
                            targetStatus: AttendanceStatus.justified,
                            isActive: status == AttendanceStatus.justified,
                            onTap: attendance.isClosed
                                ? null
                                : () => diario.markStudent(
                                    attendance,
                                    student.id,
                                    status == AttendanceStatus.justified
                                        ? AttendanceStatus.absent
                                        : AttendanceStatus.justified,
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttendanceStatusRail extends StatelessWidget {
  const _AttendanceStatusRail({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 20,
      child: Container(
        alignment: Alignment.center,
        color: color,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.badge.copyWith(color: AppColors.white),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusToggleButton extends StatelessWidget {
  const _StatusToggleButton({
    required this.icon,
    required this.targetStatus,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final AttendanceStatus targetStatus;
  final bool isActive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final style = resolveAttendanceStatusStyle(targetStatus);
    final activeBg = style.accentColor.withValues(alpha: 0.15);
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return AnimatedTapScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOutCubic,
        width: AppSizes.compactIconButton,
        height: AppSizes.compactIconButton,
        decoration: BoxDecoration(
          color: isActive ? activeBg : onSurface.withValues(alpha: 0.08),
          shape: BoxShape.rectangle,
          borderRadius: AppBorders.radius,
          border: Border.all(
            color: isActive
                ? style.accentColor
                : onSurface.withValues(alpha: 0.25),
            width: AppSizes.subtleDivider,
          ),
        ),
        child: Icon(
          icon,
          color: isActive
              ? style.accentColor
              : onSurface.withValues(alpha: 0.45),
          size: AppSizes.icon,
        ),
      ),
    );
  }
}

Color _statusFilterColor(AttendanceStatus status) {
  return resolveAttendanceStatusStyle(status).accentColor;
}
