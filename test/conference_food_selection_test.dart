import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vowora/models/conference/conference_provider.dart';
import 'package:vowora/screens/conference/conference_booking_selection_sheet.dart';

void main() {
  testWidgets('restaurant details show a photo and readable meal tabs', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const provider = ConferenceProvider(
      id: 'food_test',
      name: 'Test Restaurant',
      category: 'food',
      city: 'Sylhet',
      address: 'Sylhet',
      description: 'Explore the menu for your event.',
      imageUrl: '',
      startingPrice: 180,
      details: {'minimum_guests': 20},
      isDemo: true,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ConferenceBookingSelectionSheet(provider: provider),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Test Restaurant'), findsOneWidget);
    expect(find.byIcon(Icons.restaurant_rounded), findsOneWidget);
    expect(find.text('Minimum guests: 20'), findsOneWidget);

    final breakfastFinder = find.ancestor(
      of: find.text('Breakfast'),
      matching: find.byType(ChoiceChip),
    );
    final lunchFinder = find.ancestor(
      of: find.text('Lunch'),
      matching: find.byType(ChoiceChip),
    );
    var breakfast = tester.widget<ChoiceChip>(breakfastFinder);
    var lunch = tester.widget<ChoiceChip>(lunchFinder);
    expect(breakfast.selected, isFalse);
    expect(breakfast.backgroundColor, const Color(0xFFF0E6DD));
    expect(breakfast.labelStyle?.color, const Color(0xFF3E2C26));
    expect(lunch.selected, isTrue);
    expect(lunch.selectedColor, const Color(0xFFE8BF52));
    expect(lunch.labelStyle?.color, const Color(0xFF3E2C26));

    await tester.tap(find.text('Breakfast'));
    await tester.pump();
    breakfast = tester.widget<ChoiceChip>(breakfastFinder);
    expect(breakfast.selected, isTrue);
    expect(tester.takeException(), isNull);
  });
}
