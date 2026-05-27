import 'package:flutter/material.dart';
import '../../domain/models.dart';
import '../../domain/diario_de_classe.dart';
import '../design_system/app_colors.dart';
import '../widgets/app_dropdown.dart';
import '../widgets/page_header.dart';
import '../widgets/shared_ui.dart';
import '../widgets/bordered_container.dart';
import '../widgets/animated_tap_scale.dart';
import 'attendance_screen.dart';
import 'export_data_screen.dart';
import 'student_summary_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key, required this.diario});

  final DiarioDeClasse diario;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String? classGroupId;
  String? disciplineId;

  @override
  Widget build(BuildContext context) {
    final selectedClassGroupId =
        classGroupId ?? widget.diario.classGroups.firstOrNull?.id;
    final selectedDisciplineId =
        disciplineId ?? widget.diario.disciplines.firstOrNull?.id;
    final closedAttendances = widget.diario.closedAttendanceViews();
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                children: [
                  const PageHeader(title: 'Histórico', icon: Icons.insights_rounded),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: AppDropdown<String>(
                          value: selectedClassGroupId,
                          label: 'Turma',
                          items: [
                            for (final group in widget.diario.classGroups)
                              DropdownMenuItem(value: group.id, child: Text(group.name)),
                          ],
                          onChanged: (value) => setState(() => classGroupId = value),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: AppDropdown<String>(
                          value: selectedDisciplineId,
                          label: 'Disciplina',
                          items: [
                            for (final discipline in widget.diario.disciplines)
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
                  const SizedBox(height: 24),
                  if (closedAttendances.isEmpty)
                    const EmptyCard(text: 'Nenhuma chamada fechada ainda.', noSideBorders: true)
                  else
                    for (final entry in closedAttendances.indexed)
                      Builder(builder: (context) {
                        final view = entry.$2;
                        final isLast = entry.$1 == closedAttendances.length - 1;
                        
                        return AnimatedTapScale(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => AttendanceScreen(
                                  diario: widget.diario,
                                  lesson: LessonOccurrence(
                                    weeklyClass: view.weeklyClass,
                                    date: view.attendance.date,
                                  ),
                                  attendanceId: view.attendance.id,
                                ),
                              ),
                            );
                          },
                          child: BorderedContainer(
                            isLast: isLast,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${view.classGroup.name} - ${view.discipline.name}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          color: Theme.of(context).colorScheme.onSurface,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        dateText(view.attendance.date),
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                                ),
                              ],
                            ),
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
                      text: 'Resumo',
                      icon: Icons.assessment_rounded,
                      color: AppColors.slate950,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => StudentSummaryScreen(
                              diario: widget.diario,
                              classGroupId: selectedClassGroupId,
                              disciplineId: selectedDisciplineId,
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
                      text: 'Exportar CSV',
                      icon: Icons.import_export_rounded,
                      color: AppColors.primaryAction,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => ExportDataScreen(
                              diario: widget.diario,
                              classGroupId: selectedClassGroupId,
                              disciplineId: selectedDisciplineId,
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
  }
}
