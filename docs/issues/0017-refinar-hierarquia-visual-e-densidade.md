# Refinar hierarquia visual e densidade

## What to build

Refinar hierarquia visual e densidade das telas para que o **Professor** identifique rapidamente contexto, informacao principal e proxima acao de cada fluxo. A mudanca deve preservar navegacao linear, layout de coluna unica e termos de dominio ja definidos, sem alterar regras de **Aula**, **Turma**, **Chamada**, **Historico de chamada** ou **Exportacao de chamada**.

## Context for executor

Esta issue vem depois da primeira padronizacao do **Design System**. Nao recrie o design do app. O trabalho esperado e reduzir inconsistencias pequenas e repetidas de tipografia, espacamento, densidade e prioridade visual.

Leia antes de editar:

- `CONTEXT.md`, principalmente `Language` e `UI & Layout Guidelines`.
- `docs/product-direction.md`, principalmente `Visual direction`.
- `docs/adr/0003-ui-and-layout-guidelines.md`.
- `docs/development-notes.md`, secao `UI drift check`.
- `lib/ui/design_system.dart` e arquivos exportados por ele.
- `lib/ui/widgets/single_column_screen.dart`.
- `lib/ui/widgets/page_header.dart`.
- `lib/ui/widgets/shared_ui.dart`.

Arquivos provaveis:

- `lib/ui/widgets/page_header.dart`
- `lib/ui/widgets/shared_ui.dart`
- `lib/ui/screens/today_screen.dart`
- `lib/ui/screens/classes_screen.dart`
- `lib/ui/screens/class_group_detail_screen.dart`
- `lib/ui/screens/class_group_schedule_screen.dart`
- `lib/ui/screens/attendance_screen.dart`
- `lib/ui/screens/history_screen.dart`
- `lib/ui/screens/student_summary_screen.dart`
- `lib/ui/screens/export_data_screen.dart`
- `lib/ui/screens/settings_screen.dart`

## Suggested execution order

1. Rode `npm run check:ui` e separe achados ligados a tipografia, espacamento, decoracao manual ou densidade.
2. Revise componentes compartilhados antes das telas: `PageHeader`, `SectionCard`, `EmptyCard`, `LessonInfoRow` e cards/list rows em `shared_ui.dart`.
3. Corrija telas que duplicam hierarquia visual manual em vez de usar componentes/tokens.
4. Prefira consolidar padroes repetidos em widget compartilhado existente. Crie widget novo so se houver repeticao clara em 3+ lugares.
5. Revise telas principais em ordem de impacto: **Hoje**, **Chamada**, **Turmas**, **Grade Semanal**, **Historico**, **Resumo do Aluno**, **Exportacao**, **Ajustes**.
6. Depois de cada criterio, marque somente o criterio realmente concluido.

## Concrete guidance

- Titulo de tela deve usar `PageHeader` ou estilo equivalente ja centralizado.
- Titulo de secao/card deve usar `AppTextStyles.titleMedium` ou `Theme.of(context).textTheme.titleMedium`.
- Texto auxiliar/metadado deve usar `AppTextStyles.bodyMedium`, `AppTextStyles.caption` ou `AppTextStyles.rowMeta`.
- Evitar `TextStyle(` fora de `lib/ui/design_system`, salvo excecao com comentario `ui-drift-ok:`.
- Evitar novos `EdgeInsets` numericos em telas. Preferir `AppSpacing.pageInsets`, `AppSpacing.row`, `AppSpacing.compactRow`, `AppSpacing.card`, `AppSpacing.panel`, `SizedBox(height: AppSpacing.*)`.
- Linhas de lista devem usar `maxLines` e `overflow: TextOverflow.ellipsis` quando exibem nomes de **Aluno**, **Turma**, **Disciplina** ou horario em uma linha horizontal.
- Nao use `letterSpacing` manual em tela/widget especifico. Se precisar, use token em `AppTextStyles`.
- A informacao mais importante da tela deve aparecer no primeiro bloco visivel, antes de metadados, ajuda contextual ou historico.
- Densidade deve continuar mobile-first: compacta para escanear, mas sem reduzir area de toque ou criar linhas espremidas.

## Non-goals

- Nao mudar calculos de **Percentual de presenca**.
- Nao mudar navegacao.
- Nao mudar modelo de dados.
- Nao trocar lista vertical por grid.
- Nao adicionar pacote novo.
- Nao criar calendario visual.

## Acceptance criteria

- [x] Titulos, subtitulos, metadados e textos auxiliares usam hierarquia consistente baseada em `AppTextStyles` ou `Theme.of(context).textTheme`.
- [x] Espacamentos entre cabecalho, secoes, listas e acoes usam tokens de `AppSpacing`, sem novos valores soltos em telas.
- [x] Linhas densas de listas continuam legiveis em Android e Web, com truncamento ou quebra controlada para textos variaveis.
- [x] Informacao principal de cada tela aparece visualmente antes de informacoes secundarias.
- [x] `npm run check:ui` passa ou mostra apenas excecoes justificadas com `ui-drift-ok:`.
- [x] `flutter analyze` passa.
- [x] `flutter test` passa.

## Verification notes

- Use `npm run check:ui` para drift.
- Use `flutter analyze` e `flutter test` antes de marcar os criterios finais.
- Manual spot check: abrir mentalmente cada tela e confirmar que primeiro bloco visivel responde "onde estou?" e "qual informacao importa agora?".
- `npm run check:ui` retornou `exit 0` com apenas avisos de `manual decoration`, sem falhas de drift.
- `flutter test` (2026-06-15) retornou `exit 0`.
- `flutter analyze` foi reexecutado apos os ajustes abaixo e retornou `exit 0`:
  - `lib/ui/design_system/app_theme.dart`: removido `const` redundante.
  - `lib/ui/widgets/app_dropdown.dart`: simplificado fallback para eliminar warning `dead_code`/`dead_null_aware_expression`.

## Notes

- Issue concluida apos ajustes de hierarquia visual, densidade, tokens e verificacoes locais.

## Blocked by

- docs/issues/0016-adicionar-verificacao-anti-desvio-de-ui.md
