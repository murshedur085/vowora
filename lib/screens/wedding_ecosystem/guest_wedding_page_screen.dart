import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/vowora_theme.dart';
import '../../models/wedding_booking_model.dart';
import '../../providers/wedding_ecosystem_provider.dart';
import '../../routes/app_routes.dart';

class GuestWeddingPageScreen extends StatefulWidget {
  const GuestWeddingPageScreen({super.key});

  @override
  State<GuestWeddingPageScreen> createState() => _GuestWeddingPageScreenState();
}

class _GuestWeddingPageScreenState extends State<GuestWeddingPageScreen> {
  // RSVP Form States
  RSVPStatus _selectedRsvp = RSVPStatus.confirmed;
  int _attendees = 2;
  String _mealPref = 'Royal Mutton Kacchi Feast';
  bool _isRsvpSubmitted = false;

  final TextEditingController _nameCtrl = TextEditingController(text: 'Nusrat Jahan');
  final TextEditingController _phoneCtrl = TextEditingController(text: '+880 1700000003');
  final TextEditingController _notesCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _notesCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToRsvpForm() {
    _scrollCtrl.animateTo(
      _scrollCtrl.position.maxScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _showLeaveEventDialog(BuildContext context, WeddingEcosystemProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1B1714),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Leave Event / Logout? 🚪',
          style: GoogleFonts.playfairDisplay(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to log out of this event session? You can re-join anytime using your secret code.',
          style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await provider.leaveGuestEvent();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, AppRoutes.home);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: VoworaColors.error),
            child: const Text('Logout Event'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WeddingEcosystemProvider>(context);
    final wedding = provider.joinedGuestWedding ?? provider.activeWedding;

    return Scaffold(
      backgroundColor: VoworaColors.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, AppRoutes.home);
            }
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Guest Event Portal 💍',
              style: GoogleFonts.playfairDisplay(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              'Joined via ${wedding.weddingId}',
              style: GoogleFonts.plusJakartaSans(
                color: VoworaColors.champagneGold,
                fontSize: 11,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: VoworaColors.error),
            tooltip: 'Leave Event / Logout',
            onPressed: () => _showLeaveEventDialog(context, provider),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/wedding_background.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.8),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Hero Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          VoworaColors.champagneGold.withValues(alpha: 0.25),
                          Colors.black.withValues(alpha: 0.6),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: VoworaColors.champagneGold, width: 1.5),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'YOU ARE CORDIALLY INVITED TO THE WEDDING OF',
                          style: GoogleFonts.plusJakartaSans(
                            color: VoworaColors.champagneGold,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${wedding.brideName} ❤️ ${wedding.groomName}',
                          style: GoogleFonts.playfairDisplay(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '📅 ${DateFormat('EEEE, MMMM dd, yyyy').format(wedding.weddingDate)} • ${wedding.weddingTime}',
                          style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 12),
                        ),
                        Text(
                          '📍 ${wedding.selectedVenue?.name ?? 'Radisson Garden'}, ${wedding.selectedVenue?.location ?? 'Dhaka'}',
                          style: GoogleFonts.plusJakartaSans(color: VoworaColors.champagneGold, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Prominent Wedding Photography Gallery Banner for Guests
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, AppRoutes.weddingPhotographyGallery),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            VoworaColors.champagneGold.withValues(alpha: 0.35),
                            const Color(0xFF2C2219),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: VoworaColors.champagneGold, width: 1.2),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: VoworaColors.champagneGold.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.photo_camera_rounded, color: VoworaColors.champagneGold, size: 28),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Wedding Photography Gallery 📸',
                                  style: GoogleFonts.playfairDisplay(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Tap to view live wedding photos from Google Drive',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: VoworaColors.champagneGold,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded, color: VoworaColors.champagneGold, size: 16),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Quick Action Tabs Grid for Guest
                  Text('Guest Options', style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),

                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.1,
                    children: [
                      _buildGuestActionCard(
                        title: 'RSVP',
                        icon: Icons.how_to_reg_rounded,
                        color: VoworaColors.champagneGold,
                        onTap: () => _scrollToRsvpForm(),
                      ),
                      _buildGuestActionCard(
                        title: 'Schedule',
                        icon: Icons.access_time_filled_rounded,
                        color: const Color(0xFF6FCFB0),
                        onTap: () => Navigator.pushNamed(context, AppRoutes.weddingSchedule),
                      ),
                      _buildGuestActionCard(
                        title: 'Drive Gallery',
                        icon: Icons.folder_shared_rounded,
                        color: VoworaColors.champagneGold,
                        onTap: () => Navigator.pushNamed(context, AppRoutes.weddingPhotographyGallery),
                      ),
                      _buildGuestActionCard(
                        title: 'Location',
                        icon: Icons.location_on_rounded,
                        color: const Color(0xFF5EC8C4),
                        onTap: () => _showLocationDialog(context, wedding),
                      ),
                      _buildGuestActionCard(
                        title: 'Invitation',
                        icon: Icons.mark_email_read_rounded,
                        color: VoworaColors.champagneGold,
                        onTap: () => _showInvitationModal(context, wedding),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // RSVP Form or Confirmed Pass Container
                  _isRsvpSubmitted
                      ? _buildConfirmedRsvpPassCard(context, provider, wedding)
                      : _buildRsvpFormContainer(context, provider),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- RSVP FORM CONTAINER ---
  Widget _buildRsvpFormContainer(BuildContext context, WeddingEcosystemProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: VoworaColors.champagneGold.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Submit Your RSVP',
            style: GoogleFonts.playfairDisplay(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Please confirm your attendance to help the couple arrange catering & seating.',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white70,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 16),

          // RSVP Status Selector Buttons
          Text('ATTENDANCE STATUS', style: GoogleFonts.plusJakartaSans(color: VoworaColors.champagneGold, fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          Row(
            children: [
              _buildRsvpOptionPill('Yes, I\'ll Attend', RSVPStatus.confirmed),
              const SizedBox(width: 6),
              _buildRsvpOptionPill('Maybe', RSVPStatus.pending),
              const SizedBox(width: 6),
              _buildRsvpOptionPill('Declined', RSVPStatus.declined),
            ],
          ),
          const SizedBox(height: 16),

          // Guest Name & Phone
          TextField(
            controller: _nameCtrl,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(labelText: 'Your Name', labelStyle: TextStyle(color: Colors.white70)),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(labelText: 'Phone Number', labelStyle: TextStyle(color: Colors.white70)),
          ),
          const SizedBox(height: 16),

          // Attendees Count
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('NUMBER OF ATTENDEES', style: GoogleFonts.plusJakartaSans(color: VoworaColors.champagneGold, fontSize: 10, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: Colors.white70),
                    onPressed: () {
                      if (_attendees > 1) setState(() => _attendees--);
                    },
                  ),
                  Text('$_attendees', style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, color: VoworaColors.champagneGold),
                    onPressed: () => setState(() => _attendees++),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Upgraded Meal Preference Cards
          Text('MEAL PREFERENCE 🍽️', style: GoogleFonts.plusJakartaSans(color: VoworaColors.champagneGold, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          const SizedBox(height: 8),

          Column(
            children: [
              _buildMealCard(
                title: 'Royal Mutton Kacchi Feast',
                subtitle: 'Mutton Kacchi Biryani, Chicken Roast & Shahi Borhani',
                icon: Icons.restaurant_menu_rounded,
                mealKey: 'Royal Mutton Kacchi Feast',
              ),
              const SizedBox(height: 8),
              _buildMealCard(
                title: 'Gourmet Vegetarian Menu',
                subtitle: 'Paneer Butter Masala, Vegetable Polao & Dessert',
                icon: Icons.eco_rounded,
                mealKey: 'Gourmet Vegetarian Menu',
              ),
              const SizedBox(height: 8),
              _buildMealCard(
                title: 'Diabetic & Low Salt Special',
                subtitle: 'Grilled Chicken, Brown Rice & Fresh Salad',
                icon: Icons.health_and_safety_rounded,
                mealKey: 'Diabetic & Low Salt Special',
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Submit Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                provider.submitGuestRSVP(
                  name: _nameCtrl.text.trim(),
                  phone: _phoneCtrl.text.trim(),
                  status: _selectedRsvp,
                  attendeesCount: _attendees,
                  mealPref: _mealPref,
                  specialRequest: _notesCtrl.text.trim(),
                );
                setState(() => _isRsvpSubmitted = true);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🎉 RSVP Confirmed! Your Guest Pass is ready below.'),
                    backgroundColor: VoworaColors.success,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: VoworaColors.champagneGold,
                foregroundColor: const Color(0xFF141210),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              child: Text(
                'Confirm RSVP',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- POST-RSVP CONFIRMED PASS CARD ---
  Widget _buildConfirmedRsvpPassCard(
      BuildContext context, WeddingEcosystemProvider provider, WeddingBookingModel wedding) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            VoworaColors.success.withValues(alpha: 0.25),
            const Color(0xFF1C1917),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: VoworaColors.champagneGold, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: VoworaColors.success,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'RSVP CONFIRMED 🎉',
                      style: GoogleFonts.playfairDisplay(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Pass Code: ${wedding.weddingId}',
                      style: GoogleFonts.plusJakartaSans(color: VoworaColors.champagneGold, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24),
          const SizedBox(height: 12),

          // Guest RSVP Details Grid
          _buildPassDetailRow('Guest Name:', _nameCtrl.text.isNotEmpty ? _nameCtrl.text : 'Nusrat Jahan'),
          _buildPassDetailRow('Phone Number:', _phoneCtrl.text.isNotEmpty ? _phoneCtrl.text : '+880 1700000003'),
          _buildPassDetailRow('Attendees:', '$_attendees Guests Confirmed'),
          _buildPassDetailRow('Meal Choice:', _mealPref),
          const SizedBox(height: 20),

          // Action Buttons: Photography Gallery, Edit RSVP, Logout Event
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.weddingPhotographyGallery),
              style: ElevatedButton.styleFrom(
                backgroundColor: VoworaColors.champagneGold,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              icon: const Icon(Icons.photo_library_rounded, size: 20),
              label: Text('Open Wedding Photo Gallery 📸', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => setState(() => _isRsvpSubmitted = false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white38),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: const Icon(Icons.edit_note_rounded, size: 18),
                  label: Text('Edit RSVP', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showLeaveEventDialog(context, provider),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: VoworaColors.error,
                    side: const BorderSide(color: VoworaColors.error),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: const Icon(Icons.logout_rounded, size: 18),
                  label: Text('Logout Event 🚪', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPassDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.plusJakartaSans(color: Colors.white60, fontSize: 12)),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestActionCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 6),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRsvpOptionPill(String label, RSVPStatus status) {
    final isSelected = _selectedRsvp == status;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRsvp = status),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? VoworaColors.champagneGold : Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? VoworaColors.champagneGold : Colors.white24,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              color: isSelected ? const Color(0xFF141210) : Colors.white,
              fontSize: 10.5,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMealCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required String mealKey,
  }) {
    final isSelected = _mealPref == mealKey;
    return GestureDetector(
      onTap: () => setState(() => _mealPref = mealKey),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? VoworaColors.champagneGold.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? VoworaColors.champagneGold : Colors.white12,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? VoworaColors.champagneGold : Colors.white54, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.playfairDisplay(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white60,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: VoworaColors.champagneGold, size: 18),
          ],
        ),
      ),
    );
  }

  void _showLocationDialog(BuildContext context, WeddingBookingModel wedding) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1917),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Venue Location 📍', style: GoogleFonts.playfairDisplay(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(wedding.selectedVenue?.name ?? 'Radisson Blu Garden', style: GoogleFonts.playfairDisplay(color: VoworaColors.champagneGold, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(wedding.selectedVenue?.location ?? 'Airport Road, Cantonment, Dhaka', style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: VoworaColors.champagneGold)),
          ),
        ],
      ),
    );
  }

  void _showInvitationModal(BuildContext context, WeddingBookingModel wedding) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C1917),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Digital Wedding Card 💌', style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text('${wedding.brideName} ❤️ ${wedding.groomName}', style: GoogleFonts.playfairDisplay(color: VoworaColors.champagneGold, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('We request the honor of your presence at our wedding celebration.', textAlign: TextAlign.center, style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: VoworaColors.champagneGold, foregroundColor: Colors.black),
              child: const Text('Close Invitation'),
            ),
          ],
        ),
      ),
    );
  }
}
