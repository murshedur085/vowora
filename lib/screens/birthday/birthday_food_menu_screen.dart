import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/birthday/birthday_food_menu.dart';
import '../../models/birthday/birthday_venue.dart';
import '../../widgets/vowora_cached_image.dart';
import 'core/birthday_theme.dart';

/// Displays the per-item food menu for a selected birthday venue.
/// Users can browse by category, adjust quantities, and build a food order
/// that is passed back to the caller.
///
/// All menus shown are SAMPLE / DEMO DATA until actual restaurant menus
/// and pricing are verified and confirmed with each restaurant.
class BirthdayFoodMenuScreen extends StatefulWidget {
  final BirthdayVenue venue;

  const BirthdayFoodMenuScreen({super.key, required this.venue});

  @override
  State<BirthdayFoodMenuScreen> createState() => _BirthdayFoodMenuScreenState();
}

class _BirthdayFoodMenuScreenState extends State<BirthdayFoodMenuScreen> {
  BirthdayFoodCategory _selectedCategory = BirthdayFoodCategory.starters;
  final Map<String, int> _quantities = {}; // itemId → qty
  late final BirthdayRestaurantMenu _menu;

  @override
  void initState() {
    super.initState();
    _menu = BirthdayRestaurantMenu.forRestaurant(
      widget.venue.id,
      widget.venue.name,
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _formatCurrency(num amount) {
    final formatted = amount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
    return '৳$formatted';
  }

  List<BirthdayFoodCartEntry> get _cartEntries {
    final entries = <BirthdayFoodCartEntry>[];
    for (final item in _menu.items) {
      final qty = _quantities[item.id] ?? 0;
      if (qty > 0) entries.add(BirthdayFoodCartEntry(item: item, quantity: qty));
    }
    return entries;
  }

  double get _cartTotal =>
      _cartEntries.fold(0.0, (s, e) => s + e.totalCost);

  int get _totalItemCount =>
      _quantities.values.fold(0, (s, q) => s + q);

  void _setQty(String itemId, int qty) {
    setState(() {
      if (qty <= 0) {
        _quantities.remove(itemId);
      } else {
        _quantities[itemId] = qty;
      }
    });
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final visibleItems = _menu.itemsForCategory(_selectedCategory);

    return Scaffold(
      backgroundColor: BirthdayTheme.warmIvory,
      appBar: AppBar(
        backgroundColor: BirthdayTheme.warmIvory,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: BirthdayTheme.darkWarmBrown,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context, _cartEntries),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.venue.name,
              style: BirthdayTheme.heading2.copyWith(fontSize: 18),
            ),
            Text(
              'Browse Menu',
              style: BirthdayTheme.bodySmall,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Demo notice banner
          _buildDemoNotice(),

          // Category tab bar
          _buildCategoryTabs(),

          // Food item list
          Expanded(
            child: visibleItems.isEmpty
                ? Center(
                    child: Text(
                      'No items in this category yet.',
                      style: BirthdayTheme.bodySmall,
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                    physics: const BouncingScrollPhysics(),
                    itemCount: visibleItems.length,
                    itemBuilder: (context, index) =>
                        _buildFoodItemCard(visibleItems[index]),
                  ),
          ),
        ],
      ),

      // Sticky bottom tray
      bottomNavigationBar: _totalItemCount > 0
          ? _buildCartTray(context)
          : null,
    );
  }

  // ── Demo notice ────────────────────────────────────────────────────────────

  Widget _buildDemoNotice() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: BirthdayTheme.champagneGoldShimmer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: BirthdayTheme.champagneBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: BirthdayTheme.darkWarmBrown,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Sample menu — items, prices and availability are demo estimates. '
              'Contact the restaurant to confirm their actual event menu and pricing.',
              style: BirthdayTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  // ── Category tabs ──────────────────────────────────────────────────────────

  Widget _buildCategoryTabs() {
    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemCount: BirthdayFoodCategory.values.length,
        itemBuilder: (context, index) {
          final cat = BirthdayFoodCategory.values[index];
          final isSelected = _selectedCategory == cat;
          final count = _menu
              .itemsForCategory(cat)
              .where((i) => (_quantities[i.id] ?? 0) > 0)
              .length;

          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? BirthdayTheme.blushFloralGradient
                    : null,
                color: isSelected ? null : Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? BirthdayTheme.champagneBorder
                      : BirthdayTheme.subtleBorder,
                  width: isSelected ? 1.2 : 0.8,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    cat.emoji,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    cat.displayName,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected
                          ? BirthdayTheme.darkWarmBrown
                          : BirthdayTheme.warmBrownMuted,
                    ),
                  ),
                  if (count > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: BirthdayTheme.champagneBorder,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$count',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: BirthdayTheme.darkWarmBrown,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Food item card ─────────────────────────────────────────────────────────

  Widget _buildFoodItemCard(BirthdayFoodItem item) {
    final qty = _quantities[item.id] ?? 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: BirthdayTheme.blushFloralCard(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Food image
              VoworaCachedImage(
                imageUrl: item.imageUrl,
                width: 90,
                height: 90,
                contextSize: ImageContextSize.thumbnail,
                borderRadius: BorderRadius.circular(12),
              ),
              const SizedBox(width: 14),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name row with badges
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: BirthdayTheme.darkWarmBrown,
                            ),
                          ),
                        ),
                        if (item.isPopular)
                          _badge('Popular', BirthdayTheme.champagneBorder),
                        if (item.isVegetarian)
                          _badge('Veg', BirthdayTheme.successGreen),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      style: BirthdayTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Price + qty controls
                    Row(
                      children: [
                        // Price
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _formatCurrency(item.price),
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: BirthdayTheme.darkWarmBrown,
                              ),
                            ),
                            Text(
                              item.priceLabel,
                              style: BirthdayTheme.bodySmall
                                  .copyWith(fontSize: 10),
                            ),
                          ],
                        ),
                        const Spacer(),

                        // Quantity stepper
                        qty == 0
                            ? ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      BirthdayTheme.champagneGoldDeep,
                                  foregroundColor:
                                      BirthdayTheme.darkWarmBrown,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () => _setQty(item.id, 1),
                                child: Text(
                                  'Add',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            : _buildQtyStepper(item, qty),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      margin: const EdgeInsets.only(left: 6),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 0.8),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildQtyStepper(BirthdayFoodItem item, int qty) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: BirthdayTheme.champagneBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _stepBtn(
            icon: Icons.remove_rounded,
            onTap: () => _setQty(item.id, qty - 1),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              '$qty',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: BirthdayTheme.darkWarmBrown,
              ),
            ),
          ),
          _stepBtn(
            icon: Icons.add_rounded,
            onTap: () => _setQty(item.id, qty + 1),
          ),
        ],
      ),
    );
  }

  Widget _stepBtn({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(
          icon,
          size: 16,
          color: BirthdayTheme.darkWarmBrown,
        ),
      ),
    );
  }

  // ── Cart summary tray ──────────────────────────────────────────────────────

  Widget _buildCartTray(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: BirthdayTheme.darkWarmBrown.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Mini item summary
            ..._cartEntries.take(3).map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Text(
                          '${e.quantity}×',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: BirthdayTheme.champagneBorder,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            e.item.name,
                            style: BirthdayTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          _formatCurrency(e.totalCost),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: BirthdayTheme.darkWarmBrown,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            if (_cartEntries.length > 3)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '+ ${_cartEntries.length - 3} more item(s)',
                  style: BirthdayTheme.bodySmall,
                ),
              ),
            const Divider(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$_totalItemCount item(s) selected',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: BirthdayTheme.warmBrownMuted,
                        ),
                      ),
                      Text(
                        _formatCurrency(_cartTotal),
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: BirthdayTheme.darkWarmBrown,
                        ),
                      ),
                      Text(
                        'Sample estimate only',
                        style: BirthdayTheme.bodySmall.copyWith(fontSize: 10),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  style: BirthdayTheme.primaryButton,
                  onPressed: () =>
                      Navigator.pop(context, _cartEntries),
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: const Text('Add to Event Plan'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
