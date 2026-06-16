# Refinar estados vazios, feedback e mensagens

## What to build

Refinar estados vazios, mensagens de sucesso/erro e feedbacks de interacao para manter o app claro sem usar modais ou pop-ups. As mensagens devem orientar o **Professor** para a proxima acao possivel usando linguagem curta e termos canonicos.

## Context for executor

Esta issue trata de clareza quando nao ha dados, quando uma acao termina, ou quando uma acao visual falha/cancela. O app nao deve usar modais/pop-ups para fluxo normal.

Leia antes de editar:

- `CONTEXT.md`, termos canonicos.
- `docs/adr/0003-ui-and-layout-guidelines.md`, regra sem modais/pop-ups.
- `docs/product-direction.md`, secoes `Onboarding`, `Hoje`, `Historico`, `Chamada`, `Turmas`.
- `lib/ui/widgets/shared_ui.dart`, principalmente `EmptyCard` e `showAppSnackBar`.
- `lib/ui/screens/onboarding_screen.dart`.
- `lib/ui/screens/today_screen.dart`.
- `lib/ui/screens/classes_screen.dart`.
- `lib/ui/screens/class_group_detail_screen.dart`.
- `lib/ui/screens/class_group_schedule_screen.dart`.
- `lib/ui/screens/attendance_screen.dart`.
- `lib/ui/screens/history_screen.dart`.
- `lib/ui/screens/student_summary_screen.dart`.
- `lib/ui/screens/export_data_screen.dart`.
- `lib/ui/screens/settings_screen.dart`.

## Suggested execution order

1. Procure todos os `EmptyCard(` e mensagens passadas para `showAppSnackBar`.
2. Agrupe mensagens por tipo: sem dados, sucesso, cancelamento, erro.
3. Padronize `EmptyCard` primeiro se o componente precisar de ajuste visual.
4. Ajuste textos vazios tela por tela. Cada mensagem deve ser curta e indicar proxima acao quando existir.
5. Revise snackbars existentes. Se forem apenas feedback temporario, podem continuar; se pedirem decisao do usuario, criar/usar tela em vez de modal/snackbar.
6. Confirme que nenhuma mudanca cria `showDialog`, `AlertDialog`, `Dialog`, `BottomSheet`, `PopupMenu` ou fluxo modal.

## Concrete guidance

- Estado vazio bom: `Nenhuma Turma cadastrada.` + botao principal visivel fora do card.
- Estado vazio ruim: paragrafo longo explicando todo o app.
- Para **Hoje**, mensagem deve diferenciar falta de **Aula atual**, **Proxima aula** ou **Chamada pendente** sem inventar termo novo.
- Para **Chamada**, vazio deve indicar ausencia de **Aluno** na **Turma**, nao "participante".
- Para **Historico**, vazio deve dizer que o historico vem de **Chamadas fechadas**.
- Para **Exportacao**, feedback deve falar `CSV` e **Exportacao de chamada** quando caber.
- Para **Foto do aluno**, cancelamento deve ser compreensivel e nao alarmista.
- Mensagens devem ficar em portugues brasileiro sem acento obrigatorio se arquivo ja usa ASCII.

## Non-goals

- Nao criar sistema global de notificacoes.
- Nao adicionar modal/dialog.
- Nao adicionar animacoes.
- Nao mudar estados de dominio.
- Nao transformar snackbar em requisito para salvar dados.

## Acceptance criteria

- [x] Estados vazios usam um padrao visual consistente para icone, texto, espacamento e bordas.
- [x] Estados vazios importantes indicam a proxima acao disponivel sem virar texto explicativo longo.
- [x] Feedbacks temporarios existentes sao revisados para nao criar fluxo modal nem bloquear navegacao.
- [x] Mensagens usam termos canonicos do `CONTEXT.md`, como **Turma**, **Disciplina**, **Aluno**, **Grade Semanal**, **Chamada** e **Exportacao de chamada**.
- [x] Erros ou cancelamentos de acoes visuais, como **Foto do aluno**, continuam compreensiveis sem dialog.
- [ ] `npm run check:ui` passa ou mostra apenas excecoes justificadas com `ui-drift-ok:`.
- [x] `flutter analyze` passa.
- [x] `flutter test` passa.

## Verification notes

- Procurar proibidos: `rg -n "showDialog|AlertDialog|Dialog\\(|showModal|BottomSheet|PopupMenu" lib/ui`.
- Procurar mensagens: `rg -n "EmptyCard\\(|showAppSnackBar|SnackBar\\(" lib/ui`.
- Rode `npm run check:ui`, `flutter analyze`, `flutter test`.

## Notes

- Criterio 5 concluido: fluxo de Foto do aluno trata cancelamento e falha com `showAppSnackBar` (sem dialogo), deixando a acao compreensivel.
- Criterio 3 concluido sem mudancas de fluxo: os feedbacks temporarios continuam por `SnackBar` em `showAppSnackBar` (sem modais), com limpeza do feedback anterior antes de exibir um novo para evitar sobreposicao.

## Blocked by

- docs/issues/0018-refinar-acoes-primarias-secundarias-e-barras-inferiores.md
