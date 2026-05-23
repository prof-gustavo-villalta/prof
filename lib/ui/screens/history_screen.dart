import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/models.dart';
import '../prof_controller.dart';
import '../widgets/shared_ui.dart';
import '../widgets/animated_tap_scale.dart';
import 'attendance_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key, required this.controller});

  final ProfController controller;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String? classGroupId;
  String? disciplineId;

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final selectedClassGroupId =
        classGroupId ?? controller.data.classGroups.firstOrNull?.id;
    final selectedDisciplineId =
        disciplineId ?? controller.data.disciplines.firstOrNull?.id;
    final summaries = controller.summaries(
      classGroupId: selectedClassGroupId,
      disciplineId: selectedDisciplineId,
    );
    final closedAttendances = controller.closedAttendanceViews();
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Histórico', style: Theme.of(context).textTheme.headlineMedium),
            Icon(Icons.insights_rounded, color: Theme.of(context).colorScheme.primary, size: 28),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: selectedClassGroupId,
                dropdownColor: Theme.of(context).colorScheme.surface,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w600),
                decoration: const InputDecoration(
                  labelText: 'Turma',
                  contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
                items: [
                  for (final group in controller.data.classGroups)
                    DropdownMenuItem(value: group.id, child: Text(group.name)),
                ],
                onChanged: (value) => setState(() => classGroupId = value),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: selectedDisciplineId,
                dropdownColor: Theme.of(context).colorScheme.surface,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w600),
                decoration: const InputDecoration(
                  labelText: 'Disciplina',
                  contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
                items: [
                  for (final discipline in controller.data.disciplines)
                    DropdownMenuItem(
                      value: discipline.id,
                      child: Text(discipline.name),
                    ),
                ],
                onChanged: (value) => setState(() => disciplineId = value),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (summaries.isEmpty)
          const EmptyCard(text: 'Nenhuma chamada fechada ainda.')
        else ...[
          SectionCard(
            title: 'Chamadas fechadas',
            children: [
              for (final entry in closedAttendances.indexed) ...[
                if (entry.$1 > 0)
                  const Divider(height: 1),
                AnimatedTapScale(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => AttendanceScreen(
                          controller: controller,
                          lesson: LessonOccurrence(
                            weeklyClass: entry.$2.weeklyClass,
                            date: entry.$2.attendance.date,
                          ),
                          attendanceId: entry.$2.attendance.id,
                        ),
                      ),
                    );
                  },
                  child: ListTile(
                    key: ValueKey('closed_attendance_${entry.$1}'),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    title: Text(
                      '${entry.$2.classGroup.name} - ${entry.$2.discipline.name}',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 15,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        dateText(entry.$2.attendance.date),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    trailing: Icon(
                      Icons.chevron_right_rounded,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                    ),
                    onTap: null, // Handled by AnimatedTapScale parent
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Resumo por aluno',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
          const SizedBox(height: 8),
          for (final summary in summaries)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            summary.student.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${summary.classGroup.name} - ${summary.discipline.name}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              StatBadge(
                                label: 'P',
                                value: summary.present,
                                color: const Color(0xFF10B981),
                              ),
                              StatBadge(
                                label: 'A',
                                value: summary.absent,
                                color: const Color(0xFFEF4444),
                              ),
                              StatBadge(
                                label: 'T',
                                value: summary.late,
                                color: const Color(0xFFF59E0B),
                              ),
                              StatBadge(
                                label: 'J',
                                value: summary.justified,
                                color: const Color(0xFF3B82F6),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Builder(
                      builder: (context) {
                        final rate = summary.presencePercent;
                        final Color rateColor;
                        final Color rateBg;
                        if (rate >= 75) {
                          rateColor = const Color(0xFF10B981);
                          rateBg = const Color(0xFF10B981).withOpacity(0.12);
                        } else if (rate >= 50) {
                          rateColor = const Color(0xFFF59E0B);
                          rateBg = const Color(0xFFF59E0B).withOpacity(0.12);
                        } else {
                          rateColor = const Color(0xFFEF4444);
                          rateBg = const Color(0xFFEF4444).withOpacity(0.12);
                        }
                        return Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: rateBg,
                            borderRadius: BorderRadius.zero,
                            border: Border.all(color: rateColor.withOpacity(0.2), width: 1.5),
                          ),
                          child: Center(
                            child: Text(
                              '${summary.presencePercent}%',
                              style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                fontSize: 14,
                                color: rateColor,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Exportar dados',
            children: [
              Text(
                'Copie os dados em formato CSV para usar em planilhas como Excel ou Google Sheets.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 14),
              AppButton(
                key: const ValueKey('copy_csv'),
                text: 'Copiar CSV',
                icon: Icons.copy_rounded,
                onPressed: () async {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('CSV pronto para copiar', style: TextStyle(color: Theme.of(context).colorScheme.onInverseSurface, fontWeight: FontWeight.w700)),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Theme.of(context).colorScheme.inverseSurface,
                    ),
                  );
                  await Clipboard.setData(
                    ClipboardData(
                      text: controller.csvExport(
                        classGroupId: selectedClassGroupId,
                        disciplineId: selectedDisciplineId,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.04),
                  borderRadius: BorderRadius.zero,
                  border: Border.all(color: Theme.of(context).colorScheme.outlineVariant, width: 1.5),
                ),
                child: SelectableText(
                  controller.csvExport(
                    classGroupId: selectedClassGroupId,
                    disciplineId: selectedDisciplineId,
                  ),
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
