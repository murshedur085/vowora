class BirthdayVenue {
  final String id;
  final String name;
  final String imageUrl;
  final String location;
  final String cuisineType;
  final String seatingCapacity;
  final double estimatedPrice;
  final String description;

  const BirthdayVenue({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.location,
    required this.cuisineType,
    required this.seatingCapacity,
    required this.estimatedPrice,
    required this.description,
  });

  String get bookingAddress => '$name, $location';

  static const List<BirthdayVenue> sampleListings = [
    BirthdayVenue(
      id: 'panshi-restaurant',
      name: 'Panshi Restaurant',
      imageUrl:
          'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=1200&q=85',
      location: 'Zindabazar area, Sylhet (sample listing)',
      cuisineType: 'Bangladeshi and local favorites (sample)',
      seatingCapacity: 'About 80–120 guests (demo estimate)',
      estimatedPrice: 18000,
      description:
          'A sample venue option for a relaxed birthday meal. Contact the restaurant directly to confirm its location, menu, availability, and pricing.',
    ),
    BirthdayVenue(
      id: 'pach-bhai-restaurant',
      name: 'Pach Bhai Restaurant',
      imageUrl:
          'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?auto=format&fit=crop&w=1200&q=85',
      location: 'Zindabazar area, Sylhet (sample listing)',
      cuisineType: 'Bangladeshi and regional dishes (sample)',
      seatingCapacity: 'About 60–100 guests (demo estimate)',
      estimatedPrice: 16000,
      description:
          'A sample restaurant listing for birthday dining. Details shown here are illustrative and are not confirmed by the restaurant.',
    ),
    BirthdayVenue(
      id: 'meatup',
      name: 'MEATUP',
      imageUrl:
          'https://images.unsplash.com/photo-1514933651103-005eec06c04b?auto=format&fit=crop&w=1200&q=85',
      location: 'Sylhet city (sample listing)',
      cuisineType: 'Grill and meat dishes (sample)',
      seatingCapacity: 'About 40–80 guests (demo estimate)',
      estimatedPrice: 22000,
      description:
          'A sample grill-focused venue option. Confirm event arrangements and all details directly with the restaurant.',
    ),
    BirthdayVenue(
      id: 'the-mad-grill',
      name: 'The Mad Grill',
      imageUrl:
          'https://images.unsplash.com/photo-1552566626-52f8b828add9?auto=format&fit=crop&w=1200&q=85',
      location: 'Sylhet city (sample listing)',
      cuisineType: 'Grill and contemporary dining (sample)',
      seatingCapacity: 'About 40–80 guests (demo estimate)',
      estimatedPrice: 24000,
      description:
          'A sample contemporary dining option for a birthday celebration. The image is illustrative, not a photo of this restaurant.',
    ),
    BirthdayVenue(
      id: 'yokoso',
      name: 'Yōkoso',
      imageUrl:
          'https://images.unsplash.com/photo-1559339352-11d035aa65de?auto=format&fit=crop&w=1200&q=85',
      location: 'Sylhet city (sample listing)',
      cuisineType: 'Japanese-inspired dishes (sample)',
      seatingCapacity: 'About 30–60 guests (demo estimate)',
      estimatedPrice: 26000,
      description:
          'A sample Japanese-inspired dining option. Please verify cuisine, capacity, and event availability with the restaurant.',
    ),
    BirthdayVenue(
      id: 'woondaal-king-kebab',
      name: 'Woondaal King Kebab',
      imageUrl:
          'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=1200&q=85',
      location: 'Sylhet city (sample listing)',
      cuisineType: 'Kebab and grilled dishes (sample)',
      seatingCapacity: 'About 50–90 guests (demo estimate)',
      estimatedPrice: 20000,
      description:
          'A sample kebab-and-grill venue option. Contact the restaurant directly for current event information.',
    ),
    BirthdayVenue(
      id: 'nawabs-kitchen',
      name: "Nawab's Kitchen",
      imageUrl:
          'https://images.unsplash.com/photo-1550966871-3ed3cdb5ed0c?auto=format&fit=crop&w=1200&q=85',
      location: 'Sylhet city (sample listing)',
      cuisineType: 'South Asian and Bangladeshi dishes (sample)',
      seatingCapacity: 'About 50–90 guests (demo estimate)',
      estimatedPrice: 19000,
      description:
          "A sample dining option for birthday groups. Listing details and estimated price are demo information only.",
    ),
    BirthdayVenue(
      id: 'seasons-meat-grill',
      name: 'SEASONS Meat & Grill',
      imageUrl:
          'https://images.unsplash.com/photo-1555992336-03a23c7b20ee?auto=format&fit=crop&w=1200&q=85',
      location: 'Sylhet city (sample listing)',
      cuisineType: 'Meat and grill dishes (sample)',
      seatingCapacity: 'About 40–80 guests (demo estimate)',
      estimatedPrice: 23000,
      description:
          'A sample meat-and-grill venue option. Verify all details and booking arrangements directly with the restaurant.',
    ),
  ];
}
