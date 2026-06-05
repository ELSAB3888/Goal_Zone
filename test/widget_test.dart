import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sports_booking_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const SportsBookingApp());
    expect(find.byType(MaterialApp), findsOneWidget);
    
    // Advance virtual clock to trigger the 3-second splash navigation timer
    await tester.pump(const Duration(seconds: 4));
  });
}
