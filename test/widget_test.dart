import 'package:flutter_test/flutter_test.dart';
import 'package:study_sprint/main.dart';

void main() {
  testWidgets('Study Sprint muestra el titulo principal',
      (WidgetTester tester) async {
    await tester.pumpWidget(const StudySprintApp());

    expect(find.text('Study Sprint'), findsOneWidget);
    expect(find.text('Organiza tu estudio con enfoque'), findsOneWidget);
    expect(find.text('Tareas'), findsOneWidget);
  });
}
