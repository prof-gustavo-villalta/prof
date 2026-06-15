# Refinar responsividade e overflow Android/Web

## What to build

Revisar layouts de coluna unica e linhas internas para reduzir risco de overflow em Android e Web. O app deve continuar mobile-first em todos os alvos, sem introduzir grid desktop ou calendario visual fora do MVP.

## Context for executor

Esta issue e sobre estabilidade de layout. Mantenha app mobile-first mesmo no Web. Nao criar layouts especiais de desktop.

Leia antes de editar:

- `CONTEXT.md`, `UI & Layout Guidelines`.
- `docs/adr/0003-ui-and-layout-guidelines.md`.
- `docs/product-direction.md`, principalmente `Chamada` e `Visual direction`.
- `lib/ui/widgets/single_column_screen.dart`.
- `lib/ui/widgets/shared_ui.dart`, principalmente `LessonInfoRow`, `AppFilterRow`, `BottomActionBar`, `BottomSplitActionBar`.
- `lib/ui/widgets/bordered_container.dart`.
- `lib/ui/screens/attendance_screen.dart`.
- `lib/ui/screens/today_screen.dart`.
- `lib/ui/screens/history_screen.dart`.
- `lib/ui/screens/student_summary_screen.dart`.
- `lib/ui/screens/class_group_detail_screen.dart`.
- `lib/ui/screens/class_group_schedule_screen.dart`.

## Suggested execution order

1. Procure `Row(` em `lib/ui`. Revise cada linha com textos dinamicos.
2. Para cada `Row`, confirme uso de `Expanded`, `Flexible`, `maxLines` e `overflow` quando ha texto variavel.
3. Procure `SizedBox(width:)`, `Container(width:)`, `height`, `fontSize` e padding manual em telas. Remova valores rigidos perigosos quando tokens existentes bastam.
4. Corrija primeiro cards/list rows que mostram nomes de **Aluno**, **Turma**, **Disciplina** e **Periodo letivo**.
5. Confirme que areas com `bottomActionBar` deixam conteudo rolavel acessivel.
6. Mantenha listas verticais em Android e Web.

## Concrete guidance

- Em `Row`, nunca deixe `Text` dinamico sem `Expanded`/`Flexible` se houver outros elementos na mesma linha.
- Use `maxLines: 1` + `TextOverflow.ellipsis` para nomes em linha compacta.
- Use `maxLines: 2` so quando a linha tiver altura flexivel e nao quebrar alinhamento.
- Percentuais, horarios e contagens podem ficar com largura menor, mas nao devem espremer nomes ate zero.
- Divisoes horizontais devem seguir proporcoes claras: 20/50/30, 50/50 ou 2/3 + 1/3.
- Evite `IntrinsicHeight`/`IntrinsicWidth` se nao for necessario.
- Evite `Wrap` para substituir lista principal da **Chamada**; ela deve continuar vertical.
- Evite `LayoutBuilder` para criar experiencia desktop diferente. Use apenas se resolver overflow mantendo coluna unica.

## Manual test scenarios

Use estes dados mentalmente ou em teste/widget se ja houver fixture:

- **Turma**: `Desenvolvimento de Sistemas 3 - Periodo Noturno 2026/1`
- **Disciplina**: `Programacao para Aplicativos Moveis II`
- **Aluno**: `Ana Carolina de Souza Albuquerque`
- **Periodo letivo**: `2026 anual - turma integrada noite`
- Horario: `07:00 - 11:40`

Verifique que esses textos nao causam overflow nas telas principais.

## Non-goals

- Nao criar grid desktop.
- Nao criar calendario visual.
- Nao mudar ordem de listas.
- Nao mudar ordenacao alfabetica de **Aluno**.
- Nao mudar regras da **Chamada**.

## Acceptance criteria

- [ ] Linhas com proporcoes internas seguem padroes previsiveis como 20/50/30, 50/50 ou 2/3 + 1/3 quando houver conteudo horizontal.
- [ ] Textos longos de **Turma**, **Disciplina**, **Aluno**, **Periodo letivo** e horarios nao causam overflow.
- [ ] Listas e cards mantem largura total da coluna principal e nao criam alinhamentos inconsistentes entre telas.
- [ ] Barras inferiores e areas rolaveis continuam acessiveis em telas pequenas.
- [ ] Nenhuma tela troca para grid desktop; a lista vertical da **Chamada** permanece vertical em Android e Web.
- [ ] `npm run check:ui` passa ou mostra apenas excecoes justificadas com `ui-drift-ok:`.
- [ ] `flutter analyze` passa.
- [ ] `flutter test` passa.

## Verification notes

- Procurar linhas: `rg -n "Row\\(|Expanded\\(|Flexible\\(|TextOverflow|overflow:" lib/ui`.
- Procurar tamanhos rigidos: `rg -n "SizedBox\\(width|Container\\(width|fontSize:|EdgeInsets\\." lib/ui`.
- Rode `npm run check:ui`, `flutter analyze`, `flutter test`.

## Blocked by

- docs/issues/0019-refinar-estados-vazios-feedback-e-mensagens.md
