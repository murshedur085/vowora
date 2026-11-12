import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vowora/models/conference/conference_provider.dart';
import 'package:vowora/screens/conference/conference_booking_selection_sheet.dart';

void main() {
  testWidgets('hall selection shows its image and availability details', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const provider = ConferenceProvider(
      id: 'hall_test',
      name: 'Test Hall',
      category: 'hall',
      city: 'Sylhet',
      address: 'Sylhet',
      description: '',
      imageUrl: '',
      startingPrice: 35000,
      details: {
        'ac': true,
        'wifi': false,
        'policies': {
          'outside_food': true,
          'outside_decoration': true,
          'outside_sound': false,
        },
        'packages': [
          {'name': 'Basic', 'price': 35000, 'duration': 'Morning to evening'},
        ],
      },
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

    expect(find.byIcon(Icons.business_rounded), findsOneWidget);
    expect(find.text('Facilities & policies'), findsOneWidget);
    expect(find.text('AC support'), findsOneWidget);
    expect(find.text('Wi-Fi'), findsOneWidget);
    expect(find.text('Parking'), findsOneWidget);
    expect(find.text('Outside food'), findsOneWidget);
    expect(find.text('Outside decoration'), findsOneWidget);
    expect(find.text('Outside sound system'), findsOneWidget);
    expect(find.text('Available'), findsOneWidget);
    expect(find.text('Not available'), findsOneWidget);
    expect(find.text('Allowed'), findsNWidgets(2));
    expect(find.text('Not specified'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
