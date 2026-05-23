import 'package:flutter/material.dart';
import '../../domain/models.dart';
import '../prof_controller.dart';
import '../widgets/animated_tap_scale.dart';
import '../widgets/shared_ui.dart';
import 'attendance_screen.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key, required this.controller});

  final ProfController controller;

  @override
  Widget build(BuildContext context) {
    final current = controller.currentLesson();
    final next = current ?? controller.nextLesson();
    final pending = controller.pendingLessons();
    final pendingTake10 = pending.take(10).toList();
    final todays = controller.todaysLessons();
    final weekdayLabelStr = weekdayLabel(DateTime.now().weekday);
    
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 24),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            weekdayLabelStr,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        const SizedBox(height: 20),
        if (next == null)
          const EmptyCard(text: 'Nenhuma aula encontrada na Grade Semanal.', noSideBorders: true)
        else
          LessonHeroCard(
            controller: controller,
            lesson: next,
            isCurrent: current != null,
          ),
        const SizedBox(height: 28),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text('Aulas do dia', style: Theme.of(context).textTheme.headlineMedium),
        ),
        const SizedBox(height: 12),
        for (final entry in todays.indexed)
          AnimatedTapScale(
            onTap: () async {
              final attendance = await controller.startAttendance(entry.$2);
              if (!context.mounted) return;
              await Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => AttendanceScreen(
                    controller: controller,
                    lesson: entry.$2,
                    attendanceId: attendance.id,
                  ),
                ),
              );
            },
            child: LessonTile(
              controller: controller,
              lesson: entry.$2,
              isLast: entry.$1 == todays.length - 1,
            ),
          ),
        const SizedBox(height: 28),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text('Pendentes', style: Theme.of(context).textTheme.headlineMedium),
        ),
        const SizedBox(height: 12),
        if (pending.isEmpty)
          const EmptyCard(text: 'Nenhuma chamada pendente.', noSideBorders: true)
        else
          for (final entry in pendingTake10.indexed)
            AnimatedTapScale(
              onTap: () async {
                final attendance = await controller.startAttendance(entry.$2);
                if (!context.mounted) return;
                await Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => AttendanceScreen(
                      controller: controller,
                      lesson: entry.$2,
                      attendanceId: attendance.id,
                    ),
                  ),
                );
              },
              child: LessonTile(
                controller: controller,
                lesson: entry.$2,
                pending: true,
                isLast: entry.$1 == pendingTake10.length - 1,
              ),
            ),
      ],
    );
  }
}

class LessonHeroCard extends StatelessWidget {
  const LessonHeroCard({
    super.key,
    required this.controller,
    required this.lesson,
    required this.isCurrent,
  });

  final ProfController controller;
  final LessonOccurrence lesson;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final group = controller.classGroup(lesson.weeklyClass.classGroupId);
    final discipline = controller.discipline(lesson.weeklyClass.disciplineId);
    final accentColor = isCurrent ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.secondary;

    final attendance = controller.attendanceFor(lesson.id);
    final String statusLabel;
    final Color statusColor;

    if (isCurrent) {
      if (attendance != null) {
        if (attendance.isClosed) {
          statusLabel = 'Fechada';
          statusColor = const Color(0xFF10B981);
        } else {
          statusLabel = 'Aberta';
          statusColor = const Color(0xFF2563EB);
        }
      } else {
        statusLabel = 'Atual';
        statusColor = const Color(0xFFEF4444);
      }
    } else {
      statusLabel = 'Próxima';
      statusColor = const Color(0xFF2563EB);
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        border: Border(
          top: BorderSide(color: accentColor, width: 2.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              children: [
                // 1. Status (20%)
                Expanded(
                  flex: 20,
                  child: Text(
                    statusLabel.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                // 2. Titulo principal (50%)
                Expanded(
                  flex: 50,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      '${group.name} - ${discipline.name}',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                // 3. Horario (30%)
                Expanded(
                  flex: 30,
                  child: Text(
                    lessonTime(lesson),
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
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
                  flex: 2,
                  child: AppButton(
                    key: const ValueKey('start_attendance'),
                    text: 'Iniciar chamada',
                    color: const Color(0xFF1E40AF), // Azul escuro
                    height: 66,
                    onPressed: () async {
                      final attendance = await controller.startAttendance(lesson);
                      if (!context.mounted) return;
                      await Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => AttendanceScreen(
                            controller: controller,
                            lesson: lesson,
                            attendanceId: attendance.id,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: HoldToConfirmButton(
                    text: 'Cancelar chamada',
                    baseColor: const Color(0xFF2C1616),
                    fillColor: const Color(0xFFB91C1C),
                    height: 66,
                    onConfirmed: () => controller.cancelLesson(lesson),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LessonTile extends StatelessWidget {
  const LessonTile({
    super.key,
    required this.controller,
    required this.lesson,
    this.pending = false,
    this.isLast = true,
  });

  final ProfController controller;
  final LessonOccurrence lesson;
  final bool pending;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final group = controller.classGroup(lesson.weeklyClass.classGroupId);
    final discipline = controller.discipline(lesson.weeklyClass.disciplineId);

    final attendance = controller.attendanceFor(lesson.id);
    final String statusLabel;
    final Color statusColor;

    if (pending) {
      statusLabel = 'Pendente';
      statusColor = const Color(0xFFEF4444);
    } else if (attendance != null) {
      if (attendance.isClosed) {
        statusLabel = 'Fechada';
        statusColor = const Color(0xFF10B981);
      } else {
        statusLabel = 'Aberta';
        statusColor = const Color(0xFF2563EB);
      }
    } else {
      statusLabel = 'Agendada';
      statusColor = const Color(0xFF64748B);
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        border: Border(
          top: const BorderSide(color: Color(0xFF0F172A), width: 2.0),
          bottom: isLast
              ? const BorderSide(color: Color(0xFF0F172A), width: 2.0)
              : BorderSide.none,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Row(
        children: [
          // 1. Status (20%)
          Expanded(
            flex: 20,
            child: Text(
              statusLabel.toUpperCase(),
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.w900,
                fontSize: 13,
                letterSpacing: 0.5,
              ),
            ),
          ),
          // 2. Titulo principal (50%)
          Expanded(
            flex: 50,
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                '${group.name} - ${discipline.name}',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          // 3. Horario (30%)
          Expanded(
            flex: 30,
            child: Text(
              lessonTime(lesson),
              textAlign: TextAlign.right,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
