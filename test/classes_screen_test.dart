import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prof/data/prof_repository.dart';
import 'package:prof/main.dart';

void main() {
  testWidgets(
    'professor edita turma e cria horario com turma e disciplina escolhidas',
    (tester) async {
      final repository = InMemoryProfRepository();
      await tester.pumpWidget(
        ProfApp(repository: repository, now: DateTime(2026, 5, 21, 19)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('onboarding_submit')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Turmas'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('edit_group_DS3')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('edit_group_name')),
        'DS3 Noite',
      );
      await tester.enterText(
        find.byKey(const ValueKey('edit_term_name')),
        '2026/1 noite',
      );
      await tester.enterText(
        find.byKey(const ValueKey('edit_term_start')),
        '2026-02-01',
      );
      await tester.enterText(
        find.byKey(const ValueKey('edit_term_end')),
        '2026-06-30',
      );
      await tester.tap(find.byKey(const ValueKey('save_group')));
      await tester.pumpAndSettle();

      expect(find.text('DS3 Noite'), findsWidgets);
      expect(find.text('2026/1 noite'), findsWidgets);

      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('single_student_name')),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.enterText(
        find.byKey(const ValueKey('single_student_name')),
        'Carla Rocha',
      );
      await tester.tap(find.byKey(const ValueKey('add_single_student')));
      await tester.pumpAndSettle();
      expect(find.text('Carla Rocha'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('new_discipline_name')),
        -300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.enterText(
        find.byKey(const ValueKey('new_discipline_name')),
        'WEB2',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      await tester.ensureVisible(find.byKey(const ValueKey('add_discipline')));
      await tester.tap(find.byKey(const ValueKey('add_discipline')));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('schedule_discipline')),
        -300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.byKey(const ValueKey('schedule_discipline')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('WEB2').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('add_weekly_class')));
      await tester.pumpAndSettle();

      expect(find.textContaining('DS3 Noite - WEB2'), findsOneWidget);
    },
  );
}
