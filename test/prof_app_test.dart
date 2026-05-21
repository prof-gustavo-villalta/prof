import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prof/main.dart';
import 'package:prof/data/prof_repository.dart';

void main() {
  testWidgets('professor configura turma e fecha uma chamada', (
    WidgetTester tester,
  ) async {
    final repository = InMemoryProfRepository();

    await tester.pumpWidget(
      ProfApp(repository: repository, now: DateTime(2026, 5, 21, 19)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Primeira turma'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('onboarding_turma')),
      'DS3',
    );
    await tester.enterText(
      find.byKey(const ValueKey('onboarding_periodo')),
      '2026/1',
    );
    await tester.enterText(
      find.byKey(const ValueKey('onboarding_disciplina')),
      'PAM2',
    );
    await tester.enterText(
      find.byKey(const ValueKey('onboarding_alunos')),
      'Ana Silva\nBruno Costa',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('onboarding_submit')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const ValueKey('onboarding_submit')));
    await tester.pumpAndSettle();

    expect(find.text('Hoje'), findsWidgets);
    expect(find.byKey(const ValueKey('start_attendance')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('start_attendance')));
    await tester.pumpAndSettle();

    expect(find.text('Ana Silva'), findsOneWidget);
    expect(find.text('Bruno Costa'), findsOneWidget);
    expect(find.text('Ausente'), findsWidgets);

    await tester.tap(find.byKey(const ValueKey('student_Ana Silva')));
    await tester.pumpAndSettle();

    expect(find.text('Presente'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('close_attendance')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Historico'));
    await tester.pumpAndSettle();

    expect(find.text('Ana Silva'), findsOneWidget);
    expect(find.text('100%'), findsOneWidget);
    expect(find.text('Bruno Costa'), findsOneWidget);
    expect(find.text('0%'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('copy_csv')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const ValueKey('copy_csv')));
    await tester.pump(const Duration(milliseconds: 750));
    expect(find.text('CSV pronto para copiar'), findsOneWidget);
  });
}
