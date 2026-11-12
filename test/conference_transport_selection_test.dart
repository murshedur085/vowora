import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vowora/models/conference/conference_provider.dart';
import 'package:vowora/screens/conference/conference_booking_selection_sheet.dart';

const _transportProvider = ConferenceProvider(
  id: 'transport_test',
  name: 'Test Transport',
  category: 'transportation',
  city: 'Sylhet',
  address: 'Sylhet',
  description: 'Choose vehicles for your event.',
  imageUrl: '',
  startingPrice: 3500,
  details: {
    'packages': [
      {
        'name': 'Basic',
        'vehicle_quantities': {'v01': 1},
      },
      {
        'name': 'Standard',
        'vehicle_quantities': {'v02': 1, 'v03': 1},
      },
    ],
    'vehicles': [
      {'id': 'v01', 'name': 'Sedan', 'capacity': 4, 'price_per_day': 3500},
      {
        'id': 'v02',
        'name': 'Premium Sedan',
        'capacity': 4,
        'price_per_day': 5500,
      },
      {'id': 'v03', 'name': 'Microbus', 'capacity': 12, 'price_per_day': 6500},
    ],
  },
  isDemo: true,
);

void main() {
  testWidgets('a single vehicle can be selected without a package', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    ConferenceBookingDraft? savedDraft;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () async {
                  savedDraft =
                      await showModalBottomSheet<ConferenceBookingDraft>(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) => const ConferenceBookingSelectionSheet(
                          provider: _transportProvider,
                        ),
                      );
                },
                child: const Text('Open transport'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open transport'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.airport_shuttle_outlined), findsOneWidget);
    expect(find.text('Phone number not provided'), findsOneWidget);
    expect(find.text('Social media links not provided'), findsOneWidget);
    expect(find.text('Vehicle packages (optional)'), findsOneWidget);
    final sedanTile = find.ancestor(
      of: find.text('Sedan'),
      matching: find.byType(ListTile),
    );
    final sedanAddButton = find.descendant(
      of: sedanTile,
      matching: find.byIcon(Icons.add_circle_outline),
    );
    await tester.ensureVisible(sedanAddButton);
    await tester.pumpAndSettle();
    await tester.tap(sedanAddButton);
    await tester.pump();

    expect(
      find.descendant(of: sedanTile, matching: find.text('1')),
      findsOneWidget,
    );
    expect(find.text('৳3500'), findsOneWidget);

    final pickupField = find.byType(TextField).at(0);
    await tester.ensureVisible(pickupField);
    await tester.enterText(pickupField, 'Event venue');
    final destinationField = find.byType(TextField).at(1);
    await tester.ensureVisible(destinationField);
    await tester.enterText(destinationField, 'Airport');
    expect(
      tester.widget<TextField>(pickupField).controller?.text,
      'Event venue',
    );
    expect(
      tester.widget<TextField>(destinationField).controller?.text,
      'Airport',
    );
    await tester.tap(find.text('Save selection'));
    await tester.pumpAndSettle();

    expect(
      find.text('Enter both pickup and destination locations.'),
      findsNothing,
    );
    expect(savedDraft, isNotNull);
    expect(savedDraft!.packageName, 'Custom vehicle selection');
    expect(savedDraft!.totalPrice, 3500);
    expect(savedDraft!.details['vehicles'], hasLength(1));
    expect(savedDraft!.details['vehicles'].single['quantity'], 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a vehicle package preselects its included editable vehicles', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ConferenceBookingSelectionSheet(provider: _transportProvider),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Standard'));
    await tester.pump();

    final sedanTile = find.ancestor(
      of: find.text('Premium Sedan'),
      matching: find.byType(ListTile),
    );
    final microbusTile = find.ancestor(
      of: find.text('Microbus'),
      matching: find.byType(ListTile),
    );
    expect(
      find.descendant(of: sedanTile, matching: find.text('1')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: microbusTile, matching: find.text('1')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
