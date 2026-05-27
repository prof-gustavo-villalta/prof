import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/diario_de_classe.dart';
import '../design_system/app_colors.dart';
import '../widgets/page_header.dart';
import '../widgets/shared_ui.dart';

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

        return Scaffold(
          appBar: AppBar(
            title: const Text('Exportar dados'),
          ),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    children: [
                      const PageHeader(
                        title: 'Exportar CSV',
                        icon: Icons.import_export_rounded,
                      ),
                      const SizedBox(height: 28),
                      Text(
                        'Copie os dados em formato CSV para usar em planilhas como Excel ou Google Sheets.',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.zero,
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outlineVariant,
                            width: 2,
                          ),
                        ),
                        child: SelectableText(
                          csvData,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 13,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 66,
                  child: AppButton(
                    key: const ValueKey('copy_csv'),
                    text: 'Copiar CSV',
                    icon: Icons.copy_rounded,
                    color: AppColors.primaryAction,
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: csvData));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'CSV pronto para copiar',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onInverseSurface,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Theme.of(context).colorScheme.inverseSurface,
                          ),
                        );
                      }
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
}
