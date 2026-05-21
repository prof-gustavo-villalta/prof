# Historico com Percentual de presenca

## What to build

Implementar o **Historico de chamada** a partir de **Chamadas fechadas**, com consultas por **Aula**, **Aluno**, **Turma** e **Disciplina**. O historico deve calcular **Percentual de presenca** por Aluno em uma Turma e Disciplina. **Atraso** conta como comparecimento no percentual, mas aparece separado no detalhamento. **Justificativa** nao conta como Presenca, mas aparece separada de Ausencia comum.

## Acceptance criteria

- [ ] Apenas Chamadas fechadas entram no Historico de chamada.
- [ ] Chamadas pendentes nao entram no Historico ate serem fechadas.
- [ ] Aulas canceladas nao entram no Historico.
- [ ] O Historico pode ser consultado por Aula.
- [ ] O Historico pode ser consultado por Aluno.
- [ ] O Historico pode ser consultado por Turma e Disciplina.
- [ ] O Historico mostra totais de Presencas, Atrasos, Ausencias e Justificativas.
- [ ] O Percentual de presenca conta Presenca e Atraso como comparecimento.
- [ ] Justificativa aparece separada e nao conta como Presenca.

## Blocked by

- docs/issues/0006-chamada-aberta-com-lista-vertical-e-autosave.md
- docs/issues/0007-chamadas-pendentes-cancelamento-e-correcao.md
