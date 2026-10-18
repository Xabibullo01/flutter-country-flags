import 'package:flutter_test/flutter_test.dart';

import 'package:country_flags/main.dart';

void main() {
  testWidgets('App shows title and search field', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Davlat Bayroqlari'), findsOneWidget);
    expect(find.text('Qidiruv'), findsOneWidget);
  });
}
