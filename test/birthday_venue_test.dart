import 'package:flutter_test/flutter_test.dart';
import 'package:vowora/models/birthday/birthday_venue.dart';
import 'package:vowora/providers/birthday_provider.dart';

void main() {
  test('sample venue catalog contains all requested restaurants', () {
    final names = BirthdayVenue.sampleListings.map((venue) => venue.name);

    expect(
      names,
      containsAll([
        'Panshi Restaurant',
        'Pach Bhai Restaurant',
        'MEATUP',
        'The Mad Grill',
        'Yōkoso',
        'Woondaal King Kebab',
        "Nawab's Kitchen",
        'SEASONS Meat & Grill',
      ]),
    );
    expect(BirthdayVenue.sampleListings, hasLength(8));

    for (final venue in BirthdayVenue.sampleListings) {
      expect(venue.imageUrl, startsWith('https://'));
      expect(venue.location, isNotEmpty);
      expect(venue.cuisineType, isNotEmpty);
      expect(venue.seatingCapacity, isNotEmpty);
      expect(venue.estimatedPrice, greaterThan(0));
    }
  });

  test('venue selection adds its sample price to the Birthday estimate', () {
    final provider = BirthdayProvider();
    final venue = BirthdayVenue.sampleListings.first;

    provider.selectBirthdayVenue(venue);

    expect(provider.selectedVenue, same(venue));
    expect(provider.cartSubtotal, venue.estimatedPrice);
    expect(
      provider.cartServiceFee,
      (venue.estimatedPrice * 0.03).roundToDouble(),
    );
    expect(provider.cartTotal, venue.estimatedPrice + provider.cartServiceFee);

    provider.clearBirthdayVenue();

    expect(provider.selectedVenue, isNull);
    expect(provider.cartTotal, 0);
  });
}
