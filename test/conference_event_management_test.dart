import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vowora/core/theme/vowora_theme.dart';
import 'package:vowora/models/conference/conference_event.dart';
import 'package:vowora/models/conference/conference_provider.dart';
import 'package:vowora/screens/conference/conference_create_screen.dart';
import 'package:vowora/screens/conference/conference_events_section.dart';
import 'package:vowora/screens/conference/conference_wizard_screen.dart';
import 'package:vowora/services/conference_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  testWidgets('conference form uses Moto and Finish opens the summary', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      MaterialApp(
        theme: VoworaTheme.lightTheme,
        home: const ConferenceCreateScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Moto'), findsOneWidget);
    expect(find.text('Slogan'), findsNothing);
    expect(find.text('Continue'), findsOneWidget);
    final motoDecorator = tester.widget<InputDecorator>(
      find.byType(InputDecorator).at(1),
    );
    expect(motoDecorator.decoration.labelStyle?.color, Colors.black);

    final event = await ConferenceRepository.createConference(
      title: 'Finish flow conference',
      slogan: 'A new moto',
      eventDate: DateTime(2027, 5, 12),
      organizerName: 'Organizer',
      organizerEmail: 'organizer@example.com',
      location: 'Sylhet',
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: VoworaTheme.lightTheme,
        home: ConferenceWizardScreen(
          conference: event,
          initialStep: ConferenceServiceCategory.steps.length - 1,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Finish'));
    await tester.pumpAndSettle();

    expect(find.text('Conference summary'), findsOneWidget);
    expect(
      tester.widget<Text>(find.text('Conference summary')).style?.color,
      Colors.black,
    );
    expect(tester.takeException(), isNull);
  });

  test(
    'conference details update and deletion clean up service selections',
    () async {
      SharedPreferences.setMockInitialValues({});
      final event = await ConferenceRepository.createConference(
        title: 'Original conference',
        slogan: 'Original slogan',
        eventDate: DateTime(2027, 5, 10),
        organizerName: 'Original organizer',
        organizerEmail: 'original@example.com',
        location: 'Dhaka',
      );

      final updated = await ConferenceRepository.updateConferenceDetails(
        event: event,
        title: 'Updated conference',
        slogan: 'Updated slogan',
        organizerName: 'Updated organizer',
        organizerEmail: 'updated@example.com',
        location: 'Sylhet',
      );

      expect(updated.title, 'Updated conference');
      expect(updated.slogan, 'Updated slogan');
      expect(updated.organizerName, 'Updated organizer');
      expect(updated.organizerEmail, 'updated@example.com');
      expect(updated.location, 'Sylhet');

      const provider = ConferenceProvider(
        id: 'photo_test',
        name: 'Test Photographer',
        category: 'photography',
        city: 'Sylhet',
        address: 'Sylhet',
        description: 'Test provider',
        imageUrl: '',
        startingPrice: 1000,
        details: {},
        isDemo: true,
      );
      await ConferenceRepository.saveBooking(
        event: updated,
        provider: provider,
        packageName: 'Basic',
        totalPrice: 1000,
        selectionDetails: const {'package': 'Basic'},
      );
      expect(await ConferenceRepository.getBookings(updated), hasLength(1));

      await ConferenceRepository.deleteConference(updated);

      expect(await ConferenceRepository.getConferences(), isEmpty);
      expect(await ConferenceRepository.getBookings(updated), isEmpty);
    },
  );

  testWidgets('conference events page lists newest events and deletes one', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await ConferenceRepository.createConference(
      title: 'Earlier conference',
      slogan: '',
      eventDate: DateTime(2027, 5, 10),
      organizerName: 'Organizer',
      organizerEmail: 'organizer@example.com',
      location: 'Dhaka',
    );
    await ConferenceRepository.createConference(
      title: 'Recent conference',
      slogan: 'Initial slogan',
      eventDate: DateTime(2027, 5, 11),
      organizerName: 'Organizer',
      organizerEmail: 'organizer@example.com',
      location: 'Sylhet',
    );

    await tester.pumpWidget(const MaterialApp(home: ConferenceEventsScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Recent conference'), findsOneWidget);
    expect(find.text('Earlier conference'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Recent conference')).dy,
      lessThan(tester.getTopLeft(find.text('Earlier conference')).dy),
    );

    await tester.tap(find.text('Recent conference'));
    await tester.pumpAndSettle();
    expect(find.text('Conference summary'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Edit Conference'), findsOneWidget);
    await tester.enterText(
      find.byType(TextFormField).first,
      'Updated recent conference',
    );
    await tester.drag(find.byType(ListView).last, const Offset(0, -900));
    await tester.pumpAndSettle();
    expect(find.text('Save changes'), findsOneWidget);
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();

    expect(find.text('Updated recent conference'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.delete_outline_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete conference'));
    await tester.pumpAndSettle();

    expect(find.text('Updated recent conference'), findsNothing);
    expect(find.text('Earlier conference'), findsOneWidget);
    expect(await ConferenceRepository.getConferences(), hasLength(1));
  });
}
