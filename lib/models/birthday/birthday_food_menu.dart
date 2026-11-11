/// Per-item food menu models for the Birthday food menu selection feature.
/// All menus here are SAMPLE / DEMO DATA until actual restaurant menus
/// and pricing are verified and confirmed with each restaurant.
library;

// ---------------------------------------------------------------------------
// ENUMS
// ---------------------------------------------------------------------------

/// High-level food section used for category filter tabs.
enum BirthdayFoodCategory {
  starters,
  mains,
  grills,
  desserts,
  drinks;

  String get displayName {
    switch (this) {
      case BirthdayFoodCategory.starters:
        return 'Starters';
      case BirthdayFoodCategory.mains:
        return 'Mains';
      case BirthdayFoodCategory.grills:
        return 'Grills';
      case BirthdayFoodCategory.desserts:
        return 'Desserts';
      case BirthdayFoodCategory.drinks:
        return 'Drinks';
    }
  }

  String get emoji {
    switch (this) {
      case BirthdayFoodCategory.starters:
        return '🥗';
      case BirthdayFoodCategory.mains:
        return '🍛';
      case BirthdayFoodCategory.grills:
        return '🔥';
      case BirthdayFoodCategory.desserts:
        return '🍰';
      case BirthdayFoodCategory.drinks:
        return '🥤';
    }
  }
}

// ---------------------------------------------------------------------------
// MODELS
// ---------------------------------------------------------------------------

/// A single food item on a restaurant menu.
class BirthdayFoodItem {
  final String id;
  final String restaurantId;
  final String name;
  final String description;
  final String imageUrl;
  final double price; // per serving / per piece as labelled
  final String priceLabel; // e.g. 'per portion', 'per piece'
  final BirthdayFoodCategory category;
  final bool isPopular;
  final bool isVegetarian;

  const BirthdayFoodItem({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    this.priceLabel = 'per portion',
    required this.category,
    this.isPopular = false,
    this.isVegetarian = false,
  });
}

/// A food item placed in the food cart with a chosen quantity.
class BirthdayFoodCartEntry {
  final BirthdayFoodItem item;
  int quantity;

  BirthdayFoodCartEntry({required this.item, this.quantity = 1});

  double get totalCost => item.price * quantity;

  Map<String, dynamic> toJson() => {
        'item_id': item.id,
        'item_name': item.name,
        'restaurant_id': item.restaurantId,
        'unit_price': item.price,
        'price_label': item.priceLabel,
        'quantity': quantity,
        'total_cost': totalCost,
      };
}

/// A restaurant's complete demo menu, containing categorised food items.
class BirthdayRestaurantMenu {
  final String restaurantId;
  final String restaurantName;
  final List<BirthdayFoodItem> items;

  const BirthdayRestaurantMenu({
    required this.restaurantId,
    required this.restaurantName,
    required this.items,
  });

  List<BirthdayFoodItem> itemsForCategory(BirthdayFoodCategory category) =>
      items.where((i) => i.category == category).toList();

  /// Returns the demo menu for the given restaurantId, or a generic menu
  /// if none exists yet. All prices are SAMPLE ESTIMATES only.
  static BirthdayRestaurantMenu forRestaurant(
    String restaurantId,
    String restaurantName,
  ) {
    final menus = _sampleMenus();
    return menus.firstWhere(
      (m) => m.restaurantId == restaurantId,
      orElse: () => _genericMenu(restaurantId, restaurantName),
    );
  }

  // -------------------------------------------------------------------------
  // SAMPLE DATA — demo prices and items; not verified with restaurants
  // -------------------------------------------------------------------------

  static List<BirthdayRestaurantMenu> _sampleMenus() {
    return [
      _panshiMenu(),
      _pachBhaiMenu(),
      _meatupMenu(),
      _madGrillMenu(),
      _yokokosoMenu(),
      _woondaalMenu(),
      _nawabsKitchenMenu(),
      _seasonsMenu(),
    ];
  }

