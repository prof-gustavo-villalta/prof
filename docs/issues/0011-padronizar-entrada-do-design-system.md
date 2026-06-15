# Padronizar entrada do design system

## What to build

Criar uma entrada unica para o **Design System** da interface e usar essa entrada nos pontos em que a UI ja depende dos tokens visuais. A mudanca deve deixar claro que telas e widgets novos devem consumir cores, espacamentos, tamanhos, bordas, estilos de texto e tema a partir do design system, sem alterar comportamento funcional do app.

## Acceptance criteria

- [ ] Existe um arquivo de entrada unico para exportar os tokens do Design System.
- [ ] Imports obvios de tokens visuais podem ser trocados para a entrada unica sem mudar comportamento.
- [ ] O app continua usando o tema principal baseado no Design System.
- [ ] `flutter analyze` passa.
- [ ] `flutter test` passa.

## Blocked by

None - can start immediately
