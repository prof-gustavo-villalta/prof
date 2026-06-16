# Refinar acoes primarias, secundarias e barras inferiores

## What to build

Padronizar a apresentacao e prioridade das acoes em todo o app. Cada tela deve ter uma acao primaria clara quando houver uma proxima acao natural, e acoes secundarias devem ficar visualmente subordinadas sem competir com a acao principal.

## Context for executor

Esta issue trata so de acoes: botoes, barras inferiores, prioridade visual, textos de comando. Nao altere regras de negocio.

Leia antes de editar:

- `CONTEXT.md`, termos canonicos e termos a evitar.
- `docs/product-direction.md`, secao `Visual direction`.
- `docs/adr/0003-ui-and-layout-guidelines.md`, regra sem modais/pop-ups.
- `lib/ui/widgets/shared_ui.dart`, principalmente `AppButton`, `HoldToConfirmButton`, `BottomActionBar`, `BottomSplitActionBar`, `ActionDivider`.
- `lib/ui/design_system/app_colors.dart`.
- `lib/ui/design_system/app_sizes.dart`.

Arquivos provaveis:

- `lib/ui/widgets/shared_ui.dart`
- `lib/ui/home_shell.dart`
- `lib/ui/screens/today_screen.dart`
- `lib/ui/screens/attendance_screen.dart`
- `lib/ui/screens/classes_screen.dart`
- `lib/ui/screens/class_group_detail_screen.dart`
- `lib/ui/screens/class_group_schedule_screen.dart`
- `lib/ui/screens/group_form_screen.dart`
- `lib/ui/screens/discipline_form_screen.dart`
- `lib/ui/screens/schedule_form_screen.dart`
- `lib/ui/screens/add_students_screen.dart`
- `lib/ui/screens/history_screen.dart`
- `lib/ui/screens/export_data_screen.dart`

## Suggested execution order

1. Liste todas as telas com `bottomActionBar`.
2. Para cada tela, identifique acao primaria natural. Exemplos: `Salvar`, `Criar Turma`, `Iniciar Chamada`, `Fechar Chamada`, `Exportar CSV`.
3. Padronize tela com uma acao principal usando `BottomActionBar`.
4. Padronize tela com duas acoes equivalentes ou opostas usando `BottomSplitActionBar`.
5. Revise cores: primaria deve usar `AppColors.primaryAction` ou padrao do `AppButton`; destrutiva/cancelamento deve usar tokens existentes como `cancelBase`/`cancelFill` quando aplicavel.
6. Revise texto dos botoes usando portugues curto e verbo no infinitivo/imperativo consistente.

## Concrete guidance

- Acoes de criacao/salvamento: preferir cor primaria consistente.
- Acoes destrutivas/cancelamento: devem parecer diferentes da primaria. Exemplo existente: `HoldToConfirmButton` para cancelamento sensivel.
- Acoes secundarias nao devem competir com acao principal por cor forte quando estao no mesmo contexto.
- Botao com icone deve usar `AppButton(icon: ...)` quando ja suportado.
- Nao usar `FilledButton`, `ElevatedButton` ou `TextButton` diretamente em telas se `AppButton` cobre o caso.
- Texto deve usar termos canonicos: `Turma`, `Disciplina`, `Aluno`, `Grade Semanal`, `Chamada`, `Historico`, `Exportacao`.
- Evitar sinonimos fora do glossario: `classe`, `materia`, `estudante`, `frequencia`, `relatorio`.

## Non-goals

- Nao alterar fluxo de criacao/edicao.
- Nao adicionar confirmacao modal.
- Nao mudar ordem de navegacao principal.
- Nao implementar undo/redo.
- Nao alterar persistencia.

## Acceptance criteria

- [x] Telas com proxima acao obvia usam `BottomActionBar` ou `BottomSplitActionBar` de forma consistente.
- [x] Acoes primarias usam cor, texto e posicao consistentes com o **Design System**.
- [x] Acoes secundarias, destrutivas ou de cancelamento ficam diferenciadas sem parecerem a acao principal.
- [x] Textos de botoes usam verbos claros em portugues e termos canonicos do `CONTEXT.md`.
- [x] A largura, altura e alinhamento dos botoes permanecem estaveis em Android e Web.
- [x] `npm run check:ui` passa ou mostra apenas excecoes justificadas com `ui-drift-ok:`.
- [x] `flutter analyze` passa.
- [x] `flutter test` passa.

## Verification notes

- Procurar usos diretos: `rg -n "FilledButton|ElevatedButton|TextButton|BottomActionBar|BottomSplitActionBar|AppButton|HoldToConfirmButton" lib/ui`.
- Conferir que botoes longos nao estouram com `Flexible` ou texto menor ja suportado por `AppButton`.
- Rode `npm run check:ui`, `flutter analyze`, `flutter test`.

## Notes

- 2026-06-16: `npm run check:ui` foi executado e finalizou com sucesso; reportou 22 achados de `manual decoration` sem bloqueio para o comando (sem bloqueio no status), concentrados em `lib/ui` já existentes.
- 2026-06-16: `flutter test` foi executado e passou após ajuste de rótulos no teste `test/classes_screen_test.dart` para refletir os textos atuais da UI (`Adicionar disciplina` e `Adicionar horário`) no fluxo de grade semanal.

## Blocked by

- docs/issues/0017-refinar-hierarquia-visual-e-densidade.md
