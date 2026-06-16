import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import '../../domain/diario_de_classe.dart';
import '../design_system.dart';
import '../widgets/app_dropdown.dart';
import '../widgets/shared_ui.dart';
import '../widgets/single_column_screen.dart';

class ExportDataScreen extends StatefulWidget {
  const ExportDataScreen({
    super.key,
    required this.diario,
    this.classGroupId,
    this.disciplineId,
  });

  final DiarioDeClasse diario;
  final String? classGroupId;
  final String? disciplineId;

  @override
  State<ExportDataScreen> createState() => _ExportDataScreenState();
}

class _ExportDataScreenState extends State<ExportDataScreen> {
  late String? _classGroupId;
  late String? _disciplineId;

  @override
  void initState() {
    super.initState();
    _classGroupId =
        widget.classGroupId ??
        (widget.diario.classGroups.isNotEmpty
            ? widget.diario.classGroups.first.id
            : null);
    _disciplineId =
        widget.disciplineId ??
        (widget.diario.disciplines.isNotEmpty
            ? widget.diario.disciplines.first.id
            : null);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.diario,
      builder: (context, _) {
        final csvData = widget.diario.csvExport(
          classGroupId: _classGroupId,
          disciplineId: _disciplineId,
        );

        return SingleColumnScreen(
          appBarTitle: 'Exportar dados',
          title: 'Exportar CSV',
          icon: Icons.import_export_rounded,
          bottomActionBar: BottomActionBar(
            child: AppButton(
              key: const ValueKey('copy_csv'),
              text: 'Copiar CSV',
              icon: Icons.copy_rounded,
              color: AppColors.primaryAction,
              height: AppSizes.actionHeight,
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: csvData));
                if (context.mounted) {
                  showAppSnackBar(
                    context,
                    'Exportacao de chamada em CSV pronta para copiar',
                  );
                }
              },
            ),
          ),
          children: [
            SectionCard(
              title: 'Configurações',
              children: [
                Text(
                  'Copie os dados em formato CSV para usar em planilhas como Excel ou Google Sheets.',
                  style: AppTextStyles.support.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: AppDropdown<String>(
                        value: _classGroupId,
                        label: 'Turma',
                        items: [
                          for (final group in widget.diario.classGroups)
                            DropdownMenuItem(
                              value: group.id,
                              child: Text(group.name),
                            ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            _classGroupId = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: AppDropdown<String>(
                        value: _disciplineId,
                        label: 'Disciplina',
                        items: [
                          for (final discipline in widget.diario.disciplines)
                            DropdownMenuItem(
                              value: discipline.id,
                              child: Text(discipline.name),
                            ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            _disciplineId = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.section),
            Container(
              width: double.infinity,
              padding: AppSpacing.card,
              // ui-drift-ok: intentional use of BoxDecoration in this screen style context.
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: AppBorders.radius,
                border: AppBorders.horizontal,
              ),
              child: SelectableText(
                csvData,
                style: AppTextStyles.caption.copyWith(
                  fontFamily: 'monospace',
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
