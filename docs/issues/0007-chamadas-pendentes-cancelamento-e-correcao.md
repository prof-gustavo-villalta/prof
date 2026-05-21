# Chamadas pendentes, cancelamento e correcao

## What to build

Implementar o tratamento de **Chamadas pendentes**, **Aula cancelada** e **Correcao de chamada**. Uma Aula nao cancelada que passou sem Chamada fechada deve aparecer como Chamada pendente. Uma Aula cancelada nao gera Chamada, nao gera Ausencia e nao entra no historico. Uma Chamada fechada pode ser reaberta, corrigida e fechada novamente, sem criar segunda Chamada.

## Acceptance criteria

- [ ] Aula passada nao cancelada e sem Chamada fechada aparece em Pendentes na tela Hoje.
- [ ] Chamada pendente pode ser aberta e fechada pelo Professor.
- [ ] O Professor consegue cancelar uma ocorrencia especifica de Aula sem alterar a Grade Semanal.
- [ ] Aula cancelada nao aparece como pendencia e nao gera Ausencia.
- [ ] Aula cancelada e ignorada no Historico de chamada.
- [ ] Chamada fechada pode ser reaberta, editada e fechada novamente.
- [ ] Reabrir uma Chamada nao cria outra Chamada para a mesma Aula.

## Blocked by

- docs/issues/0006-chamada-aberta-com-lista-vertical-e-autosave.md