  static BirthdayRestaurantMenu _panshiMenu() => const BirthdayRestaurantMenu(
        restaurantId: 'panshi-restaurant',
        restaurantName: 'Panshi Restaurant',
        items: [
          BirthdayFoodItem(
            id: 'panshi-s1',
            restaurantId: 'panshi-restaurant',
            name: 'Vegetable Singara (4 pcs)',
            description: 'Crispy fried pastry filled with spiced potato and vegetables.',
            imageUrl: 'https://images.unsplash.com/photo-1601050690597-df0568f70950?auto=format&fit=crop&w=600&q=80',
            price: 80,
            priceLabel: 'per 4 pcs',
            category: BirthdayFoodCategory.starters,
            isVegetarian: true,
          ),
          BirthdayFoodItem(
            id: 'panshi-s2',
            restaurantId: 'panshi-restaurant',
            name: 'Chicken Soup',
            description: 'Hearty Bangladeshi-style chicken clear soup with herbs.',
            imageUrl: 'https://images.unsplash.com/photo-1547592166-23ac45744acd?auto=format&fit=crop&w=600&q=80',
            price: 150,
            priceLabel: 'per bowl',
            category: BirthdayFoodCategory.starters,
          ),
          BirthdayFoodItem(
            id: 'panshi-m1',
            restaurantId: 'panshi-restaurant',
            name: 'Chicken Roast with Polao',
            description: 'Aromatic Basmati Polao served with slow-roasted whole chicken and borhani.',
            imageUrl: 'https://images.unsplash.com/photo-1565557623262-b51c2513a641?auto=format&fit=crop&w=600&q=80',
            price: 420,
            priceLabel: 'per plate',
            category: BirthdayFoodCategory.mains,
            isPopular: true,
          ),
          BirthdayFoodItem(
            id: 'panshi-m2',
            restaurantId: 'panshi-restaurant',
            name: 'Beef Bhuna with Roti',
            description: 'Rich slow-cooked beef in aromatic spices, served with 4 roti.',
            imageUrl: 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?auto=format&fit=crop&w=600&q=80',
            price: 380,
            priceLabel: 'per plate',
            category: BirthdayFoodCategory.mains,
          ),
          BirthdayFoodItem(
            id: 'panshi-m3',
            restaurantId: 'panshi-restaurant',
            name: 'Hilsa Fish Curry',
            description: 'Traditional Bangladeshi hilsa curry in mustard sauce.',
            imageUrl: 'https://images.unsplash.com/photo-1534422298391-e4f8c172dddb?auto=format&fit=crop&w=600&q=80',
            price: 550,
            priceLabel: 'per plate',
            category: BirthdayFoodCategory.mains,
            isPopular: true,
          ),
          BirthdayFoodItem(
            id: 'panshi-d1',
            restaurantId: 'panshi-restaurant',
            name: 'Firni Cup',
            description: 'Chilled creamy rice pudding in an earthen cup.',
            imageUrl: 'https://images.unsplash.com/photo-1563805042-7684c019e1cb?auto=format&fit=crop&w=600&q=80',
            price: 90,
            priceLabel: 'per cup',
            category: BirthdayFoodCategory.desserts,
          ),
          BirthdayFoodItem(
            id: 'panshi-d2',
            restaurantId: 'panshi-restaurant',
            name: 'Gulab Jamun (3 pcs)',
            description: 'Soft milk-solid sweets soaked in rose-flavoured sugar syrup.',
            imageUrl: 'https://images.unsplash.com/photo-1571115764595-644a1f56a55c?auto=format&fit=crop&w=600&q=80',
            price: 80,
            priceLabel: 'per 3 pcs',
            category: BirthdayFoodCategory.desserts,
            isVegetarian: true,
          ),
          BirthdayFoodItem(
            id: 'panshi-dr1',
            restaurantId: 'panshi-restaurant',
            name: 'Borhani',
            description: 'Traditional chilled spiced yoghurt drink.',
            imageUrl: 'https://images.unsplash.com/photo-1587049352846-4a222e784d38?auto=format&fit=crop&w=600&q=80',
            price: 60,
            priceLabel: 'per glass',
            category: BirthdayFoodCategory.drinks,
            isVegetarian: true,
          ),
          BirthdayFoodItem(
            id: 'panshi-dr2',
            restaurantId: 'panshi-restaurant',
            name: 'Soft Drinks (Assorted)',
            description: 'Chilled canned soft drinks — Coke, Sprite, 7Up.',
            imageUrl: 'https://images.unsplash.com/photo-1437418747212-8d9709afab22?auto=format&fit=crop&w=600&q=80',
            price: 50,
            priceLabel: 'per can',
            category: BirthdayFoodCategory.drinks,
          ),
        ],
      );

