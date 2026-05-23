# Grade Semanal e selecao da Aula atual

## What to build

Implementar a **Grade Semanal** e a selecao automatica da **Aula atual** ou **Proxima aula** na tela Hoje. Cada item da grade define dia da semana, horario de inicio e fim, **Turma** e **Disciplina**. O app deve respeitar datas opcionais do **Periodo letivo** e tratar intervalos sem aula apenas como espacos entre itens da grade.

## Acceptance criteria

- [x] O Professor consegue criar, editar e remover itens da Grade Semanal.
- [x] Cada item da Grade Semanal exige dia da semana, inicio, fim, Turma e Disciplina.
- [x] Ao abrir Hoje durante um horario cadastrado, o app mostra a Aula atual em destaque.
- [x] Fora do horario de aula, Hoje mostra a Proxima aula, preferindo outra aula do mesmo dia.
- [x] A Proxima aula pode ter Chamada iniciada manualmente antes do horario.
- [x] Se o Periodo letivo tiver datas inicial/final, aulas fora desse intervalo nao aparecem como atuais/proximas.
- [x] Nao existe calendario visual mensal/semanal no MVP.

## Blocked by

- docs/issues/0003-cadastro-de-turmas-disciplinas-e-alunos.md
