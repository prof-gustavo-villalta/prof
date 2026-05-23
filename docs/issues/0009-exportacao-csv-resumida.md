# Exportacao CSV resumida

## What to build

Implementar **Exportacao de chamada** em CSV a partir do **Historico de chamada**. O MVP deve exportar um resumo por Aluno em uma Turma e Disciplina, com as colunas: Aluno, Turma, Disciplina, Periodo letivo, Aulas chamadas, Presencas, Atrasos, Ausencias, Justificativas e Percentual de presenca.

## Acceptance criteria

- [x] O Professor consegue exportar CSV a partir do Historico de uma Turma e Disciplina.
- [x] O CSV contem as colunas definidas no escopo do MVP.
- [x] Cada linha representa um Aluno.
- [x] Aulas chamadas considera apenas Chamadas fechadas.
- [x] Atrasos, Ausencias e Justificativas aparecem em colunas separadas.
- [x] Percentual de presenca usa a mesma regra do Historico.
- [x] Exportacao detalhada por data nao aparece no MVP.

## Blocked by

- docs/issues/0008-historico-com-percentual-de-presenca.md
