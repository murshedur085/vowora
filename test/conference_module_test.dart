import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vowora/data/conference/conference_seed_data.dart';
import 'package:vowora/models/conference/conference_event.dart';
import 'package:vowora/services/conference_repository.dart';
import 'package:vowora/widgets/conference_progress_indicator.dart';

void main() {
  testWidgets('all six conference steps fit in the progress indicator', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(18),
            child: ConferenceProgressIndicator(
              labels: ConferenceServiceCategory.steps
                  .map((step) => step.label)
                  .toList(),
              currentIndex: 0,
              bookedCategories: const {},
              skippedCategories: const {},
              onStepSelected: (_) {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('Step 1 of 6'), findsOneWidget);
    expect(find.text('Halls'), findsOneWidget);
    expect(find.text('Food'), findsOneWidget);
    expect(find.text('Sound'), findsOneWidget);
    expect(find.text('Decor'), findsOneWidget);
    expect(find.text('Photo'), findsOneWidget);
    expect(find.text('Transport'), findsOneWidget);
  });

  group('Conference planning calculations', () {
    test('conference codes are exactly five digits', () {
      for (var index = 0; index < 100; index++) {
        expect(
          ConferenceRepository.generateConferenceCode(),
          matches(RegExp(r'^\d{5}$')),
        );
      }
    });

    test('food quantities are independent and calculate per item', () {
      final total = ConferenceOrderMath.foodTotal([
        {'unit_price': 250, 'quantity': 20},
        {'unit_price': 40, 'quantity': 20},
        {'unit_price': 80, 'quantity': 10},
      ]);

      expect(total, 6600);
    });

    test('transport calculates price by quantity and rental days', () {
      final total = ConferenceOrderMath.transportTotal([
        {'price_per_day': 8000, 'quantity': 2, 'days': 2},
        {'price_per_day': 12000, 'quantity': 1, 'days': 2},
      ]);

      expect(total, 56000);
    });

    test('the service workflow contains all six categories in order', () {
      expect(ConferenceServiceCategory.steps.map((step) => step.key).toList(), [
        'hall',
        'food',
        'sound',
        'decoration',
        'photography',
        'transportation',
      ]);
    });

    test('seed adapter preserves the expected demo provider counts', () {
      expect(ConferenceSeedData.halls, hasLength(9));
      expect(ConferenceSeedData.foods, hasLength(10));
      expect(ConferenceSeedData.sounds, hasLength(10));
      expect(ConferenceSeedData.decorations, hasLength(10));
      expect(ConferenceSeedData.photography, hasLength(10));
      expect(ConferenceSeedData.transport, hasLength(10));
      expect(ConferenceSeedData.halls.first['id'], 'hall_01');
      expect(ConferenceSeedData.transport.last['id'], 'transport_10');
    });

    test(
      'hall seeds have city-specific images and three priced time slots',
      () async {
        final dhakaHalls = await ConferenceRepository.getProviders(
          category: 'hall',
          city: 'Dhaka',
        );
        final sylhetHalls = await ConferenceRepository.getProviders(
          category: 'hall',
          city: 'Sylhet',
        );

        expect(dhakaHalls, hasLength(3));
        expect(sylhetHalls, hasLength(6));
        expect(
          ConferenceSeedData.halls.map((hall) => hall['image']).toSet(),
          hasLength(9),
        );
        for (final hall in ConferenceSeedData.halls) {
          final packages = hall['packages'] as List;
          expect(packages.map((package) => package['name']), [
            'Basic',
            'Standard',
            'Premium',
          ]);
          expect(packages.map((package) => package['duration']), [
            'Morning to evening',
            'Evening to late night',
            'Full day',
          ]);
          expect(packages.every((package) => package['price'] is num), isTrue);
        }
      },
    );

    test('restaurant updates preserve the existing menu records', () async {
      final sylhetRestaurants = await ConferenceRepository.getProviders(
        category: 'food',
        city: 'Sylhet',
      );
      final dhakaRestaurants = await ConferenceRepository.getProviders(
        category: 'food',
        city: 'Dhaka',
      );

      expect(sylhetRestaurants, hasLength(3));
      expect(dhakaRestaurants, hasLength(7));
      expect(ConferenceSeedData.foods.take(6).map((food) => food['name']), [
        'Unnoon Restaurant',
        'Wok Restaurant',
        'La Bistro',
        'Ozz Cafe',
        'Attitude Restaurant at Holiday Inn Dhaka',
        'The Grand Kitchen',
      ]);
      expect(
        ConferenceSeedData.foods
            .take(6)
            .every(
              (food) =>
                  (food['image'] as String).startsWith('https://iili.io/'),
            ),
        isTrue,
      );
      expect(ConferenceSeedData.foodItems, hasLength(28));
      expect(ConferenceSeedData.foodItems.first['name'], 'Kacchi Biryani');
      expect(ConferenceSeedData.foodItems.first['price'], 250);
      expect(ConferenceSeedData.foodItems.last['name'], 'Jorda');
      expect(ConferenceSeedData.foodItems.last['price'], 70);
      expect(
        ConferenceSeedData.foodItems.every(
          (item) => !item.containsKey('image_url'),
        ),
        isTrue,
      );
      for (final restaurant in ConferenceSeedData.foods) {
        final packages = restaurant['packages'] as Map<String, dynamic>;
        expect((packages['breakfast'] as List), hasLength(5));
        expect((packages['lunch'] as List), hasLength(12));
        expect((packages['dinner'] as List), hasLength(11));
      }
    });

    test('conference service providers use the supplied cities and images', () async {
      final expected = <String, List<String>>{
        'sound': [
          'Silsila',
          'RJ Sound & Screens',
          'The Sylhet Sound',
          'After Party Sound & Screens',
          'Selvent Planner',
          'Dhaka International Sound',
        ],
        'decoration': [
          'Sessions Decor',
          'A2Z Event',
          'Topflight',
          'Event Esyfyn',
          'Avalon',
          'RB Events',
        ],
        'photography': [
          'Dero',
          'Media Hub',
          'Pro Shooters',
          'Story and Lens',
          'Open Studio',
          'Product Shine',
        ],
        'transportation': [
          'JatriBondhu Transport',
          'Royal Route Transport',
          'DeshRide Transport',
          'BanglaWay Travels',
          'Nirapod Journey',
          'DeshLink Mobility',
        ],
      };

      for (final entry in expected.entries) {
        final records = switch (entry.key) {
          'sound' => ConferenceSeedData.sounds,
          'decoration' => ConferenceSeedData.decorations,
          'photography' => ConferenceSeedData.photography,
          'transportation' => ConferenceSeedData.transport,
          _ => const <Map<String, dynamic>>[],
        };
        expect(
          records.take(6).map((provider) => provider['name']).toList(),
          entry.value,
        );
        expect(
          records.take(6).every(
            (provider) =>
                (provider['image'] as String).startsWith('https://iili.io/'),
          ),
          isTrue,
        );

        final sylhet = await ConferenceRepository.getProviders(
          category: entry.key,
          city: 'Sylhet',
        );
        final dhaka = await ConferenceRepository.getProviders(
          category: entry.key,
          city: 'Dhaka',
        );
        expect(sylhet, hasLength(3), reason: entry.key);
        expect(dhaka, hasLength(7), reason: entry.key);
      }
    });

    test('sound and photography packages show the requested tiers', () {
      final soundPackages = ConferenceSeedData.sounds.first['packs'] as List;
      expect(soundPackages.map((package) => package['name']), [
        'Basic',
        'Standard',
        'Premium',
      ]);
      expect(
        soundPackages.every(
          (package) =>
              package['price'] is num &&
              (package['details'] as String).isNotEmpty,
        ),
        isTrue,
      );

      final photographyPackages =
          ConferenceSeedData.photography.first['packs'] as List;
      expect(photographyPackages.map((package) => package['name']), [
        'Basic',
        'Standard',
        'Premium',
      ]);
      expect(
        photographyPackages.every(
          (package) =>
              package['price'] is num &&
              package['photographers'] is num &&
              package['videographers'] is num &&
              package['camera_count'] is num &&
              package['camera_count_is_sample'] == true &&
              package['drone'] is bool &&
              (package['details'] as String).contains('sample estimate'),
        ),
        isTrue,
      );
      expect(
        ConferenceSeedData.photography.every(
          (provider) {
            final packages = provider['packs'] as List;
            final socialLinks = provider['social_links'] as List;
            return provider['contact_is_sample'] == true &&
                provider['contact_phone'] == '+880 0000 000000' &&
                socialLinks.single.toString().startsWith(
                  'https://example.invalid/',
                ) &&
                packages.every(
                  (package) =>
                      package['videographers'] is num &&
                      package['camera_count'] is num &&
                      package['camera_count_is_sample'] == true,
                );
          },
        ),
        isTrue,
      );
    });

    test('transport packages include editable vehicle quantities and rates', () async {
      final packages = ConferenceSeedData.transport.first['packages'] as List;
      expect(packages.map((package) => package['name']), [
        'Basic',
        'Standard',
        'Premium',
      ]);
      expect(packages[0]['vehicle_quantities'], {'v01': 1});
      expect(packages[1]['vehicle_quantities'], {'v02': 1, 'v03': 1});
      expect(packages[2]['vehicle_quantities'], {
        'v02': 1,
        'v03': 1,
        'v05': 1,
        'v06': 1,
      });

      final sylhetProviders = await ConferenceRepository.getProviders(
        category: 'transportation',
        city: 'Sylhet',
      );
      expect(sylhetProviders.first.startingPrice, 3500);
      expect(sylhetProviders.first.details['vehicles'], hasLength(6));
    });
  });
}