  static BirthdayRestaurantMenu _pachBhaiMenu() => const BirthdayRestaurantMenu(
        restaurantId: 'pach-bhai-restaurant',
        restaurantName: 'Pach Bhai Restaurant',
        items: [
          BirthdayFoodItem(
            id: 'pb-s1',
            restaurantId: 'pach-bhai-restaurant',
            name: 'Piyaju (8 pcs)',
            description: 'Crispy lentil fritters with green chilli and onion.',
            imageUrl: 'https://images.unsplash.com/photo-1601050690597-df0568f70950?auto=format&fit=crop&w=600&q=80',
            price: 60,
            priceLabel: 'per 8 pcs',
            category: BirthdayFoodCategory.starters,
            isVegetarian: true,
          ),
          BirthdayFoodItem(
            id: 'pb-m1',
            restaurantId: 'pach-bhai-restaurant',
            name: 'Mutton Kacchi Biryani',
            description: 'Classic slow-cooked mutton kacchi biryani with saffron-infused basmati.',
            imageUrl: 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?auto=format&fit=crop&w=600&q=80',
            price: 650,
            priceLabel: 'per plate',
            category: BirthdayFoodCategory.mains,
            isPopular: true,
          ),
          BirthdayFoodItem(
            id: 'pb-m2',
            restaurantId: 'pach-bhai-restaurant',
            name: 'Chicken Biryani',
            description: 'Fragrant chicken biryani with caramelised onions and boiled egg.',
            imageUrl: 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?auto=format&fit=crop&w=600&q=80',
            price: 380,
            priceLabel: 'per plate',
            category: BirthdayFoodCategory.mains,
          ),
          BirthdayFoodItem(
            id: 'pb-g1',
            restaurantId: 'pach-bhai-restaurant',
            name: 'Mixed Grill Platter',
            description: 'Chicken tikka, seekh kebab, and reshmi kebab with mint chutney.',
            imageUrl: 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=600&q=80',
            price: 850,
            priceLabel: 'per platter (2–3 pax)',
            category: BirthdayFoodCategory.grills,
            isPopular: true,
          ),
          BirthdayFoodItem(
            id: 'pb-d1',
            restaurantId: 'pach-bhai-restaurant',
            name: 'Shahi Tukra',
            description: 'Double-fried bread in sweet condensed milk with pistachio.',
            imageUrl: 'https://images.unsplash.com/photo-1563805042-7684c019e1cb?auto=format&fit=crop&w=600&q=80',
            price: 120,
            priceLabel: 'per piece',
            category: BirthdayFoodCategory.desserts,
          ),
          BirthdayFoodItem(
            id: 'pb-dr1',
            restaurantId: 'pach-bhai-restaurant',
            name: 'Lemon Mint Cooler',
            description: 'Chilled fresh lemon juice with mint and jeera.',
            imageUrl: 'https://images.unsplash.com/photo-1587049352846-4a222e784d38?auto=format&fit=crop&w=600&q=80',
            price: 80,
            priceLabel: 'per glass',
            category: BirthdayFoodCategory.drinks,
            isVegetarian: true,
          ),
        ],
      );

