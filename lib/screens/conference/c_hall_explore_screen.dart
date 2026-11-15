import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/conference/conference_seed_data.dart';
import '../../widgets/conference_hall_availability_section.dart';
import '../../widgets/vowora_cached_image.dart';
import '../conference/c_others/booking_bottom_sheet.dart';

Widget _hallImage(
  Map<String, dynamic> hall, {
  required double width,
  required double height,
}) {
  final imageUrl = hall['image']?.toString() ?? '';
  if (imageUrl.isEmpty) {
    return _hallImagePlaceholder(width: width, height: height);
  }
  return VoworaCachedImage(
    imageUrl: imageUrl,
    width: width,
    height: height,
    fit: BoxFit.cover,
    contextSize: ImageContextSize.card,
    errorWidget: _hallImagePlaceholder(width: width, height: height),
  );
}

Widget _hallImagePlaceholder({required double width, required double height}) =>
    Container(
      width: width,
      height: height,
      color: const Color(0xFFF0E6DD),
      alignment: Alignment.center,
      child: const Icon(Icons.business_rounded, color: Color(0xFFB88A68)),
    );

class HallExploreScreen extends StatelessWidget {
  const HallExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ... (Keep your existing ListView and Card code here) ...
    // (If you need the full list code again, let me know, but I'm focusing on the Detail Page fix)

    // For brevity, assuming you have the ListView builder here.
    return Scaffold(
      body: ListView.builder(
        itemCount: ConferenceSeedData.halls.length,
        itemBuilder: (context, index) {
          final hall = ConferenceSeedData.halls[index];
          return ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _hallImage(hall, width: 56, height: 56),
            ),
            title: Text(hall['name']),
            subtitle: Text(
              '${hall['city'] ?? hall['location']} · '
              'From ৳${hall['price_per_day']}',
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => HallDetailsScreen(hall: hall)),
            ),
          );
        },
      ),
    );
  }
}

// --- HALL DETAILS PAGE (FIXED OVERFLOW) ---
class HallDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> hall;
  const HallDetailsScreen({super.key, required this.hall});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F1EA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F1EA),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF3E2C26)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _hallImage(hall, height: 250, width: double.infinity),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hall['name'],
                    style: GoogleFonts.playfairDisplay(
                      color: const Color(0xFF3E2C26),
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '📍 ${hall['location']}',
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFF8A7A75),
                    ),
                  ),
                  if (hall['description'] is String &&
                      (hall['description'] as String).isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      hall['description'] as String,
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF8A7A75),
                        fontSize: 12,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  ConferenceHallAvailabilitySection(details: hall),
                  const SizedBox(height: 32),

                  // --- FIXED OVERFLOW BOTTOM CARD ---
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFF0E6DD)),
                    ),
                    child: Row(
                      children: [
                        // Flexible ensures text doesn't push the button off screen
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Price',
                                style: GoogleFonts.plusJakartaSans(
                                  color: const Color(0xFF8A7A75),
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                '${hall['price_per_day']} BDT',
                                style: GoogleFonts.plusJakartaSans(
                                  color: const Color(0xFFB88A68),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow
                                    .ellipsis, // Prevents text overflow
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () {
                            // Opens the Bottom Sheet correctly
                            showBookingSheet(
                              context,
                              hall['name'],
                              hall['price_per_day'].toString(),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3E2C26),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Book Now',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
