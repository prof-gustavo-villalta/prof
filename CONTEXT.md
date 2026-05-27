# Prof

App pessoal para o professor organizar aulas, alunos e chamadas presenciais.

## Language

**Professor**:
Usuario unico do app e dono dos dados de aulas, turmas, alunos e chamadas.
_Avoid_: Usuario, conta

**Aula**:
Uma ocorrencia agendada com data, horario de inicio e fim, turma/disciplina e lista de alunos esperados.
_Avoid_: Evento, compromisso, materia

**Aula atual**:
A **Aula** em andamento no horario do dispositivo.
_Avoid_: Aula aberta, aula de agora

**Aula cancelada**:
Ocorrencia de **Aula** que nao aconteceu, nao exige **Chamada** e nao entra no historico de presenca.
_Avoid_: Feriado, aula removida

**Proxima aula**:
A **Aula** futura mais proxima quando nao existe **Aula atual**.
_Avoid_: Aula seguinte, proximo evento

**Grade Semanal**:
Conjunto de aulas recorrentes do professor em cada dia da semana e horario.
_Avoid_: Agenda, calendario

**Turma**:
Grupo fixo de alunos de uma disciplina ou curso em um periodo letivo.
_Avoid_: Sala, classe, grupo

**Periodo letivo**:
Intervalo academico ao qual uma **Turma** pertence.
_Avoid_: Semestre, ano

**Disciplina**:
Componente curricular ministrado pelo professor para uma **Turma**.
_Avoid_: Curso, materia

**Aluno**:
Pessoa matriculada em uma **Turma** e esperada nas **Aulas** dessa turma.
_Avoid_: Estudante, participante

**Foto do aluno**:
Imagem opcional usada para reconhecer visualmente um **Aluno** na **Chamada**.
_Avoid_: Avatar, retrato

**Chamada**:
Registro de presenca dos **Alunos** em uma **Aula** especifica.
_Avoid_: Frequencia, lista de presenca

**Chamada aberta**:
**Chamada** em andamento que pode receber marcacoes e correcoes livremente.
_Avoid_: Chamada ativa, chamada em edicao

**Chamada pendente**:
**Chamada** esperada para uma **Aula** que aconteceu, mas ainda nao foi fechada pelo professor.
_Avoid_: Aula ignorada, chamada atrasada

**Chamada fechada**:
**Chamada** concluida e preservada no historico.
_Avoid_: Chamada finalizada, chamada salva

**Correcao de chamada**:
Reabertura de uma **Chamada fechada** para ajustar marcacoes e fecha-la novamente.
_Avoid_: Auditoria, revisao

**Historico de chamada**:
Consulta das marcacoes preservadas a partir de **Chamadas fechadas**.
_Avoid_: Relatorio, boletim

**Percentual de presenca**:
Proporcao de **Presencas** de um **Aluno** no **Historico de chamada** de uma **Turma** e **Disciplina**.
_Avoid_: Nota, desempenho

**Exportacao de chamada**:
Saida do **Historico de chamada** para uso fora do app.
_Avoid_: Backup, impressao

**Ausencia**:
Estado inicial de um **Aluno** na **Chamada** ate que o professor registre outro estado.
_Avoid_: Nao marcado, pendente

**Presenca**:
Estado de um **Aluno** que compareceu a uma **Aula**.
_Avoid_: Confirmado, ok

**Atraso**:
Estado de um **Aluno** que compareceu a uma **Aula** depois do horario de inicio.
_Avoid_: Presenca parcial, chegou tarde

**Justificativa**:
Estado de um **Aluno** que nao compareceu a uma **Aula**, mas teve a ausencia explicada ou abonavel.
_Avoid_: Abono, falta justificada

## Relationships