  static BirthdayRestaurantMenu _meatupMenu() => const BirthdayRestaurantMenu(
        restaurantId: 'meatup',
        restaurantName: 'MEATUP',
        items: [
          BirthdayFoodItem(
            id: 'mu-s1',
            restaurantId: 'meatup',
            name: 'Crispy Chicken Wings (6 pcs)',
            description: 'Spiced and fried chicken wings with garlic dip.',
            imageUrl: 'https://images.unsplash.com/photo-1567620832903-9fc6debc209f?auto=format&fit=crop&w=600&q=80',
            price: 320,
            priceLabel: 'per 6 pcs',
            category: BirthdayFoodCategory.starters,
            isPopular: true,
          ),
          BirthdayFoodItem(
            id: 'mu-m1',
            restaurantId: 'meatup',
            name: 'MEATUP Beef Burger',
            description: 'Double smash beef patty with cheese, pickles, and special sauce.',
            imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=600&q=80',
            price: 480,
            priceLabel: 'per burger',
            category: BirthdayFoodCategory.mains,
            isPopular: true,
          ),
          BirthdayFoodItem(
            id: 'mu-m2',
            restaurantId: 'meatup',
            name: 'Beef Steak (200g)',
            description: 'Pan-seared beef striploin with mushroom sauce and mashed potato.',
            imageUrl: 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?auto=format&fit=crop&w=600&q=80',
            price: 850,
            priceLabel: 'per plate',
            category: BirthdayFoodCategory.mains,
          ),
          BirthdayFoodItem(
            id: 'mu-g1',
            restaurantId: 'meatup',
            name: 'BBQ Beef Ribs',
            description: 'Slow-smoked beef ribs glazed with smoky BBQ sauce.',
            imageUrl: 'https://images.unsplash.com/photo-1529193591184-b1d58069ecdd?auto=format&fit=crop&w=600&q=80',
            price: 1200,
            priceLabel: 'per rack (half)',
            category: BirthdayFoodCategory.grills,
            isPopular: true,
          ),
          BirthdayFoodItem(
            id: 'mu-g2',
            restaurantId: 'meatup',
            name: 'Chicken Skewers',
            description: 'Marinated chicken thigh skewers with capsicum and tzatziki.',
            imageUrl: 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=600&q=80',
            price: 420,
            priceLabel: 'per 4 skewers',
            category: BirthdayFoodCategory.grills,
          ),
          BirthdayFoodItem(
            id: 'mu-d1',
            restaurantId: 'meatup',
            name: 'Chocolate Lava Cake',
            description: 'Warm dark chocolate fondant with vanilla ice cream.',
            imageUrl: 'https://images.unsplash.com/photo-1529042410759-befb1204b468?auto=format&fit=crop&w=600&q=80',
            price: 220,
            priceLabel: 'per piece',
            category: BirthdayFoodCategory.desserts,
          ),
          BirthdayFoodItem(
            id: 'mu-dr1',
            restaurantId: 'meatup',
            name: 'Fresh Juice (Mango/Orange)',
            description: 'Freshly blended seasonal fruit juice.',
            imageUrl: 'https://images.unsplash.com/photo-1437418747212-8d9709afab22?auto=format&fit=crop&w=600&q=80',
            price: 120,
            priceLabel: 'per glass',
            category: BirthdayFoodCategory.drinks,
            isVegetarian: true,
          ),
        ],
      );

