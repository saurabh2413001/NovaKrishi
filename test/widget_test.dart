import 'package:flutter_test/flutter_test.dart';
import 'package:novakrishi/main.dart';

void main() {
  testWidgets('NovaKrishi app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const NovaKrishiApp());

    expect(find.byType(NovaKrishiApp), findsOneWidget);
  });
}
