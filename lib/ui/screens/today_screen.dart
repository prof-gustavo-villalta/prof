import 'package:flutter/material.dart';

import '../../domain/models.dart';
import '../../domain/diario_de_classe.dart';
import '../design_system.dart';
import '../widgets/animated_tap_scale.dart';
import '../widgets/bordered_container.dart';
import '../widgets/shared_ui.dart';
import '../widgets/page_header.dart';
import '../widgets/single_column_screen.dart';
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

        return SingleColumnScreen(
          title: weekdayLabelStr,
          icon: Icons.today_rounded,
          paddingPreset: AppScreenPadding.list,
          spacingAfterHeader: AppSpacing.page,
          children: [
            if (next == null)
              const EmptyCard(
                text:
                    'Nenhuma aula na Grade Semanal agora. Abra a Turma e adicione Horario na Grade Semanal.',
                noSideBorders: true,
              )
            else
              LessonHeroCard(
                diario: diario,
                lesson: next,
                isCurrent: current != null,
              ),
            const SizedBox(height: AppSpacing.section),
            const PageHeader(
              title: 'Aulas do dia',
              icon: Icons.event_note_rounded,
            ),
            const SizedBox(height: AppSpacing.xl),
            for (final entry in todays.indexed)
              Builder(
                builder: (context) {
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
                },
              ),
            const SizedBox(height: AppSpacing.section),
            const PageHeader(
              title: 'Pendentes',
              icon: Icons.pending_actions_rounded,
            ),
            const SizedBox(height: AppSpacing.xl),
            if (pending.isEmpty)
              const EmptyCard(
                text:
                    'Nenhuma Chamada pendente no momento. Toque em uma Aula para iniciar chamada.',
                noSideBorders: true,
              )
            else
              for (final entry in pendingTake10.indexed)
                Builder(
                  builder: (context) {
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
                  },
                ),
            if (pending.length > 10)
              _MorePendingIndicator(count: pending.length - 10),
          ],
        );
      },
    );
  }

  Future<void> _openAttendance(
    BuildContext context,
    LessonOccurrence lesson,
  ) async {
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
    return BorderedContainer(
      sideBorders: true,
      isLast: true,
      backgroundColor: Theme.of(context).cardTheme.color,
      padding: AppSpacing.compactRow,
      child: Row(
        children: [
          Icon(
            Icons.more_horiz_rounded,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.5),
            size: AppSizes.icon,
          ),
          const SizedBox(width: AppSpacing.xl),
          Text(
            'Mais $count pendente${count == 1 ? '' : 's'}',
            style: AppTextStyles.rowMeta.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
      // ui-drift-ok: intentional use of BoxDecoration in this screen style context.
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        border: Border(
          top: BorderSide(color: accentColor, width: AppSizes.accentDivider),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: AppSpacing.card,
            child: LessonInfoRow(
              statusLabel: status.label,
              statusColor: status.color,
              title: '${group.name} - ${discipline.name}',
              time: lessonTime(lesson),
            ),
          ),
          BottomSplitActionBar(
            left: HoldToConfirmButton(
              text: 'Cancelar chamada',
              baseColor: AppColors.cancelBase,
              fillColor: AppColors.cancelFill,
              height: AppSizes.actionHeight,
              onConfirmed: () => diario.cancelLesson(lesson),
            ),
            right: AppButton(
              key: const ValueKey('start_attendance'),
              text: 'Iniciar chamada',
              color: AppColors.primaryAction,
              height: AppSizes.actionHeight,
              onPressed: () => _openAttendance(context, lesson),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openAttendance(
    BuildContext context,
    LessonOccurrence lesson,
  ) async {
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

    return BorderedContainer(
      isLast: isLast,
      backgroundColor: Theme.of(context).cardTheme.color,
      padding: AppSpacing.row,
      child: LessonInfoRow(
        statusLabel: status.label,
        statusColor: status.color,
        title: '${group.name} - ${discipline.name}',
        time: lessonTime(lesson),
      ),
    );
  }
}