  static BirthdayRestaurantMenu _madGrillMenu() => const BirthdayRestaurantMenu(
        restaurantId: 'the-mad-grill',
        restaurantName: 'The Mad Grill',
        items: [
          BirthdayFoodItem(
            id: 'mg-s1',
            restaurantId: 'the-mad-grill',
            name: 'Nachos with Salsa & Cheese',
            description: 'Crispy tortilla chips with fresh tomato salsa and melted cheese.',
            imageUrl: 'https://images.unsplash.com/photo-1513456852971-30c0b8199d4d?auto=format&fit=crop&w=600&q=80',
            price: 250,
            priceLabel: 'per portion',
            category: BirthdayFoodCategory.starters,
            isVegetarian: true,
          ),
          BirthdayFoodItem(
            id: 'mg-m1',
            restaurantId: 'the-mad-grill',
            name: 'Mad Grill Burger',
            description: 'Signature double-decker with caramelised onion and jalapeño mayo.',
            imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=600&q=80',
            price: 520,
            priceLabel: 'per burger',
            category: BirthdayFoodCategory.mains,
            isPopular: true,
          ),
          BirthdayFoodItem(
            id: 'mg-g1',
            restaurantId: 'the-mad-grill',
            name: 'Mad Mixed Grill Platter',
            description: 'Lamb chop, chicken thigh, seekh kebab, and grilled veggies.',
            imageUrl: 'https://images.unsplash.com/photo-1529193591184-b1d58069ecdd?auto=format&fit=crop&w=600&q=80',
            price: 1400,
            priceLabel: 'per platter (3–4 pax)',
            category: BirthdayFoodCategory.grills,
            isPopular: true,
          ),
          BirthdayFoodItem(
            id: 'mg-g2',
            restaurantId: 'the-mad-grill',
            name: 'Grilled Lamb Chops (3 pcs)',
            description: 'Herb-marinated lamb chops with rosemary jus.',
            imageUrl: 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=600&q=80',
            price: 980,
            priceLabel: 'per 3 pcs',
            category: BirthdayFoodCategory.grills,
          ),
          BirthdayFoodItem(
            id: 'mg-d1',
            restaurantId: 'the-mad-grill',
            name: 'Brownie Sundae',
            description: 'Warm chocolate brownie with vanilla ice cream and hot fudge.',
            imageUrl: 'https://images.unsplash.com/photo-1563729784474-d77dbb933a9e?auto=format&fit=crop&w=600&q=80',
            price: 240,
            priceLabel: 'per serving',
            category: BirthdayFoodCategory.desserts,
          ),
          BirthdayFoodItem(
            id: 'mg-dr1',
            restaurantId: 'the-mad-grill',
            name: 'Lemonade',
            description: 'Fresh-pressed lemonade with basil seeds.',
            imageUrl: 'https://images.unsplash.com/photo-1587049352846-4a222e784d38?auto=format&fit=crop&w=600&q=80',
            price: 90,
            priceLabel: 'per glass',
            category: BirthdayFoodCategory.drinks,
            isVegetarian: true,
          ),
        ],
      );

  static BirthdayRestaurantMenu _yokokosoMenu() => const BirthdayRestaurantMenu(
        restaurantId: 'yokoso',
        restaurantName: 'Yōkoso',
        items: [
          BirthdayFoodItem(
            id: 'yk-s1',
            restaurantId: 'yokoso',
            name: 'Edamame (steamed)',
            description: 'Lightly salted steamed soybean pods.',
            imageUrl: 'https://images.unsplash.com/photo-1547592166-23ac45744acd?auto=format&fit=crop&w=600&q=80',
            price: 150,
            priceLabel: 'per bowl',
            category: BirthdayFoodCategory.starters,
            isVegetarian: true,
          ),
          BirthdayFoodItem(
            id: 'yk-s2',
            restaurantId: 'yokoso',
            name: 'Gyoza (6 pcs)',
            description: 'Pan-fried pork and cabbage dumplings with ponzu dipping sauce.',
            imageUrl: 'https://images.unsplash.com/photo-1563805042-7684c019e1cb?auto=format&fit=crop&w=600&q=80',
            price: 320,
            priceLabel: 'per 6 pcs',
            category: BirthdayFoodCategory.starters,
            isPopular: true,
          ),
          BirthdayFoodItem(
            id: 'yk-m1',
            restaurantId: 'yokoso',
            name: 'Chicken Teriyaki Bowl',
            description: 'Grilled teriyaki chicken over steamed Japanese rice with pickled ginger.',
            imageUrl: 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?auto=format&fit=crop&w=600&q=80',
            price: 480,
            priceLabel: 'per bowl',
            category: BirthdayFoodCategory.mains,
            isPopular: true,
          ),
          BirthdayFoodItem(
            id: 'yk-m2',
            restaurantId: 'yokoso',
            name: 'Salmon Ramen',
            description: 'Rich tonkotsu broth with grilled salmon, noodles, and soft-boiled egg.',
            imageUrl: 'https://images.unsplash.com/photo-1569050467447-ce54b3bbc37d?auto=format&fit=crop&w=600&q=80',
            price: 650,
            priceLabel: 'per bowl',
            category: BirthdayFoodCategory.mains,
          ),
          BirthdayFoodItem(
            id: 'yk-g1',
            restaurantId: 'yokoso',
            name: 'Yakitori Skewers (5 pcs)',
            description: 'Japanese charcoal-grilled chicken skewers with tare glaze.',
            imageUrl: 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=600&q=80',
            price: 420,
            priceLabel: 'per 5 pcs',
            category: BirthdayFoodCategory.grills,
          ),
          BirthdayFoodItem(
            id: 'yk-d1',
            restaurantId: 'yokoso',
            name: 'Matcha Ice Cream',
            description: 'Japanese green tea ice cream with red bean topping.',
            imageUrl: 'https://images.unsplash.com/photo-1563729784474-d77dbb933a9e?auto=format&fit=crop&w=600&q=80',
            price: 180,
            priceLabel: 'per scoop',
            category: BirthdayFoodCategory.desserts,
            isVegetarian: true,
          ),
          BirthdayFoodItem(
            id: 'yk-dr1',
            restaurantId: 'yokoso',
            name: 'Ramune Soda',
            description: 'Japanese marble bottle soda — assorted flavours.',
            imageUrl: 'https://images.unsplash.com/photo-1437418747212-8d9709afab22?auto=format&fit=crop&w=600&q=80',
            price: 150,
            priceLabel: 'per bottle',
            category: BirthdayFoodCategory.drinks,
            isVegetarian: true,
          ),
        ],
      );

