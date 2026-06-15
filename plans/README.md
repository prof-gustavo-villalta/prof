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

- Ver fila de issues:

```powershell
npm run ralph:issues
```

- Windows explicito:

```powershell
npm run w:ralph:issues
npm run w:ralph:hitl
npm run w:ralph:afk -- 3
```

- Linux explicito:

```bash
npm run l:ralph:issues
npm run l:ralph:hitl
npm run l:ralph:afk -- 3
```

## Contrato

Cada iteracao:

1. Le `docs/issues`, `plans/prd.md`, `CONTEXT.md`, docs e ultimos commits do git.
2. Escolhe a menor issue desbloqueada com criterio aberto.
3. Escolhe exatamente um criterio de aceite.
4. Explora codigo relevante antes de editar.
5. Implementa uma mudanca pequena.
6. Atualiza checklist da issue.
7. Roda `npm run analyze` e `npm run test`.
8. Faz commit normal, mencionando issue e criterio no corpo.

## Selecao de issues

`docs/issues` e a fila principal. `plans/prd.md` e contexto de produto.

Regra:

1. Pegar a menor issue numerada com criterios abertos.
2. Pular issues bloqueadas por outra issue ainda aberta.
3. Fazer uma mudanca pequena por iteracao.
4. Marcar `[x]` apenas criterios realmente concluidos.
5. Marcar checks de `flutter analyze` e `flutter test` apenas depois de executar e passar.

Se nao houver tarefa restante, deve emitir:

```text
<promise>NO MORE TASKS</promise>
```

Se bloquear, deve emitir:

```text
<promise>ABORT</promise>
```

## Windows e Linux

Scripts Windows ficam em PowerShell. Scripts Linux ficam em Bash. Ambos esperam `codex` disponivel no `PATH`.
