# Prof - Product Requirements Document

## Overview

Build a local-first mobile-first Flutter app for one Professor to organize Turmas, Disciplinas, Alunos, Grade Semanal and Chamadas.

The MVP is fixed in Brazilian Portuguese and uses the domain language from `CONTEXT.md`.

## Platform

- Flutter app targeting Android and Web first
- Local-first data storage
- No login, account, PIN or remote backend in MVP
- Mobile-first layouts on every target

## Navigation

Main navigation:

- Hoje
- Turmas
- Historico
- Ajustes

## Onboarding

When the app has no usable data, guide the Professor through minimum setup:

1. Create first Turma
2. Create first Disciplina
3. Add Alunos
4. Create first Grade Semanal entry

After setup, app opens on Hoje.

## Hoje

Hoje opens focused on:

- Aula atual when a Grade Semanal entry is happening according to device time
- Proxima aula when no Aula atual exists

Hoje must show one obvious primary Chamada action.

Other aulas from same day appear below as compact list.

Chamadas pendentes appear in a dedicated Pendentes section.

## Grade Semanal

Professor can create, edit and inspect Grade Semanal entries.

Each Grade Semanal entry needs:

- Turma
- Disciplina
- Day of week
- Start time
- End time

Periodo letivo may have optional start/end dates. If missing, Grade Semanal continues indefinitely.

## Turmas, Disciplinas, Alunos

Professor can:

- Create Turma with Periodo letivo free text
- Create reusable Disciplina
- Add Alunos individually
- Add Alunos in bulk by pasting one name per line
- Add Foto do aluno optionally later

MVP rule: all Alunos from a Turma appear in all Disciplinas for that Turma.

## Chamada

Chamada is tied to exactly one Aula.

Each Aula has at most one Chamada. Corrections reopen same Chamada.

Chamada starts with every Aluno as Ausencia.

Supported statuses:

- Presenca
- Ausencia
- Atraso
- Justificativa

Attendance list:

- Vertical list on Android and Web
- Alunos sorted alphabetically
- Search by Aluno name
- Filters: Todos, Presentes, Ausentes, Atrasos, Justificados
- Tapping Aluno toggles Ausencia -> Presenca
- Atraso and Justificativa are explicit choices
- Autosave every marking

Closing Chamada confirms remaining Ausencias.

Chamada fechada appears in Historico and requires explicit reopen for Correcao de chamada.

## Aula Cancelada

Professor can cancel one Aula occurrence.

Cancelled Aula:

- Does not require Chamada
- Does not create Ausencia
- Does not enter Historico de chamada
- Does not alter recurring Grade Semanal

## Chamadas Pendentes

If an Aula has passed and was not cancelled and has no Chamada fechada, it becomes Chamada pendente.

Chamada pendente does not enter Historico until closed.

## Historico

Historico is based only on Chamadas fechadas.

Historico can be viewed by:

- Aula
- Aluno
- Turma
- Disciplina

Show Percentual de presenca by Aluno for Turma + Disciplina.

Calculation:

- Presenca counts as attendance
- Atraso counts as attendance but remains separate in detail
- Justificativa does not count as attendance
- Ausencia does not count as attendance

## Exportacao de Chamada

CSV export is summarized by Aluno for one Turma and Disciplina.

Columns:

- Aluno
- Turma
- Disciplina
- Periodo letivo
- Aulas chamadas
- Presencas
- Atrasos
- Ausencias
- Justificativas
- Percentual de presenca

Detailed per-date export is outside MVP.

## Visual Direction

Interface should feel close to Any.do:

- Light background
- Generous whitespace
- Clean cards
- Soft borders
- Readable typography
- Discreet status colors
- One obvious primary action per screen

No pop-ups or modals for core workflows. Use full screens.

## Development Data

Development and tests should include demo data for:

- DS3
- PAM2
- WEB2
- Students with photos
- Students without photos

Demo data is not user-facing MVP.

## Feedback Loops

Every implementation slice must pass:

```powershell
npm run analyze
npm run test
```

## Implementation Notes

- Preserve existing architecture and domain model unless PRD requires change.
- Prefer small commits with user-visible behavior or focused domain logic.
- Keep docs in sync when domain language or process changes.
- Do not add remote services or auth to MVP.
