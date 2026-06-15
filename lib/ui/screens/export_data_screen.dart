import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import '../../domain/diario_de_classe.dart';
import '../design_system.dart';
import '../widgets/shared_ui.dart';
import '../widgets/single_column_screen.dart';

class ExportDataScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: diario,
      builder: (context, _) {
        final csvData = diario.csvExport(
          classGroupId: classGroupId,
          disciplineId: disciplineId,
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
                  showAppSnackBar(context, 'CSV pronto para copiar');
                }
              },
            ),
          ),
          children: [
            Text(
              'Copie os dados em formato CSV para usar em planilhas como Excel ou Google Sheets.',
              style: AppTextStyles.support.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: AppSpacing.loose),
            Container(
              width: double.infinity,
              padding: AppSpacing.panel,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.04),
                borderRadius: AppBorders.radius,
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  width: AppSizes.divider,
                ),
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
