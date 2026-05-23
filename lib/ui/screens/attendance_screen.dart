import 'dart:convert';
import 'package:flutter/material.dart';
import '../../domain/models.dart';
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
        final attendance = widget.controller.data.attendances.firstWhere(
          (item) => item.id == widget.attendanceId,
        );
        final group = widget.controller.classGroup(widget.lesson.weeklyClass.classGroupId);
        final discipline = widget.controller.discipline(
          widget.lesson.weeklyClass.disciplineId,
        );
        
        final students = widget.controller.studentsForClass(group.id).where((student) {
          final matchesQuery = student.name.toLowerCase().contains(
            studentQuery.trim().toLowerCase(),
          );
          final status =
              attendance.statusByStudentId[student.id] ?? AttendanceStatus.absent;
          final matchesFilter =
              statusFilter == 'Todos' ||
              (statusFilter == 'Presentes' &&
                  status == AttendanceStatus.present) ||
              (statusFilter == 'Ausentes' && status == AttendanceStatus.absent) ||
              (statusFilter == 'Atrasos' && status == AttendanceStatus.late) ||
              (statusFilter == 'Justificados' &&
                  status == AttendanceStatus.justified);
          return matchesQuery && matchesFilter;
        }).toList();

        return Scaffold(
          appBar: AppBar(
            title: Text('${group.name} - ${discipline.name}'),
            actions: [
              if (attendance.isClosed)
                TextButton(
                  onPressed: () => widget.controller.reopenAttendance(attendance),
                  child: const Text('Reabrir'),
                )
              else
                TextButton(
                  key: const ValueKey('close_attendance'),
                  onPressed: () async {
                    await widget.controller.closeAttendance(attendance);
                    if (context.mounted) Navigator.of(context).pop();
                  },
                  child: const Text('Fechar'),
                ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                selectedFilter: statusFilter,
                onSelected: (value) {
                  setState(() {
                    statusFilter = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              for (final student in students)
                StudentAttendanceCard(
                  controller: widget.controller,
                  attendance: attendance,
                  student: student,
                ),
            ],
          ),
        );
      },
    );
  }
}

class StudentAttendanceCard extends StatelessWidget {
  const StudentAttendanceCard({
    super.key,
    required this.controller,
    required this.attendance,
    required this.student,
  });

  final ProfController controller;
  final Attendance attendance;
  final Student student;

  @override
  Widget build(BuildContext context) {
    final status =
        attendance.statusByStudentId[student.id] ?? AttendanceStatus.absent;

    final cardBgColor = Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface;
    final (bgColor, borderColor, accentColor, statusLabel) = switch (status) {
      AttendanceStatus.present => (
          cardBgColor,
          const Color(0xFF10B981).withOpacity(0.4),
          const Color(0xFF10B981),
          'Presente'
        ),
      AttendanceStatus.absent => (
          cardBgColor,
          const Color(0xFFEF4444).withOpacity(0.4),
          const Color(0xFFEF4444),
          'Ausente'
        ),
      AttendanceStatus.late => (
          cardBgColor,
          const Color(0xFFF59E0B).withOpacity(0.4),
          const Color(0xFFF59E0B),
          'Atrasado'
        ),
      AttendanceStatus.justified => (
          cardBgColor,
          const Color(0xFF3B82F6).withOpacity(0.4),
          const Color(0xFF3B82F6),
          'Justificado'
        ),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOutCubic,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.zero,
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            key: ValueKey('student_${student.name}'),
            borderRadius: BorderRadius.zero,
            onTap: () => controller.togglePresence(attendance, student.id),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  _AnimatedCheckbox(
                    isChecked: status == AttendanceStatus.present,
                    status: status,
                    accentColor: accentColor,
                  ),
                  const SizedBox(width: 14),
                  StudentAvatar(student: student),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          statusLabel,
                          style: TextStyle(
                            color: accentColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _QuickActionButton(
                        icon: Icons.hourglass_empty_rounded,
                        isActive: status == AttendanceStatus.late,
                        activeColor: const Color(0xFFF59E0B),
                        activeBg: const Color(0xFFF59E0B).withOpacity(0.15),
                        tooltip: 'Atrasado',
                        onTap: () {
                          if (status == AttendanceStatus.late) {
                            controller.markStudent(
                              attendance,
                              student.id,
                              AttendanceStatus.absent,
                            );
                          } else {
                            controller.markStudent(
                              attendance,
                              student.id,
                              AttendanceStatus.late,
                            );
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      _QuickActionButton(
                        icon: Icons.verified_user_rounded,
                        isActive: status == AttendanceStatus.justified,
                        activeColor: const Color(0xFF3B82F6),
                        activeBg: const Color(0xFF3B82F6).withOpacity(0.15),
                        tooltip: 'Justificado',
                        onTap: () {
                          if (status == AttendanceStatus.justified) {
                            controller.markStudent(
                              attendance,
                              student.id,
                              AttendanceStatus.absent,
                            );
                          } else {
                            controller.markStudent(
                              attendance,
                              student.id,
                              AttendanceStatus.justified,
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedCheckbox extends StatelessWidget {
  const _AnimatedCheckbox({
    required this.isChecked,
    required this.status,
    required this.accentColor,
  });

  final bool isChecked;
  final AttendanceStatus status;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutBack,
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: isChecked ? accentColor : Colors.transparent,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.zero,
        border: Border.all(
          color: isChecked ? accentColor : Theme.of(context).colorScheme.outlineVariant,
          width: 2,
        ),
      ),
      child: Center(
        child: AnimatedScale(
          scale: isChecked ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutBack,
          child: const Icon(
            Icons.check_rounded,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.isActive,
    required this.activeColor,
    required this.activeBg,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final bool isActive;
  final Color activeColor;
  final Color activeBg;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedTapScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOutCubic,
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: isActive ? activeBg : Theme.of(context).colorScheme.onSurface.withOpacity(0.08),
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.zero,
          border: Border.all(
            color: isActive ? activeColor : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Icon(
          icon,
          color: isActive ? activeColor : Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
          size: 18,
        ),
      ),
    );
  }
}