  static BirthdayRestaurantMenu _woondaalMenu() => const BirthdayRestaurantMenu(
        restaurantId: 'woondaal-king-kebab',
        restaurantName: 'Woondaal King Kebab',
        items: [
          BirthdayFoodItem(
            id: 'wk-s1',
            restaurantId: 'woondaal-king-kebab',
            name: 'Shammi Kebab (4 pcs)',
            description: 'Spiced minced beef patties pan-fried with onion rings.',
            imageUrl: 'https://images.unsplash.com/photo-1529193591184-b1d58069ecdd?auto=format&fit=crop&w=600&q=80',
            price: 240,
            priceLabel: 'per 4 pcs',
            category: BirthdayFoodCategory.starters,
            isPopular: true,
          ),
          BirthdayFoodItem(
            id: 'wk-m1',
            restaurantId: 'woondaal-king-kebab',
            name: 'King Kebab Roll',
            description: 'Signature hand-ground seekh kebab in a flaky paratha roll.',
            imageUrl: 'https://images.unsplash.com/photo-1565557623262-b51c2513a641?auto=format&fit=crop&w=600&q=80',
            price: 300,
            priceLabel: 'per roll',
            category: BirthdayFoodCategory.mains,
            isPopular: true,
          ),
          BirthdayFoodItem(
            id: 'wk-m2',
            restaurantId: 'woondaal-king-kebab',
            name: 'Mutton Kebab Platter',
            description: 'Assorted mutton seekh, boti, and reshmi kebabs with chutney.',
            imageUrl: 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=600&q=80',
            price: 1100,
            priceLabel: 'per platter (2–3 pax)',
            category: BirthdayFoodCategory.mains,
          ),
          BirthdayFoodItem(
            id: 'wk-g1',
            restaurantId: 'woondaal-king-kebab',
            name: 'Beef Tikka (6 pcs)',
            description: 'Marinated beef tikka charcoal-grilled with lemon and onion salad.',
            imageUrl: 'https://images.unsplash.com/photo-1529193591184-b1d58069ecdd?auto=format&fit=crop&w=600&q=80',
            price: 480,
            priceLabel: 'per 6 pcs',
            category: BirthdayFoodCategory.grills,
          ),
          BirthdayFoodItem(
            id: 'wk-d1',
            restaurantId: 'woondaal-king-kebab',
            name: 'Kheer',
            description: 'Chilled rice and milk pudding with cardamom and rose water.',
            imageUrl: 'https://images.unsplash.com/photo-1571115764595-644a1f56a55c?auto=format&fit=crop&w=600&q=80',
            price: 90,
            priceLabel: 'per bowl',
            category: BirthdayFoodCategory.desserts,
            isVegetarian: true,
          ),
          BirthdayFoodItem(
            id: 'wk-dr1',
            restaurantId: 'woondaal-king-kebab',
            name: 'Lassi (Sweet / Salted)',
            description: 'Chilled thick yoghurt drink.',
            imageUrl: 'https://images.unsplash.com/photo-1587049352846-4a222e784d38?auto=format&fit=crop&w=600&q=80',
            price: 80,
            priceLabel: 'per glass',
            category: BirthdayFoodCategory.drinks,
            isVegetarian: true,
          ),
        ],
      );

