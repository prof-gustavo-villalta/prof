# Iterative Development Process

Processo adaptado de `mattpocock/ralph-workshop-repo-001` para este repo Flutter em Windows.

## Como rodar

- Uma iteracao supervisionada:

```powershell
npm run ralph:hitl
```

- Varias iteracoes:

```powershell
npm run ralph:afk -- 3
```

## Contrato

Cada iteracao:

1. Le `plans/prd.md`, `CONTEXT.md`, docs e ultimos commits `RALPH:`.
2. Quebra o PRD em tarefas pequenas.
3. Escolhe exatamente uma tarefa.
4. Explora codigo relevante antes de editar.
5. Implementa uma mudanca pequena.
6. Roda `npm run analyze` e `npm run test`.
7. Faz commit com prefixo `RALPH:`.

Se nao houver tarefa restante, deve emitir:

```text
<promise>NO MORE TASKS</promise>
```

Se bloquear, deve emitir:

```text
<promise>ABORT</promise>
```

## Windows

Scripts ficam em PowerShell para evitar dependencia de Bash, `chmod`, `grep`, `jq` ou Docker. O comando espera `codex` disponivel no `PATH`.
