# Historico com Percentual de presenca

## What to build

Implementar o **Historico de chamada** a partir de **Chamadas fechadas**, com consultas por **Aula**, **Aluno**, **Turma** e **Disciplina**. O historico deve calcular **Percentual de presenca** por Aluno em uma Turma e Disciplina. **Atraso** conta como comparecimento no percentual, mas aparece separado no detalhamento. **Justificativa** nao conta como Presenca, mas aparece separada de Ausencia comum.

## Acceptance criteria

- [x] Apenas Chamadas fechadas entram no Historico de chamada.
- [x] Chamadas pendentes nao entram no Historico ate serem fechadas.
- [x] Aulas canceladas nao entram no Historico.
- [x] O Historico pode ser consultado por Aula.
- [x] O Historico pode ser consultado por Aluno.
- [x] O Historico pode ser consultado por Turma e Disciplina.
- [x] O Historico mostra totais de Presencas, Atrasos, Ausencias e Justificativas.
- [x] O Percentual de presenca conta Presenca e Atraso como comparecimento.
- [x] Justificativa aparece separada e nao conta como Presenca.

## Blocked by

- docs/issues/0006-chamada-aberta-com-lista-vertical-e-autosave.md
- docs/issues/0007-chamadas-pendentes-cancelamento-e-correcao.md
