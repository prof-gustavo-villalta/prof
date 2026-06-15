# Refinar hierarquia visual e densidade

## What to build

Refinar a hierarquia visual e a densidade das telas para que o **Professor** leia rapidamente a informacao principal de cada fluxo. A mudanca deve preservar a navegacao linear, o layout de coluna unica e os termos de dominio ja definidos, sem alterar regras de **Aula**, **Turma**, **Chamada**, **Historico de chamada** ou **Exportacao de chamada**.

## Context for executor

Esta issue vem depois da primeira padronizacao do **Design System**. Nao recrie o design do app. Ajuste inconsistencias pequenas e repetidas.

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

1. Rode `npm run check:ui` e anote achados que sejam realmente ligados a tipografia, espacamento ou decoracao manual.
2. Revise componentes compartilhados primeiro: `PageHeader`, `SectionCard`, `EmptyCard`, `LessonInfoRow`, cards/list rows em `shared_ui.dart`.
3. Corrija telas que duplicam hierarquia visual manual em vez de usar componentes/tokens.
4. Prefira mover padroes repetidos para widget compartilhado existente. Crie widget novo so se houver repeticao clara em 3+ lugares.
5. Depois de cada criterio, marque somente o criterio realmente concluido.

## Concrete guidance

- Titulo de tela: usar `PageHeader` ou estilo equivalente ja centralizado.
- Titulo de secao/card: usar `AppTextStyles.titleMedium` ou `Theme.of(context).textTheme.titleMedium`.
- Texto auxiliar/metadado: usar `AppTextStyles.bodyMedium`, `AppTextStyles.caption` ou `AppTextStyles.rowMeta`.
- Evitar `TextStyle(` fora de `lib/ui/design_system`, salvo excecao com comentario `ui-drift-ok:`.
- Evitar novos `EdgeInsets` numericos em telas. Preferir `AppSpacing.pageInsets`, `AppSpacing.row`, `AppSpacing.compactRow`, `AppSpacing.card`, `AppSpacing.panel`, `SizedBox(height: AppSpacing.*)`.
- Linhas de lista devem usar `maxLines` e `overflow: TextOverflow.ellipsis` quando exibem nomes de **Aluno**, **Turma**, **Disciplina** ou horario em uma linha horizontal.
- Nao use `letterSpacing` manual em tela/widget especifico. Se precisar, use token em `AppTextStyles`.

## Non-goals

- Nao mudar calculos de **Percentual de presenca**.
- Nao mudar navegacao.
- Nao mudar modelo de dados.
- Nao trocar lista vertical por grid.
- Nao adicionar pacote novo.
- Nao criar calendario visual.

## Acceptance criteria

- [ ] Titulos, subtitulos, metadados e textos auxiliares usam uma hierarquia consistente baseada em `AppTextStyles` ou `Theme.of(context).textTheme`.
- [ ] Espacamentos entre cabecalho, secoes, listas e acoes usam tokens de `AppSpacing` sem valores soltos novos em telas.
- [ ] Linhas densas de listas continuam legiveis em Android e Web, com truncamento ou quebra controlada onde necessario.
- [ ] A informacao principal de cada tela fica visualmente acima de informacoes secundarias.
- [ ] `npm run check:ui` passa ou mostra apenas excecoes justificadas com `ui-drift-ok:`.
- [ ] `flutter analyze` passa.
- [ ] `flutter test` passa.

## Verification notes

- Use `npm run check:ui` for drift.
- Use `flutter analyze` and `flutter test` before marking final checks.
- Manual spot check: abrir mentalmente cada tela e confirmar que primeiro bloco visivel responde "onde estou?" e "qual informacao importa agora?".

## Blocked by

- docs/issues/0016-adicionar-verificacao-anti-desvio-de-ui.md
