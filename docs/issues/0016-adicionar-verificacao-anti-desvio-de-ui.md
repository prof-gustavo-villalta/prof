# Adicionar verificacao anti-desvio de UI

## What to build

Adicionar uma verificacao simples para reduzir desvios do **Design System** em telas novas ou alteradas. A verificacao deve apontar usos diretos de valores visuais que deveriam vir dos tokens ou componentes compartilhados, sem bloquear casos intencionais quando houver justificativa clara.

## Acceptance criteria

- [ ] Existe uma forma documentada de procurar desvios comuns nas telas, como `Colors.*`, `TextStyle(`, `EdgeInsets` numerico e decoracoes manuais.
- [ ] A verificacao foca arquivos de UI e evita ruido em arquivos de dominio ou dados.
- [ ] Casos aceitos por design podem ser mantidos com justificativa clara no codigo ou na documentacao.
- [ ] A verificacao pode ser executada localmente antes de commits de UI.
- [ ] `flutter analyze` passa.
- [ ] `flutter test` passa.

## Blocked by

- docs/issues/0012-padronizar-telas-simples-e-forms.md
- docs/issues/0013-padronizar-fluxo-turmas-e-grade.md
- docs/issues/0014-padronizar-fluxo-hoje-e-chamada.md
- docs/issues/0015-padronizar-historico-exportacao-e-resumo-do-aluno.md
