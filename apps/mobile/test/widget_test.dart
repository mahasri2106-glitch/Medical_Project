import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders a basic smoke widget', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Text('MedBill'),
        ),
      ),
    );

    expect(find.text('MedBill'), findsOneWidget);
  });
}
