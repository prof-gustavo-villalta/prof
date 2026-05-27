import 'package:flutter/material.dart';
import '../../domain/models.dart';
import '../design_system/app_colors.dart';
import '../prof_controller.dart';
import '../widgets/animated_tap_scale.dart';
import '../widgets/student_avatar.dart';
import '../widgets/shared_ui.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({
    super.key,
    required this.controller,
    required this.lesson,
    required this.attendanceId,
  });

  final ProfController controller;
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
      listenable: widget.controller,
      builder: (context, _) {
        final attendance = widget.controller.attendanceById(widget.attendanceId)!;
        final group = widget.controller.classGroup(
          widget.lesson.weeklyClass.classGroupId,
        );
        final discipline = widget.controller.discipline(
          widget.lesson.weeklyClass.disciplineId,
        );

        final students = _filteredStudents(attendance, group.id);

        return Scaffold(
          appBar: AppBar(
            title: Text('${group.name} - ${discipline.name}'),
          ),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(top: 16, bottom: 24),
                    children: [
                      AppSearchBar(
                        hintText: 'Buscar aluno',
                        onChanged: (value) {
                          setState(() {
                            studentQuery = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      AppFilterRow(
                        filters: const [
                          'Todos',
                          'Presentes',
                          'Ausentes',
                          'Atrasos',
                          'Justificados',
                        ],
                        filterColors: const {
                          'Todos': AppColors.slate500,
                          'Presentes': AppColors.present,
                          'Ausentes': AppColors.absent,
                          'Atrasos': AppColors.lateColor,
                          'Justificados': AppColors.justified,
                        },
                        selectedFilter: statusFilter,
                        onSelected: (value) {
                          setState(() {
                            statusFilter = value;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      if (students.isEmpty)
                        const EmptyCard(
                          text: 'Nenhum aluno encontrado para este filtro.',
                          noSideBorders: true,
                        )
                      else
                        for (final entry in students.indexed)
                          StudentAttendanceCard(
                            key: ValueKey('student_card_${entry.$2.id}'),
                            controller: widget.controller,
                            attendance: attendance,
                            student: entry.$2,
                            isLast: entry.$1 == students.length - 1,
                          ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 66,
                  child: attendance.isClosed
                      ? AppButton(
                          key: const ValueKey('reopen_attendance'),
                          text: 'Reabrir chamada',
                          color: AppColors.slate900,
                          height: 66,
                          onPressed: () =>
                              widget.controller.reopenAttendance(attendance),
                        )
                      : AppButton(
                          key: const ValueKey('close_attendance'),
                          text: 'Fechar chamada',
                          color: AppColors.primaryAction,
                          height: 66,
                          onPressed: () async {
                            await widget.controller.closeAttendance(attendance);
                            if (context.mounted) Navigator.of(context).pop();
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Student> _filteredStudents(Attendance attendance, String groupId) {
    final query = studentQuery.trim().toLowerCase();
    return widget.controller.studentsForClass(groupId).where((student) {
      final matchesQuery =
          query.isEmpty || student.name.toLowerCase().contains(query);
      final status = attendance.statusByStudentId[student.id] ??
          AttendanceStatus.absent;
      return matchesQuery && matchesAttendanceFilter(status, statusFilter);
    }).toList();
  }
}

class StudentAttendanceCard extends StatelessWidget {
  const StudentAttendanceCard({
    super.key,
    required this.controller,
    required this.attendance,
    required this.student,
    required this.isLast,
  });

  final ProfController controller;
  final Attendance attendance;
  final Student student;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final status =
        attendance.statusByStudentId[student.id] ?? AttendanceStatus.absent;
    final style = resolveAttendanceStatusStyle(status);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOutCubic,
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ??
            Theme.of(context).colorScheme.surface,
        border: Border(
          top: const BorderSide(color: AppColors.slate950, width: 2.0),
          bottom: isLast
              ? const BorderSide(color: AppColors.slate950, width: 2.0)
              : BorderSide.none,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: ValueKey('student_${student.name}'),
          borderRadius: BorderRadius.zero,
          onTap: () => controller.togglePresence(attendance, student.id),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 20,
                  child: Container(
                    color: style.accentColor,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          style.label.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 80,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 20,
                          child: StudentAvatar(student: student),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 30,
                          child: Text(
                                  student.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 18,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface,
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
                                onTap: () => controller.markStudent(
                                  attendance,
                                  student.id,
                                  status == AttendanceStatus.late
                                      ? AttendanceStatus.absent
                                      : AttendanceStatus.late,
                                ),
                              ),
                              const SizedBox(width: 8),
                              _StatusToggleButton(
                                icon: Icons.verified_user_rounded,
                                targetStatus: AttendanceStatus.justified,
                                isActive: status == AttendanceStatus.justified,
                                onTap: () => controller.markStudent(
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
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final style = resolveAttendanceStatusStyle(targetStatus);
    final activeBg = style.accentColor.withValues(alpha: 0.15);

    return AnimatedTapScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOutCubic,
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isActive
              ? activeBg
              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.zero,
          border: Border.all(
            color: isActive ? style.accentColor : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Icon(
          icon,
          color: isActive
              ? style.accentColor
              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
          size: 20,
        ),
      ),
    );
  }
}
