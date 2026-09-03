import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quraan/main.dart';

void main() {
  testWidgets('Quran App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const QuraanApp());
    await tester.pump();
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
