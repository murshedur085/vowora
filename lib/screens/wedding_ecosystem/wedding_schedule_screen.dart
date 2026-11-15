import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/vowora_theme.dart';
import '../../models/wedding_ecosystem_models.dart';
import '../../providers/wedding_ecosystem_provider.dart';

class WeddingScheduleScreen extends StatelessWidget {
  const WeddingScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WeddingEcosystemProvider>(context);
    final isClient = provider.activeRole == UserRole.client;
    final schedule = provider.scheduleItems;
    final List<WeddingScheduleItemModel> displaySchedule = schedule.isNotEmpty
        ? schedule
        : [
            WeddingScheduleItemModel(
              id: 'ds1',
              weddingId: 'demo',
              timeString: '05:00 PM',
              title: 'Guest Arrival & Welcome Drink 🍹',
              description: 'Guests arrive at the venue and enjoy welcome refreshments & mocktails.',
              location: 'Main Arch & Reception Area',
            ),
            WeddingScheduleItemModel(
              id: 'ds2',
              weddingId: 'demo',
              timeString: '06:30 PM',
              title: 'Nikah & Ring Ceremony 💍',
              description: 'Official wedding ritual, vow signing, and exchange of rings.',
              location: 'Main Stage',
            ),
            WeddingScheduleItemModel(
              id: 'ds3',
              weddingId: 'demo',
              timeString: '08:00 PM',
              title: 'Grand Royal Dinner 🍽️',
              description: 'Traditional wedding feast with Kacchi Biryani & desserts.',
              location: 'Dining Hall',
            ),
            WeddingScheduleItemModel(
              id: 'ds4',
              weddingId: 'demo',
              timeString: '09:30 PM',
              title: 'Photoshoot & Guest Moments 📸',
              description: 'Family portraits, candid guest photo sessions, and video reels.',
              location: 'Photo Stage & Floral Arch',
            ),
            WeddingScheduleItemModel(
              id: 'ds5',
              weddingId: 'demo',
              timeString: '10:30 PM',
              title: 'Cultural Music & Farewell 🎶',
              description: 'Live acoustic music performance followed by bride & groom farewell.',
              location: 'Main Stage',
            ),
          ];

    return Scaffold(
      backgroundColor: VoworaColors.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Wedding Schedule ⏱️',
          style: GoogleFonts.playfairDisplay(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (isClient)
            IconButton(
              icon: const Icon(Icons.add_circle_outline_rounded, color: VoworaColors.champagneGold),
              onPressed: () => _showAddScheduleModal(context, provider),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Event Schedule & Timeline',
                style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Follow the event sequence on your special day.',
                style: GoogleFonts.plusJakartaSans(color: VoworaColors.champagneGold, fontSize: 12),
              ),
              const SizedBox(height: 20),

              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: displaySchedule.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final item = displaySchedule[index];
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Time Pillar
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: VoworaColors.champagneGold.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: VoworaColors.champagneGold.withValues(alpha: 0.5)),
                        ),
                        child: Text(
                          item.timeString,
                          style: GoogleFonts.plusJakartaSans(
                            color: VoworaColors.champagneGold,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Schedule Content Card
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    item.title,
                                    style: GoogleFonts.playfairDisplay(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  if (isClient)
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.white38, size: 16),
                                      onPressed: () => provider.deleteScheduleItem(item.id),
                                    ),
                                ],
                              ),
                              Text('📍 ${item.location}', style: GoogleFonts.plusJakartaSans(color: VoworaColors.champagneGold, fontSize: 10.5)),
                              const SizedBox(height: 4),
                              Text(item.description, style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 11)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddScheduleModal(BuildContext context, WeddingEcosystemProvider provider) {
    final timeCtrl = TextEditingController(text: '08:30 PM');
    final titleCtrl = TextEditingController();
    final locCtrl = TextEditingController(text: 'Main Stage');
    final descCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF181513),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add Schedule Milestone', style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                controller: timeCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Time (e.g. 08:30 PM)', labelStyle: TextStyle(color: Colors.white70)),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: titleCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Event Title', labelStyle: TextStyle(color: Colors.white70)),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: locCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Location', labelStyle: TextStyle(color: Colors.white70)),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    if (titleCtrl.text.trim().isNotEmpty) {
                      provider.addScheduleItem(
                        WeddingScheduleItemModel(
                          id: 'sch_${DateTime.now().millisecondsSinceEpoch}',
                          weddingId: provider.activeWedding.weddingId,
                          timeString: timeCtrl.text.trim(),
                          title: titleCtrl.text.trim(),
                          description: descCtrl.text.trim(),
                          location: locCtrl.text.trim(),
                        ),
                      );
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: VoworaColors.champagneGold, foregroundColor: Colors.black),
                  child: Text('Save Schedule Item', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
