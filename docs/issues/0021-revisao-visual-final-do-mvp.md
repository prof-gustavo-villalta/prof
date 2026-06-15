# Revisao visual final do MVP

## What to build

Fazer uma revisao visual final do MVP apos os refinamentos transversais. A revisao deve corrigir pequenos desvios restantes e registrar no proprio codigo ou documentacao qualquer excecao intencional ao **Design System**.

## Context for executor

Esta e issue final de polimento. Nao comece grandes refactors aqui. Corrija so inconsistencias pequenas descobertas na revisao final.

Leia antes de editar:

- `CONTEXT.md`.
- `plans/prd.md`, principalmente `Visual Direction`.
- `docs/product-direction.md`.
- `docs/adr/0003-ui-and-layout-guidelines.md`.
- `docs/development-notes.md`.
- Issues 0017, 0018, 0019 e 0020 para entender padroes recem-criados.

## Review checklist

Revise estes fluxos no codigo e, se possivel, rodando app:

- Onboarding: `lib/ui/screens/onboarding_screen.dart`
- Hoje: `lib/ui/screens/today_screen.dart`
- Chamada: `lib/ui/screens/attendance_screen.dart`
- Turmas: `lib/ui/screens/classes_screen.dart`
- Detalhe da Turma: `lib/ui/screens/class_group_detail_screen.dart`
- Grade Semanal: `lib/ui/screens/class_group_schedule_screen.dart` e `lib/ui/screens/schedule_form_screen.dart`
- Forms: `group_form_screen.dart`, `discipline_form_screen.dart`, `add_students_screen.dart`
- Historico: `lib/ui/screens/history_screen.dart`
- Resumo do Aluno: `lib/ui/screens/student_summary_screen.dart`
- Exportacao: `lib/ui/screens/export_data_screen.dart`
- Ajustes: `lib/ui/screens/settings_screen.dart`
- Navegacao principal: `lib/ui/home_shell.dart`

## Suggested execution order

1. Rode `npm run check:ui`.
2. Revise achados. Corrija achados simples; adicione `ui-drift-ok:` so quando valor direto for intencional e nao houver token melhor.
3. Procure proibidos de navegacao modal.
4. Leia cada tela principal e compare com PRD: fundo claro, espaco em branco, cards limpos, bordas suaves, tipografia legivel, cores de status discretas, uma acao primaria evidente.
5. Corrija inconsistencias pequenas. Exemplos: texto fora do glossario, botao com cor errada, `EdgeInsets` solto, linha sem `overflow`, card com padding diferente sem motivo.
6. Nao marque revisao manual se nao revisou todos os fluxos da checklist.

## Concrete guidance

- Se encontrar problema grande, crie nota em `Notes` desta issue em vez de resolver tudo aqui.
- Se excecao ao design system for necessaria, comentario deve ficar perto do codigo com `ui-drift-ok:` e motivo curto.
- Cores de status devem continuar mapeadas:
  - **Presenca**: `AppColors.present`
  - **Ausencia**: `AppColors.absent`
  - **Atraso**: `AppColors.lateColor`
  - **Justificativa**: `AppColors.justified`
- Nao usar termos evitados pelo glossario: `Usuario`, `Evento`, `materia`, `classe`, `estudante`, `frequencia`, `relatorio`.

## Non-goals

- Nao redesenhar app.
- Nao adicionar nova feature.
- Nao alterar dominio, storage ou dados demo.
- Nao criar testes golden se nao houver infraestrutura existente.
- Nao instalar dependencia.

## Acceptance criteria

- [ ] Fluxos principais sao revisados manualmente: Onboarding, Hoje, Chamada, Turmas, Grade Semanal, Historico, Exportacao e Ajustes.
- [ ] Inconsistencias visuais pequenas encontradas na revisao sao corrigidas ou registradas com justificativa objetiva.
- [ ] Nenhum fluxo principal usa modal ou pop-up para interacao, formulario ou aviso.
- [ ] O app preserva direcao visual do PRD: fundo claro, espaco em branco, cards limpos, bordas suaves, tipografia legivel, cores de status discretas e uma acao primaria evidente por tela quando aplicavel.
- [ ] `npm run check:ui` passa ou mostra apenas excecoes justificadas com `ui-drift-ok:`.
- [ ] `flutter analyze` passa.
- [ ] `flutter test` passa.

## Verification notes

- Proibidos: `rg -n "showDialog|AlertDialog|Dialog\\(|showModal|BottomSheet|PopupMenu" lib/ui`.
- Drift: `npm run check:ui`.
- Checks finais: `flutter analyze` e `flutter test`.
- Depois de revisar, adicionar uma breve nota `## Notes` com fluxos revisados e excecoes aceitas, se houver.

## Blocked by

- docs/issues/0020-refinar-responsividade-e-overflow-android-web.md
