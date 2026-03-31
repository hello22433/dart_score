import 'package:flutter_test/flutter_test.dart';

import 'package:dart_score/main.dart';

void main() {
  testWidgets('App shows title', (WidgetTester tester) async {
    await tester.pumpWidget(const DartScoreApp());
    expect(find.text('다트 경기'), findsOneWidget);
  });
}
