import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:unityhub_mobile/main.dart';

void main() {
  testWidgets('App boots into UnityHub shell', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: UnityHubApp(),
      ),
    );

    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('UnityHub'), findsWidgets);
  });
}
