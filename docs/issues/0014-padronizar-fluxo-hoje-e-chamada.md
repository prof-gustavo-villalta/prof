# Padronizar fluxo Hoje e Chamada

## What to build

Padronizar as telas **Hoje** e **Chamada** para seguir o **Design System**, preservando a velocidade de uso em sala de aula. O professor deve continuar conseguindo identificar a aula atual, iniciar ou retomar uma chamada, marcar presencas e fechar a chamada sem perda de clareza.

## Acceptance criteria

- [x] A tela Hoje usa componentes e tokens do Design System para aula atual, proximas aulas, pendencias e acoes.
- [x] A tela de Chamada usa componentes e tokens do Design System para busca, filtros, cards de alunos, status e acoes.
- [x] Cores de status continuam consistentes para Presente, Ausente, Atraso e Justificado.
- [x] O fluxo de marcar presenca, atraso, justificativa e ausencia permanece rapido e sem passos extras.
- [ ] A mudanca passa por revisao visual manual antes de merge.
- [x] `flutter analyze` passa.
- [ ] `flutter test` passa.

## Notes

- `npm run analyze` foi executado e passou.
- `npm run test` falhou por regressão de layout em `lib/ui/screens/attendance_screen.dart` (`BoxConstraints` infinito na `Row` em torno de `InkWell` em `StudentAttendanceCard`) e por falha no teste `professor configura turma e fecha uma chamada`; `flutter test` permanece em aberto.

## Blocked by

- docs/issues/0011-padronizar-entrada-do-design-system.md
