# 3. UI and Layout Guidelines

Date: 2026-05-25

## Status

Accepted

## Context

Para manter a consistência, previsibilidade e simplicidade da interface do usuário em todo o projeto, precisamos estabelecer regras claras sobre a construção das telas e navegação. A ausência de regras estritas sobre o uso de modais e responsabilidades das telas pode causar fragmentação visual e de usabilidade no longo prazo.

## Decision

As seguintes diretrizes de design e arquitetura de telas foram estabelecidas:

1. **Responsabilidade Única por Tela:** Cada tela do aplicativo deve ter uma única responsabilidade. Telas não devem ser sobrecarregadas com múltiplos fluxos de ação.
2. **Uso Exclusivo de Telas (Sem Modais/Pop-ups):** Nunca devem ser usados pop-ups, dialogs ou modais. Toda e qualquer interação, formulário ou aviso deve ocorrer em sua própria tela dedicada na pilha de navegação.
3. **Layout de Coluna Única:** As telas devem ser definidas em termos de um layout de coluna única principal. As linhas (`Rows`) devem sempre ocupar a largura total disponível da tela.
4. **Divisão de Sub-elementos:** Elementos dispostos horizontalmente dentro das linhas devem se organizar utilizando proporções pré-definidas e previsíveis, tais como divisões de 20%/50%/30% ou em terços (2/3 + 1/3).

## Consequences

- Maior facilidade de manutenção devido à clareza do objetivo de cada arquivo de tela.
- Fluxo de navegação linear (push/pop padrão) elimina o estado complexo de modais empilhados.
- O uso de divisões percentuais fixas garante que a aplicação mantenha estabilidade de layout e responsividade, evitando inconsistências e transbordamento de flex (Overflows).
