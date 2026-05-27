import 'package:flutter/material.dart';
import '../../domain/models.dart';
import '../design_system/app_colors.dart';
import '../../domain/diario_de_classe.dart';
import '../widgets/animated_tap_scale.dart';
import '../widgets/shared_ui.dart';
import 'attendance_screen.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key, required this.diario, required this.now});

  final DiarioDeClasse diario;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: diario,
      builder: (context, _) {
        final current = diario.getDashboard(now).currentLesson;
        final next = current ?? diario.getDashboard(now).nextLesson;
        final pending = diario.getDashboard(now).pendingLessons;
        final pendingTake10 = pending.take(10).toList();
        final todays = diario.getDashboard(now).todaysLessons;
        final weekdayLabelStr = weekdayLabel(now.weekday);

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
              const EmptyCard(
                text: 'Nenhuma aula encontrada na Grade Semanal.',
                noSideBorders: true,
              )
            else
              LessonHeroCard(
                diario: diario,
                lesson: next,
                isCurrent: current != null,
              ),
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Aulas do dia',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            const SizedBox(height: 12),
            for (final entry in todays.indexed)
              Builder(builder: (context) {
                final lesson = entry.$2;
                final isLast = entry.$1 == todays.length - 1;
                return AnimatedTapScale(
                  onTap: () => _openAttendance(context, lesson),
                  child: LessonTile(
                    diario: diario,
                    lesson: lesson,
                    isLast: isLast,
                  ),
                );
              }),
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Pendentes',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            const SizedBox(height: 12),
            if (pending.isEmpty)
              const EmptyCard(
                text: 'Nenhuma chamada pendente.',
                noSideBorders: true,
              )
            else
              for (final entry in pendingTake10.indexed)
                Builder(builder: (context) {
                  final lesson = entry.$2;
                  final isLast = entry.$1 == pendingTake10.length - 1;
                  return AnimatedTapScale(
                    onTap: () => _openAttendance(context, lesson),
                    child: LessonTile(
                      diario: diario,
                      lesson: lesson,
                      pending: true,
                      isLast: isLast,
                    ),
                  );
                }),
            if (pending.length > 10)
              _MorePendingIndicator(count: pending.length - 10),
          ],
        );
      },
    );
  }

  Future<void> _openAttendance(BuildContext context, LessonOccurrence lesson) async {
    final attendance = await diario.startAttendance(lesson);
    if (!context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AttendanceScreen(
          diario: diario,
          lesson: lesson,
          attendanceId: attendance.id,
        ),
      ),
    );
  }
}

class _MorePendingIndicator extends StatelessWidget {
  const _MorePendingIndicator({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        border: const Border(
          top: BorderSide(color: AppColors.slate950, width: 2.0),
          bottom: BorderSide(color: AppColors.slate950, width: 2.0),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Icon(
            Icons.more_horiz_rounded,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            'Mais $count pendente${count == 1 ? '' : 's'}',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class LessonHeroCard extends StatelessWidget {
  const LessonHeroCard({
    super.key,
    required this.diario,
    required this.lesson,
    required this.isCurrent,
  });

  final DiarioDeClasse diario;
  final LessonOccurrence lesson;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final group = diario.classGroup(lesson.weeklyClass.classGroupId);
    final discipline = diario.discipline(lesson.weeklyClass.disciplineId);
    final accentColor = isCurrent
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.secondary;

    final attendance = diario.attendanceFor(lesson.id);
    final LessonDisplayStatus displayStatus;
    if (isCurrent) {
      if (attendance != null) {
        displayStatus = attendance.isClosed
            ? LessonDisplayStatus.closed
            : LessonDisplayStatus.open;
      } else {
        displayStatus = LessonDisplayStatus.current;
      }
    } else {
      displayStatus = LessonDisplayStatus.next;
    }
    final status = resolveLessonStatus(displayStatus);

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
            child: LessonInfoRow(
              statusLabel: status.label,
              statusColor: status.color,
              title: '${group.name} - ${discipline.name}',
              time: lessonTime(lesson),
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
                    color: AppColors.primaryAction,
                    height: 66,
                    onPressed: () => _openAttendance(context, lesson),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: HoldToConfirmButton(
                    text: 'Cancelar chamada',
                    baseColor: AppColors.cancelBase,
                    fillColor: AppColors.cancelFill,
                    height: 66,
                    onConfirmed: () => diario.cancelLesson(lesson),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openAttendance(BuildContext context, LessonOccurrence lesson) async {
    final attendance = await diario.startAttendance(lesson);
    if (!context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AttendanceScreen(
          diario: diario,
          lesson: lesson,
          attendanceId: attendance.id,
        ),
      ),
    );
  }
}

class LessonTile extends StatelessWidget {
  const LessonTile({
    super.key,
    required this.diario,
    required this.lesson,
    this.pending = false,
    this.isLast = true,
  });

  final DiarioDeClasse diario;
  final LessonOccurrence lesson;
  final bool pending;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final group = diario.classGroup(lesson.weeklyClass.classGroupId);
    final discipline = diario.discipline(lesson.weeklyClass.disciplineId);

    final attendance = diario.attendanceFor(lesson.id);
    final LessonDisplayStatus displayStatus;
    if (pending) {
      displayStatus = LessonDisplayStatus.pending;
    } else if (attendance != null) {
      displayStatus = attendance.isClosed
          ? LessonDisplayStatus.closed
          : LessonDisplayStatus.open;
    } else {
      displayStatus = LessonDisplayStatus.scheduled;
    }
    final status = resolveLessonStatus(displayStatus);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        border: Border(
          top: const BorderSide(color: AppColors.slate950, width: 2.0),
          bottom: isLast
              ? const BorderSide(color: AppColors.slate950, width: 2.0)
              : BorderSide.none,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: LessonInfoRow(
        statusLabel: status.label,
        statusColor: status.color,
        title: '${group.name} - ${discipline.name}',
        time: lessonTime(lesson),
      ),
    );
  }
}