  static BirthdayRestaurantMenu _nawabsKitchenMenu() =>
      const BirthdayRestaurantMenu(
        restaurantId: 'nawabs-kitchen',
        restaurantName: "Nawab's Kitchen",
        items: [
          BirthdayFoodItem(
            id: 'nk-s1',
            restaurantId: 'nawabs-kitchen',
            name: 'Chicken Tikka (6 pcs)',
            description: 'Tender chicken chunks marinated in yoghurt and spice, tandoor-baked.',
            imageUrl: 'https://images.unsplash.com/photo-1565557623262-b51c2513a641?auto=format&fit=crop&w=600&q=80',
            price: 420,
            priceLabel: 'per 6 pcs',
            category: BirthdayFoodCategory.starters,
            isPopular: true,
          ),
          BirthdayFoodItem(
            id: 'nk-m1',
            restaurantId: 'nawabs-kitchen',
            name: 'Nawab\'s Special Biryani',
            description: 'Signature handi-dum biryani with tender mutton and saffron rice.',
            imageUrl: 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?auto=format&fit=crop&w=600&q=80',
            price: 720,
            priceLabel: 'per plate',
            category: BirthdayFoodCategory.mains,
            isPopular: true,
          ),
          BirthdayFoodItem(
            id: 'nk-m2',
            restaurantId: 'nawabs-kitchen',
            name: 'Chicken Korma with Naan',
            description: 'Creamy Mughal-style chicken korma served with two butter naan.',
            imageUrl: 'https://images.unsplash.com/photo-1534422298391-e4f8c172dddb?auto=format&fit=crop&w=600&q=80',
            price: 480,
            priceLabel: 'per plate',
            category: BirthdayFoodCategory.mains,
          ),
          BirthdayFoodItem(
            id: 'nk-g1',
            restaurantId: 'nawabs-kitchen',
            name: 'Nawab Grill Platter',
            description: 'Lamb seekh, chicken seekh, boti, and paneer tikka with dips.',
            imageUrl: 'https://images.unsplash.com/photo-1529193591184-b1d58069ecdd?auto=format&fit=crop&w=600&q=80',
            price: 1300,
            priceLabel: 'per platter (3–4 pax)',
            category: BirthdayFoodCategory.grills,
            isPopular: true,
          ),
          BirthdayFoodItem(
            id: 'nk-d1',
            restaurantId: 'nawabs-kitchen',
            name: 'Rasmalai (3 pcs)',
            description: 'Soft cottage cheese rounds in saffron-scented condensed milk.',
            imageUrl: 'https://images.unsplash.com/photo-1571115764595-644a1f56a55c?auto=format&fit=crop&w=600&q=80',
            price: 150,
            priceLabel: 'per 3 pcs',
            category: BirthdayFoodCategory.desserts,
            isVegetarian: true,
          ),
          BirthdayFoodItem(
            id: 'nk-dr1',
            restaurantId: 'nawabs-kitchen',
            name: 'Rose Sherbet',
            description: 'Chilled rose-flavoured milk drink with basil seeds.',
            imageUrl: 'https://images.unsplash.com/photo-1437418747212-8d9709afab22?auto=format&fit=crop&w=600&q=80',
            price: 90,
            priceLabel: 'per glass',
            category: BirthdayFoodCategory.drinks,
            isVegetarian: true,
          ),
        ],
      );

