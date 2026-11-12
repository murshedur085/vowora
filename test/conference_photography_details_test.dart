import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vowora/services/conference_repository.dart';
import 'package:vowora/screens/conference/conference_booking_selection_sheet.dart';

void main() {
  testWidgets(
    'photography details show sample contacts and package crew counts',
    (tester) async {
      final providers = await ConferenceRepository.getProviders(
        category: 'photography',
        city: 'Sylhet',
      );
      final provider = providers.first;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConferenceBookingSelectionSheet(provider: provider),
          ),
        ),
      );
      await tester.pump();

      expect(
        find.text('Sample phone (not real): +880 0000 000000'),
        findsOneWidget,
      );
      expect(
        find.text(
          'Sample social link: https://example.invalid/photographers/photo_01',
        ),
        findsOneWidget,
      );
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();
      expect(find.textContaining('videographers'), findsNWidgets(3));
      expect(find.textContaining('camera'), findsNWidgets(3));
      expect(tester.takeException(), isNull);
    },
  );
}
