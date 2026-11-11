import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/birthday/birthday_venue.dart';
import '../../providers/birthday_provider.dart';
import 'core/birthday_theme.dart';

class BirthdayVenueSelectionScreen extends StatelessWidget {
  const BirthdayVenueSelectionScreen({super.key});

  String _formatCurrency(num amount) {
    final formatted = amount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
        );
    return '৳$formatted';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BirthdayTheme.warmIvory,
      appBar: AppBar(
        backgroundColor: BirthdayTheme.warmIvory,
        elevation: 0,
        title: Text('Choose a Birthday Venue', style: BirthdayTheme.heading2),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: BirthdayTheme.darkWarmBrown,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _buildDemoNotice(),
          const SizedBox(height: 16),
          ...BirthdayVenue.sampleListings.map(
            (venue) => _buildVenueCard(context, venue),
          ),
        ],
      ),
    );
  }

  Widget _buildDemoNotice() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: BirthdayTheme.champagneGoldShimmer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BirthdayTheme.champagneBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: BirthdayTheme.darkWarmBrown,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Sample listings only — no official partnerships or live availability. '
              'Photos are illustrative; location, cuisine, capacity, and prices are demo estimates. '
              'Please contact a restaurant directly to confirm details and booking.',
              style: BirthdayTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVenueCard(BuildContext context, BirthdayVenue venue) {
    return Consumer<BirthdayProvider>(
      builder: (context, provider, _) {
        final isSelected = provider.selectedVenue?.id == venue.id;
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: BirthdayTheme.blushFloralCard(
            border: Border.all(
              color: isSelected
                  ? BirthdayTheme.champagneBorder
                  : BirthdayTheme.subtleBorder,
              width: isSelected ? 1.6 : 1,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: Image.network(
                    venue.imageUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return _imageFallback(showLoading: true);
                    },
                    errorBuilder: (context, error, stackTrace) =>
                        _imageFallback(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              venue.name,
                              style: BirthdayTheme.heading3,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatCurrency(venue.estimatedPrice),
                            style: GoogleFonts.playfairDisplay(
                              color: BirthdayTheme.darkWarmBrown,
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Estimated venue price · sample',
                        style: BirthdayTheme.bodySmall,
                      ),
                      const SizedBox(height: 12),
                      _infoRow(Icons.location_on_outlined, venue.location),
                      const SizedBox(height: 7),
                      _infoRow(
                        Icons.restaurant_menu_rounded,
                        venue.cuisineType,
                      ),
                      const SizedBox(height: 7),
                      _infoRow(Icons.groups_2_outlined, venue.seatingCapacity),
                      const SizedBox(height: 10),
                      Text(
                        'Illustrative restaurant image',
                        style: BirthdayTheme.bodySmall.copyWith(fontSize: 10),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _showDetails(context, venue),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: BirthdayTheme.darkWarmBrown,
                                side: const BorderSide(
                                  color: BirthdayTheme.champagneBorder,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text('View Details'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                provider.selectBirthdayVenue(venue);
                                Navigator.pop(context);
                              },
                              style: BirthdayTheme.primaryButton,
                              child: Text(
                                isSelected ? 'Selected' : 'Select Venue',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _imageFallback({bool showLoading = false}) {
    return SizedBox(
      height: 180,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/birthday/birthday_decor.jpg',
            fit: BoxFit.cover,
          ),
          if (showLoading)
            const Center(
              child: CircularProgressIndicator(
                color: BirthdayTheme.champagneGoldDeep,
              ),
            ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 17, color: BirthdayTheme.mutedGold),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: BirthdayTheme.bodySmall)),
      ],
    );
  }

  void _showDetails(BuildContext pageContext, BirthdayVenue venue) {
    showModalBottomSheet<void>(
      context: pageContext,
      backgroundColor: BirthdayTheme.warmIvoryBase,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(venue.name, style: BirthdayTheme.heading2),
              const SizedBox(height: 12),
              Text(venue.description, style: BirthdayTheme.body),
              const SizedBox(height: 14),
              _infoRow(Icons.location_on_outlined, venue.location),
              const SizedBox(height: 8),
              _infoRow(Icons.restaurant_menu_rounded, venue.cuisineType),
              const SizedBox(height: 8),
              _infoRow(Icons.groups_2_outlined, venue.seatingCapacity),
              const SizedBox(height: 8),
              _infoRow(
                Icons.payments_outlined,
                '${_formatCurrency(venue.estimatedPrice)} estimated venue price (sample)',
              ),
              const SizedBox(height: 16),
              Text(
                'This demo selection does not place a reservation. '
                'Confirm current availability and terms directly with the restaurant.',
                style: BirthdayTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: BirthdayTheme.primaryButton,
                  onPressed: () {
                    final provider = Provider.of<BirthdayProvider>(
                      pageContext,
                      listen: false,
                    );
                    provider.selectBirthdayVenue(venue);
                    Navigator.pop(sheetContext);
                    Navigator.of(pageContext).pop();
                  },
                  child: const Text('Select Venue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
