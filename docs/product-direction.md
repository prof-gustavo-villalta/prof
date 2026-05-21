# Product Direction

## Visual direction

The app should feel close to Any.do: light background, generous whitespace, clean cards, soft borders, readable typography, discreet status colors and one obvious primary action on each screen.

The main navigation for the MVP should be simple: Hoje, Turmas, Historico and Ajustes.

The MVP interface is fixed in Brazilian Portuguese, using domain terms such as Hoje, Turmas, Disciplinas, Chamada, Historico, Ajustes, Presente, Ausente, Atraso and Justificado.

The MVP does not require PIN, password or login before use.

## Onboarding

When the app has no data, it guides the professor through the minimum setup: create the first Turma, create the first Disciplina, add students and create the first Grade Semanal entry. After setup, the app opens on Hoje.

## Hoje

The Hoje screen opens focused on the Aula atual or Proxima aula, with the primary attendance action visible. Other aulas from the same day appear below as a compact list.

Chamadas pendentes appear on Hoje in a dedicated Pendentes section below the current/next class area.

A monthly or weekly visual calendar is outside the MVP; Hoje, Grade Semanal editing and Historico are enough for the first version.

## Historico

The MVP CSV export is summarized by student for a Turma and Disciplina, with columns: Aluno, Turma, Disciplina, Periodo letivo, Aulas chamadas, Presencas, Atrasos, Ausencias, Justificativas and Percentual de presenca. Detailed per-date export is outside the initial scope.

## Chamada

The attendance list is mobile-first on every target. It uses a vertical list for Android and Web instead of switching to a desktop grid.

The attendance list includes a discreet student search field and quick filters by status: Todos, Presentes, Ausentes, Atrasos and Justificados.

Students appear alphabetically by name in the attendance list.

Per-student notes are outside the MVP; the attendance card should stay focused on status marking.

## Turmas

Student setup should support both individual registration and bulk creation by pasting one student name per line. Bulk-created students can receive photos later.

Periodo letivo is entered as free text, such as "2026/1", "2026/2" or "2026 anual", because school calendars vary.