- Uma **Aula** tem uma lista de alunos esperados.
- A **Aula atual** e determinada pelo horario do dispositivo e pela **Grade Semanal**.
- A **Proxima aula** e exibida quando nao existe **Aula atual**.
- A **Chamada** da **Proxima aula** pode ser iniciada manualmente antes do horario.
- Uma **Aula cancelada** nao tem **Chamada**, nao gera **Ausencia** e e ignorada no **Historico de chamada**.
- Cancelar uma **Aula** afeta apenas aquela ocorrencia e nao altera a **Grade Semanal**.
- Uma **Aula** pertence a exatamente uma **Turma**.
- Uma **Aula** pertence a exatamente uma **Disciplina**.
- Uma **Aula** tem exatamente uma **Chamada**.
- Uma **Chamada** pertence a exatamente uma **Aula**.
- Uma **Chamada** comeca com todos os **Alunos** em **Ausencia**.
- Uma **Aula** nao cancelada que passou sem **Chamada fechada** fica com **Chamada pendente**.
- Uma **Aula** pode ter no maximo uma **Chamada**; reabrir uma chamada corrige a mesma chamada.
- Uma **Chamada aberta** pode receber marcacoes e correcoes livremente.
- Uma **Chamada aberta** preserva cada marcacao automaticamente.
- Uma **Chamada fechada** fica preservada no historico e exige reabertura explicita para correcao.
- Fechar uma **Chamada** confirma como **Ausencia** todos os **Alunos** que nao foram marcados como **Presenca**, **Atraso** ou **Justificativa**.
- Uma **Correcao de chamada** reabre a mesma **Chamada** e nao cria uma segunda chamada para a **Aula**.
- O **Historico de chamada** e formado por **Chamadas fechadas**.
- O **Historico de chamada** pode ser consultado por **Aula**, **Aluno**, **Turma** ou **Disciplina**.
- O **Historico de chamada** pode mostrar o **Percentual de presenca** por **Aluno** em uma **Turma** e **Disciplina**.
- **Atraso** conta como comparecimento no **Percentual de presenca**, mas aparece separado no detalhamento.
- **Justificativa** nao conta como **Presenca** no **Percentual de presenca**, mas aparece separada de **Ausencia** comum.
- Uma **Chamada pendente** nao entra no **Historico de chamada** ate ser fechada.
- A **Exportacao de chamada** usa os dados do **Historico de chamada**.
- Um **Aluno** em uma **Chamada** pode estar em **Presenca**, **Ausencia**, **Atraso** ou **Justificativa**.
- O MVP pertence a um unico **Professor** e nao tem contas de outros usuarios.
- Uma **Turma** pode ter varias **Disciplinas** ministradas pelo professor.
- Uma **Turma** pertence a exatamente um **Periodo letivo**.
- Um **Periodo letivo** pode ter data inicial e data final opcionais.
- Uma **Disciplina** pode ser ministrada para varias **Turmas**.
- Uma **Turma** define a lista padrao de **Alunos** esperados para suas **Aulas**.
- Um **Aluno** pode aparecer em varias **Disciplinas** quando elas pertencem a mesma **Turma**.
- No MVP, todos os **Alunos** de uma **Turma** aparecem em todas as **Disciplinas** dessa turma.
- No MVP, a lista de **Alunos** da **Turma** e tratada como estavel depois que as **Chamadas** comecam; entrada, remocao e transferencia ficam fora do escopo inicial.
- Marcar um **Aluno** na **Chamada** transforma sua **Ausencia** em **Presenca**, salvo quando o professor escolhe **Atraso** ou **Justificativa**.
- Um **Aluno** pode existir sem **Foto do aluno**.
- A **Grade Semanal** define quando uma **Disciplina** acontece para uma **Turma**.
- Para existir uma **Aula** na **Grade Semanal**, ela precisa estar ligada a uma **Turma** e a uma **Disciplina**.
- Uma **Chamada** util exige uma **Turma** com **Alunos** cadastrados.
- O intervalo de inicio e fim define a unidade de uma **Aula** na **Grade Semanal**.
- Intervalos sem aula nao sao modelados; eles sao apenas espacos entre itens da **Grade Semanal**.

## Example dialogue

