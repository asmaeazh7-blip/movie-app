import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/main.dart';

void main() {
  testWidgets('CineJoy splash screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(const CineJoyApp());
    await tester.pump();
    expect(find.byType(CineJoyApp), findsOneWidget);
  });
}