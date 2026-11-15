import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/vowora_theme.dart';
import '../routes/app_routes.dart';
import '../widgets/vowora_button.dart';

class ComingSoonScreen extends StatelessWidget {
  final String title;
  final String subtitle;

  const ComingSoonScreen({
    super.key,
    required this.title,
    this.subtitle = 'We are crafting an exceptional luxury experience for this module.',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
              shape: BoxShape.circle,
              border: Border.all(color: VoworaColors.champagneGold.withValues(alpha: 0.3)),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/wedding_background.png',
            fit: BoxFit.cover,
          ),
          Container(
            color: Colors.black.withValues(alpha: 0.75),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: VoworaColors.champagneGold.withValues(alpha: 0.15),
                      border: Border.all(color: VoworaColors.champagneGold.withValues(alpha: 0.4), width: 1.5),
                    ),
                    child: const Icon(
                      Icons.hourglass_top_rounded,
                      color: VoworaColors.champagneGold,
                      size: 44,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    title,
                    style: GoogleFonts.playfairDisplay(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: VoworaColors.champagneGold.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: VoworaColors.champagneGold.withValues(alpha: 0.5)),
                    ),
                    child: Text(
                      'Coming Soon',
                      style: GoogleFonts.plusJakartaSans(
                        color: VoworaColors.champagneGold,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    child: VoworaPrimaryButton(
                      text: 'Go to Home Page',
                      showArrow: false,
                      onPressed: () => Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.home,
                        (route) => false,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Back',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