  static BirthdayRestaurantMenu _seasonsMenu() => const BirthdayRestaurantMenu(
        restaurantId: 'seasons-meat-grill',
        restaurantName: 'SEASONS Meat & Grill',
        items: [
          BirthdayFoodItem(
            id: 'sm-s1',
            restaurantId: 'seasons-meat-grill',
            name: 'Garlic Bread with Dip',
            description: 'Toasted garlic butter baguette with herb cream cheese.',
            imageUrl: 'https://images.unsplash.com/photo-1513456852971-30c0b8199d4d?auto=format&fit=crop&w=600&q=80',
            price: 150,
            priceLabel: 'per portion',
            category: BirthdayFoodCategory.starters,
            isVegetarian: true,
          ),
          BirthdayFoodItem(
            id: 'sm-m1',
            restaurantId: 'seasons-meat-grill',
            name: 'Seasons Beef Burger',
            description: '180g beef patty with cheddar, caramelised onion, and truffle mayo.',
            imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=600&q=80',
            price: 550,
            priceLabel: 'per burger',
            category: BirthdayFoodCategory.mains,
            isPopular: true,
          ),
          BirthdayFoodItem(
            id: 'sm-m2',
            restaurantId: 'seasons-meat-grill',
            name: 'Pasta Arrabbiata',
            description: 'Penne in spicy tomato sauce with fresh basil and parmesan.',
            imageUrl: 'https://images.unsplash.com/photo-1555244162-803834f70033?auto=format&fit=crop&w=600&q=80',
            price: 380,
            priceLabel: 'per plate',
            category: BirthdayFoodCategory.mains,
            isVegetarian: true,
          ),
          BirthdayFoodItem(
            id: 'sm-g1',
            restaurantId: 'seasons-meat-grill',
            name: 'Seasons BBQ Platter',
            description: 'Beef ribs, chicken thigh, lamb kebab, and corn on the cob.',
            imageUrl: 'https://images.unsplash.com/photo-1529193591184-b1d58069ecdd?auto=format&fit=crop&w=600&q=80',
            price: 1800,
            priceLabel: 'per platter (3–5 pax)',
            category: BirthdayFoodCategory.grills,
            isPopular: true,
          ),
          BirthdayFoodItem(
            id: 'sm-g2',
            restaurantId: 'seasons-meat-grill',
            name: 'Ribeye Steak (250g)',
            description: 'Dry-aged ribeye grilled to your preference with compound butter.',
            imageUrl: 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?auto=format&fit=crop&w=600&q=80',
            price: 1400,
            priceLabel: 'per piece',
            category: BirthdayFoodCategory.grills,
          ),
          BirthdayFoodItem(
            id: 'sm-d1',
            restaurantId: 'seasons-meat-grill',
            name: 'Tiramisu',
            description: 'Classic Italian ladyfinger and mascarpone dessert with cocoa.',
            imageUrl: 'https://images.unsplash.com/photo-1563729784474-d77dbb933a9e?auto=format&fit=crop&w=600&q=80',
            price: 280,
            priceLabel: 'per slice',
            category: BirthdayFoodCategory.desserts,
            isVegetarian: true,
          ),
          BirthdayFoodItem(
            id: 'sm-dr1',
            restaurantId: 'seasons-meat-grill',
            name: 'Iced Coffee',
            description: 'Cold brew with milk and simple syrup over ice.',
            imageUrl: 'https://images.unsplash.com/photo-1437418747212-8d9709afab22?auto=format&fit=crop&w=600&q=80',
            price: 180,
            priceLabel: 'per glass',
            category: BirthdayFoodCategory.drinks,
            isVegetarian: true,
          ),
        ],
      );

  static BirthdayRestaurantMenu _genericMenu(
    String restaurantId,
    String restaurantName,
  ) =>
      BirthdayRestaurantMenu(
        restaurantId: restaurantId,
        restaurantName: restaurantName,
        items: [
          BirthdayFoodItem(
            id: '$restaurantId-m1',
            restaurantId: restaurantId,
            name: 'Chef\'s Special (Sample)',
            description: 'Sample menu item. Contact the restaurant for their actual menu.',
            imageUrl: 'https://images.unsplash.com/photo-1555244162-803834f70033?auto=format&fit=crop&w=600&q=80',
            price: 400,
            priceLabel: 'per plate (sample)',
            category: BirthdayFoodCategory.mains,
          ),
        ],
      );
}
