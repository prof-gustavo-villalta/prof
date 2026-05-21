# Exportacao CSV resumida

## What to build

Implementar **Exportacao de chamada** em CSV a partir do **Historico de chamada**. O MVP deve exportar um resumo por Aluno em uma Turma e Disciplina, com as colunas: Aluno, Turma, Disciplina, Periodo letivo, Aulas chamadas, Presencas, Atrasos, Ausencias, Justificativas e Percentual de presenca.

## Acceptance criteria

- [ ] O Professor consegue exportar CSV a partir do Historico de uma Turma e Disciplina.
- [ ] O CSV contem as colunas definidas no escopo do MVP.
- [ ] Cada linha representa um Aluno.
- [ ] Aulas chamadas considera apenas Chamadas fechadas.
- [ ] Atrasos, Ausencias e Justificativas aparecem em colunas separadas.
- [ ] Percentual de presenca usa a mesma regra do Historico.
- [ ] Exportacao detalhada por data nao aparece no MVP.

## Blocked by

- docs/issues/0008-historico-com-percentual-de-presenca.md
