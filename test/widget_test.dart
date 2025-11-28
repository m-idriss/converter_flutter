// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:converter_flutter/main.dart';

void main() {
  testWidgets('App loads onboarding screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the onboarding screen shows the expected text.
    expect(find.text('Learn design & code'), findsOneWidget);
    expect(find.text('Start the course'), findsOneWidget);
  });
}