> **Dev:** "Quando o professor abre o app, ele escolhe uma aula manualmente?"
> **Domain expert:** "Nao. O app deve abrir direto na **Aula atual**; se nao houver aula agora, deve mostrar a proxima aula do dia."
> **Dev:** "A lista de chamada fica cadastrada na aula?"
> **Domain expert:** "Nao. A **Aula** usa a lista padrao da **Turma**."
> **Dev:** "PAM2 e WEB2 sao turmas diferentes?"
> **Domain expert:** "Nao. PAM2 e WEB2 sao **Disciplinas** que posso ministrar para a mesma **Turma**, como DS3."
> **Dev:** "A presenca em PAM2 vale automaticamente para WEB2 no mesmo dia?"
> **Domain expert:** "Nao. Cada **Aula** tem sua propria **Chamada**."
> **Dev:** "Alunos ainda nao tocados ficam pendentes?"
> **Domain expert:** "Nao. A **Chamada** comeca com todos em **Ausencia** por padrao."
> **Dev:** "Atraso e justificativa contam como a mesma coisa?"
> **Domain expert:** "Nao. **Atraso** significa que o aluno veio depois do inicio; **Justificativa** significa que ele nao veio, mas a ausencia foi explicada."
> **Dev:** "Qual e a acao principal durante a chamada?"
> **Domain expert:** "Tocar no **Aluno** para trocar de **Ausencia** para **Presenca**; **Atraso** e **Justificativa** sao escolhas explicitas."
> **Dev:** "O cadastro do **Aluno** precisa guardar idade?"
> **Domain expert:** "Nao. Para este app, o **Aluno** e identificado por nome e foto."
> **Dev:** "E se o **Aluno** ainda nao tiver foto?"
> **Domain expert:** "Ele continua cadastrado; a interface pode representar o aluno pelas iniciais."
> **Dev:** "Como a **Foto do aluno** entra no app?"
> **Domain expert:** "No Android, por camera ou galeria; na Web, por camera ou upload."
> **Dev:** "De onde vem a aula que aparece ao abrir o app?"
> **Domain expert:** "Da **Grade Semanal** cadastrada manualmente e do horario atual do dispositivo."
> **Dev:** "O que aparece se nenhuma aula estiver acontecendo agora?"
> **Domain expert:** "O app mostra a **Proxima aula**, preferindo outra aula de hoje; se nao houver, a proxima aula futura da grade."
> **Dev:** "Posso adiantar uma chamada antes do horario?"
> **Domain expert:** "Sim. A **Proxima aula** pode ter sua **Chamada** iniciada manualmente."
> **Dev:** "Depois de passar a chamada, ela continua editavel sem limite?"
> **Domain expert:** "Nao. Ela vira uma **Chamada fechada** no historico; para corrigir, preciso reabrir explicitamente."
> **Dev:** "Preciso salvar manualmente cada presenca?"
> **Domain expert:** "Nao. A **Chamada aberta** salva cada marcacao automaticamente; eu fecho a chamada quando terminar."
> **Dev:** "Ao fechar a chamada, quem ficou ausente continua como falta?"
> **Domain expert:** "Sim. Fechar a **Chamada** confirma as **Ausencias** restantes."
> **Dev:** "Como corrijo uma chamada antiga?"
> **Domain expert:** "Eu reabro a mesma **Chamada**, ajusto as marcacoes e fecho de novo."
> **Dev:** "De onde vem o historico de um aluno?"
> **Domain expert:** "Das **Chamadas fechadas** em que esse **Aluno** aparece."
> **Dev:** "O historico precisa calcular presenca?"
> **Domain expert:** "Sim. Ele mostra o **Percentual de presenca** por **Aluno** em cada **Turma** e **Disciplina**."
> **Dev:** "Atraso entra no percentual?"
> **Domain expert:** "Sim. **Atraso** conta como comparecimento, mas fica separado no detalhamento; **Justificativa** nao conta como presenca."
> **Dev:** "O que sai do app para usar em planilha?"
> **Domain expert:** "Uma **Exportacao de chamada** em CSV gerada a partir do **Historico de chamada**."
> **Dev:** "Qual e o minimo antes de passar uma chamada?"
> **Domain expert:** "Preciso de uma **Turma**, suas **Disciplinas**, seus **Alunos** e a **Grade Semanal**."
> **Dev:** "WEB2 pode ter uma lista de alunos diferente de PAM2 na mesma **Turma**?"
> **Domain expert:** "No MVP, nao. Todos os **Alunos** da **Turma** aparecem em todas as **Disciplinas** dessa turma."
> **Dev:** "E se entrar aluno novo depois de ja existir chamada fechada?"
> **Domain expert:** "Isso fica fora do MVP; a lista de **Alunos** da **Turma** e considerada estavel quando as **Chamadas** comecam."
> **Dev:** "E se um aluno sair ou mudar de turma depois?"
> **Domain expert:** "Tambem fica fora do MVP."
> **Dev:** "O app precisa separar dados por usuario?"
> **Domain expert:** "Nao. O MVP e pessoal, de um unico **Professor**."
> **Dev:** "Uma aula dupla deve gerar duas chamadas automaticamente?"
> **Domain expert:** "Nao. Uma **Aula** e o intervalo cadastrado na **Grade Semanal**; duas chamadas exigem dois intervalos cadastrados."
> **Dev:** "O recreio precisa aparecer na grade?"
> **Domain expert:** "Nao. Intervalos sem aula sao apenas espacos entre itens da **Grade Semanal**."
> **Dev:** "Feriado ou aula cancelada vira falta para todo mundo?"
> **Domain expert:** "Nao. Uma **Aula cancelada** nao tem **Chamada**, nao gera **Ausencia** e e ignorada no historico de presenca."
> **Dev:** "E se uma aula passou e eu nao fiz chamada?"
> **Domain expert:** "Se nao foi cancelada, ela fica com **Chamada pendente** ate eu fechar a chamada."
> **Dev:** "Posso criar duas chamadas para a mesma **Aula**?"
> **Domain expert:** "Nao. Cada **Aula** tem no maximo uma **Chamada**; correcoes reabrem a mesma chamada."
> **Dev:** "Cancelar uma aula de terca cancela todas as tercas?"
> **Domain expert:** "Nao. Cancela apenas aquela ocorrencia; a **Grade Semanal** continua igual."
> **Dev:** "PAM2 precisa ser cadastrada de novo para cada turma?"
> **Domain expert:** "Nao. A **Disciplina** pode ser reutilizada em varias **Turmas**."
> **Dev:** "DS3 de 2026/1 e DS3 de outro periodo sao a mesma turma?"
> **Domain expert:** "Nao. A **Turma** pertence a um **Periodo letivo**, como 2026/1."
> **Dev:** "A grade continua gerando aulas fora do semestre?"
> **Domain expert:** "Se o **Periodo letivo** tiver datas de inicio e fim, nao. Se nao tiver, a **Grade Semanal** continua valendo."

## Flagged ambiguities

- "aula que eu teria naquele horario" foi resolvido como **Aula atual**, determinada pelo relogio do dispositivo.
- "curso" foi usado para PAM2 e WEB2, mas neste contexto o termo canonico e **Disciplina**; DS3 e a **Turma**.
- "sem marcacao" foi rejeitado como estado de dominio; a **Chamada** comeca em **Ausencia**.
- "idade" foi removida do cadastro de **Aluno**; o app deve usar nome e foto.

## UI & Layout Guidelines

1. **Responsabilidade unica**: Cada tela tem uma unica responsabilidade.
2. **Navegacao linear**: Nunca usar pop-ups ou modais, sempre usar telas inteiras para interacoes e dialogos.
3. **Estrutura base**: As telas devem ser definidas em termos de layout de coluna unica, com linhas que ocupem a largura toda da tela.
4. **Sub-elementos**: Os sub-elementos podem se organizar dentro do layout usando quebras como 20%/50%/30% ou 2/3 + 1/3.
