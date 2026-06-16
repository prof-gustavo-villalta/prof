import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prof/data/diario_storage.dart';
import 'package:prof/main.dart';

void main() {
  testWidgets('professor cria e edita turma com periodo letivo e datas', (
    tester,
  ) async {
    final storage = InMemoryDiarioStorage();
    await tester.pumpWidget(
      ProfApp(storage: storage, now: DateTime(2026, 5, 21, 19)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('onboarding_submit')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Turmas'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Adicionar Turma'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('edit_group_name')),
      'DS4',
    );
    await tester.enterText(
      find.byKey(const ValueKey('edit_term_name')),
      '2026/2',
    );
    await tester.enterText(
      find.byKey(const ValueKey('edit_term_start')),
      '2026-08-01',
    );
    await tester.enterText(
      find.byKey(const ValueKey('edit_term_end')),
      '2026-11-30',
    );
    await tester.tap(find.byKey(const ValueKey('save_group')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('DS4'));
    await tester.pumpAndSettle();
    expect(find.textContaining('2026/2'), findsWidgets);

    final created = await storage.loadAll();
    final createdGroup = created.classGroups.singleWhere(
      (group) => group.name == 'DS4',
    );
    final createdTerm = created.terms.singleWhere(
      (term) => term.id == createdGroup.termId,
    );
    expect(createdTerm.startDate, DateTime(2026, 8));
    expect(createdTerm.endDate, DateTime(2026, 11, 30));

    await tester.tap(find.byKey(const ValueKey('edit_group')));
    await tester.pumpAndSettle();
    expect(find.text('2026-08-01'), findsOneWidget);
    expect(find.text('2026-11-30'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('edit_group_name')),
      'DS4 Manha',
    );
    await tester.tap(find.byKey(const ValueKey('save_group')));
    await tester.pumpAndSettle();

    expect(find.textContaining('DS4 Manha'), findsWidgets);
  });

  testWidgets(
    'professor edita turma e cria horario com turma e disciplina escolhidas',
    (tester) async {
      final storage = InMemoryDiarioStorage();
      await tester.pumpWidget(
        ProfApp(storage: storage, now: DateTime(2026, 5, 21, 19)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('onboarding_submit')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Turmas'));
      await tester.pumpAndSettle();

      // Navega para detalhe da turma DS3
      await tester.tap(find.text('DS3'));
      await tester.pumpAndSettle();

      expect(find.textContaining('DS3'), findsWidgets);
      expect(find.textContaining('2026/1'), findsWidgets);

      // Adiciona aluno na tela de detalhe
      await tester.tap(find.text('Adicionar'));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('add_students_field')),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.enterText(
        find.byKey(const ValueKey('add_students_field')),
        'Carla Rocha',
      );
      await tester.tap(find.byKey(const ValueKey('add_students_button')));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Carla Rocha'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Carla Rocha'), findsOneWidget);

      // Vai para Grade semanal
      await tester.tap(find.text('Grade'));
      await tester.pumpAndSettle();

      // Adiciona disciplina
      await tester.tap(find.text('Adicionar disciplina'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const ValueKey('new_discipline_name')),
        'WEB2',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.ensureVisible(find.byKey(const ValueKey('add_discipline')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('add_discipline')));
      await tester.pumpAndSettle();

      // Adiciona horário
      await tester.tap(find.text('Adicionar horário'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('schedule_discipline')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('WEB2').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('save_schedule')));
      await tester.pumpAndSettle();

      expect(find.textContaining('DS3 - WEB2'), findsOneWidget);

      // Edita horário
      await tester.drag(find.byType(Scrollable).first, const Offset(0, 600));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('edit_schedule_WEB2')).last);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('edit_schedule_start')),
        '21:00',
      );
      await tester.enterText(
        find.byKey(const ValueKey('edit_schedule_end')),
        '22:00',
      );
      await tester.tap(find.byKey(const ValueKey('save_schedule')));
      await tester.pumpAndSettle();

      expect(find.text('21:00 - 22:00'), findsOneWidget);

      // Remove horário
      await tester.tap(find.byKey(const ValueKey('edit_schedule_WEB2')).last);
      await tester.pumpAndSettle();

      final deleteButton = find.byKey(const ValueKey('delete_schedule'));
      expect(deleteButton, findsOneWidget);

      final gesture = await tester.startGesture(tester.getCenter(deleteButton));
      await tester.pumpAndSettle();
      await gesture.up();
      await tester.pumpAndSettle();

      expect(find.textContaining('DS3 - WEB2'), findsNothing);
    },
  );
}
