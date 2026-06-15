# Padronizar fluxo Hoje e Chamada

## What to build

Padronizar as telas **Hoje** e **Chamada** para seguir o **Design System**, preservando a velocidade de uso em sala de aula. O professor deve continuar conseguindo identificar a aula atual, iniciar ou retomar uma chamada, marcar presencas e fechar a chamada sem perda de clareza.

## Acceptance criteria

- [x] A tela Hoje usa componentes e tokens do Design System para aula atual, proximas aulas, pendencias e acoes.
- [x] A tela de Chamada usa componentes e tokens do Design System para busca, filtros, cards de alunos, status e acoes.
- [x] Cores de status continuam consistentes para Presente, Ausente, Atraso e Justificado.
- [x] O fluxo de marcar presenca, atraso, justificativa e ausencia permanece rapido e sem passos extras.
- [ ] A mudanca passa por revisao visual manual antes de merge.
- [x] `flutter test` passa.

## Notes

- `npm run analyze` foi executado e passou.
- `npm run test` passou após ajuste em `lib/ui/screens/attendance_screen.dart` (`BoxConstraints` infinito em `Row` de `StudentAttendanceCard`).
- `npm run analyze` reporta warning em `lib/ui/screens/export_data_screen.dart` sobre membro deprecated `surfaceVariant`.

## Blocked by

- docs/issues/0011-padronizar-entrada-do-design-system.md
- Revisao visual manual ainda pendente fora do fluxo automatizado; issue permanece com AC final aberta para aprova��o de merge.
