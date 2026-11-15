import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/google_drive_service.dart';
import '../../core/services/supabase_database_service.dart';
import '../../core/theme/vowora_theme.dart';
import '../../models/wedding_ecosystem_models.dart';
import '../../providers/wedding_ecosystem_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/vowora_cached_image.dart';

class WeddingPhotographyGalleryScreen extends StatefulWidget {
  const WeddingPhotographyGalleryScreen({super.key});

  @override
  State<WeddingPhotographyGalleryScreen> createState() =>
      _WeddingPhotographyGalleryScreenState();
}

class _WeddingPhotographyGalleryScreenState
    extends State<WeddingPhotographyGalleryScreen> {
  bool _isLoading = true;
  List<GoogleDrivePhotoItem> _drivePhotos = [];
  String? _folderUrl;
  String? _folderId;
  String? _apiKey;
  String? _errorMessage;
  final TextEditingController _folderUrlCtrl = TextEditingController();
  final TextEditingController _apiKeyCtrl = TextEditingController();
  final TextEditingController _photoUrlCtrl = TextEditingController();
  final TextEditingController _photoTitleCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadEventFolderAndPhotos();
  }

  @override
  void dispose() {
    _folderUrlCtrl.dispose();
    _apiKeyCtrl.dispose();
    _photoUrlCtrl.dispose();
    _photoTitleCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadEventFolderAndPhotos() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final provider = Provider.of<WeddingEcosystemProvider>(context, listen: false);
      final weddingId = provider.joinedGuestWedding?.weddingId ?? provider.activeWedding.weddingId;

      // 1. Load from local SharedPreferences (event-specific + global device fallback across logouts)
      final prefs = await SharedPreferences.getInstance();
      _folderUrl = prefs.getString('drive_folder_url_$weddingId') ?? prefs.getString('global_drive_folder_url');
      _folderId = prefs.getString('drive_folder_id_$weddingId') ?? prefs.getString('global_drive_folder_id');
      _apiKey = prefs.getString('drive_api_key_$weddingId') ?? prefs.getString('global_drive_api_key');

      // 2. Also try fetching from Supabase
      final folderData = await SupabaseDatabaseService.fetchWeddingPhotoFolder(weddingId);
      if (folderData != null) {
        _folderUrl = folderData['google_drive_folder_url'] as String? ?? _folderUrl;
        _folderId = folderData['google_drive_folder_id'] as String? ?? _folderId;
      }

      // Sync back to both local and global preferences
      if (_folderUrl != null) {
        prefs.setString('drive_folder_url_$weddingId', _folderUrl!);
        prefs.setString('global_drive_folder_url', _folderUrl!);
        _folderUrlCtrl.text = _folderUrl!;
      }
      if (_folderId != null) {
        prefs.setString('drive_folder_id_$weddingId', _folderId!);
        prefs.setString('global_drive_folder_id', _folderId!);
      }
      if (_apiKey != null) {
        prefs.setString('drive_api_key_$weddingId', _apiKey!);
        prefs.setString('global_drive_api_key', _apiKey!);
        _apiKeyCtrl.text = _apiKey!;
      }

      if (_folderId != null && _folderId!.isNotEmpty) {
        // Load photos from Google Drive folder with optional API key
        _drivePhotos = await GoogleDriveService.fetchFolderPhotos(_folderId!, apiKey: _apiKey);
      } else {
        // Default demo folder if none configured yet
        _drivePhotos = await GoogleDriveService.fetchFolderPhotos('wedding_default_folder_123', apiKey: _apiKey);
      }

      if (mounted && _drivePhotos.isNotEmpty) {
        VoworaImagePreloader.preloadImages(context, _drivePhotos.map((p) => p.thumbnailUrl).toList());
      }
    } catch (e) {
      _errorMessage = 'Could not load photography gallery: $e';
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveFolderLink() async {
    final input = _folderUrlCtrl.text.trim();
    if (input.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid Google Drive folder URL or ID.')),
      );
      return;
    }

    final extractedId = GoogleDriveService.extractFolderId(input);
    if (extractedId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid Google Drive folder link. Please check the URL.')),
      );
      return;
    }

    final apiKeyInput = _apiKeyCtrl.text.trim();

    setState(() => _isLoading = true);

    try {
      final provider = Provider.of<WeddingEcosystemProvider>(context, listen: false);
      final weddingId = provider.joinedGuestWedding?.weddingId ?? provider.activeWedding.weddingId;

      // 1. Save locally to event-specific & global device SharedPreferences permanently
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('drive_folder_url_$weddingId', input);
      await prefs.setString('drive_folder_id_$weddingId', extractedId);
      await prefs.setString('global_drive_folder_url', input);
      await prefs.setString('global_drive_folder_id', extractedId);

      if (apiKeyInput.isNotEmpty) {
        await prefs.setString('drive_api_key_$weddingId', apiKeyInput);
        await prefs.setString('global_drive_api_key', apiKeyInput);
      } else {
        await prefs.remove('drive_api_key_$weddingId');
        await prefs.remove('global_drive_api_key');
      }

      // 2. Save to Supabase
      await SupabaseDatabaseService.upsertWeddingPhotoFolder(
        eventId: weddingId,
        folderUrl: input,
        folderId: extractedId,
        apiKey: apiKeyInput.isNotEmpty ? apiKeyInput : null,
      );

      _folderUrl = input;
      _folderId = extractedId;
      _apiKey = apiKeyInput.isNotEmpty ? apiKeyInput : null;
      _drivePhotos = await GoogleDriveService.fetchFolderPhotos(extractedId, apiKey: _apiKey);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✨ Google Drive folder linked & remembered globally!')),
        );
        Navigator.pop(context); // Close setup modal
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving folder link: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _removeFolderLink() async {
    setState(() => _isLoading = true);
    try {
      final provider = Provider.of<WeddingEcosystemProvider>(context, listen: false);
      final weddingId = provider.joinedGuestWedding?.weddingId ?? provider.activeWedding.weddingId;

      // 1. Remove from local preferences (event & global)
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('drive_folder_url_$weddingId');
      await prefs.remove('drive_folder_id_$weddingId');
      await prefs.remove('drive_api_key_$weddingId');
      await prefs.remove('global_drive_folder_url');
      await prefs.remove('global_drive_folder_id');
      await prefs.remove('global_drive_api_key');

      // 2. Remove from Supabase
      await SupabaseDatabaseService.deleteWeddingPhotoFolder(weddingId);

      _folderUrl = null;
      _folderId = null;
      _apiKey = null;
      _folderUrlCtrl.clear();
      _apiKeyCtrl.clear();
      _drivePhotos = await GoogleDriveService.fetchFolderPhotos('default_empty');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google Drive folder link unlinked.')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error removing folder: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _addPhotoDirectly(BuildContext context) async {
    final url = _photoUrlCtrl.text.trim();
    final title = _photoTitleCtrl.text.trim();
    final messenger = ScaffoldMessenger.of(context);

    if (url.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Please enter an image URL.')),
      );
      return;
    }

    try {
      final provider = Provider.of<WeddingEcosystemProvider>(context, listen: false);
      final weddingId = provider.joinedGuestWedding?.weddingId ?? provider.activeWedding.weddingId;
      final uploaderName = provider.activeRole == UserRole.client ? 'Event Admin' : 'Wedding Guest';
      final activeRole = provider.activeRole;
      final nav = Navigator.of(context);

      final newPhoto = WeddingGalleryPhotoModel(
        id: 'photo_${DateTime.now().millisecondsSinceEpoch}',
        weddingId: weddingId,
        albumName: title.isNotEmpty ? title : 'Wedding Moment',
        imageUrl: url,
        uploaderId: 'user_${DateTime.now().millisecondsSinceEpoch}',
        uploaderName: uploaderName,
        uploaderRole: activeRole,
        uploadTime: DateTime.now(),
        visibility: PhotoVisibility.publicToGuests,
        approvalStatus: PhotoApprovalStatus.approved,
      );

      await SupabaseDatabaseService.insertPhoto(newPhoto);

      _photoUrlCtrl.clear();
      _photoTitleCtrl.clear();

      nav.pop();
      messenger.showSnackBar(
        const SnackBar(content: Text('📸 Photo added successfully to the wedding gallery!')),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Error adding photo: $e')),
      );
    }
  }

  void _showAddPhotoModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1B1714),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 28,
            bottom: MediaQuery.of(context).viewInsets.bottom + 28,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add Wedding Photo 📸',
                    style: GoogleFonts.playfairDisplay(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Add a direct image URL or photo link to share instantly with everyone.',
                style: GoogleFonts.plusJakartaSans(
                  color: VoworaColors.champagneGold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _photoTitleCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Photo Title / Album (e.g. Reception, Ceremony)',
                  labelStyle: const TextStyle(color: Colors.white60),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.08),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _photoUrlCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Image Direct URL (https://...)',
                  labelStyle: const TextStyle(color: Colors.white60),
                  hintText: 'https://images.unsplash.com/...',
                  hintStyle: const TextStyle(color: Colors.white30),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.08),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _addPhotoDirectly(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: VoworaColors.champagneGold,
                    foregroundColor: const Color(0xFF141210),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    'Upload & Share Photo',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDriveFolderSetupModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1B1714),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 28,
            bottom: MediaQuery.of(context).viewInsets.bottom + 28,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Google Drive Folder Setup 📁',
                    style: GoogleFonts.playfairDisplay(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Link a Google Drive folder containing your wedding photographs. Authorized guests joining this event will instantly browse these photos.',
                style: GoogleFonts.plusJakartaSans(
                  color: VoworaColors.champagneGold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _folderUrlCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Google Drive Folder URL or ID',
                  labelStyle: const TextStyle(color: Colors.white60),
                  hintText: 'https://drive.google.com/drive/folders/...',
                  hintStyle: const TextStyle(color: Colors.white30),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.08),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: VoworaColors.champagneGold, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _apiKeyCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Google Drive API Key (Optional for Live Sync)',
                  labelStyle: const TextStyle(color: Colors.white60),
                  hintText: 'Enter Google Cloud API Key',
                  hintStyle: const TextStyle(color: Colors.white30),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.08),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: VoworaColors.champagneGold, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  if (_folderId != null)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _removeFolderLink,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: VoworaColors.error,
                          side: const BorderSide(color: VoworaColors.error),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text('Unlink Folder', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  if (_folderId != null) const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _saveFolderLink,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: VoworaColors.champagneGold,
                        foregroundColor: const Color(0xFF141210),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(
                        'Save & Sync Photos',
                        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _openFullScreenViewer(List<GoogleDrivePhotoItem> photos, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _FullScreenGalleryViewer(
          photos: photos,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WeddingEcosystemProvider>(context);
    final isClient = provider.activeRole == UserRole.client;
    final weddingId = provider.joinedGuestWedding?.weddingId ?? provider.activeWedding.weddingId;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
                'Wedding Photography 📸',
                style: GoogleFonts.playfairDisplay(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Text(
                'Event: $weddingId',
                style: GoogleFonts.plusJakartaSans(
                  color: VoworaColors.champagneGold,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add_a_photo_rounded, color: VoworaColors.champagneGold),
              tooltip: 'Add Photo',
              onPressed: () => _showAddPhotoModal(context),
            ),
            if (isClient)
              IconButton(
                icon: const Icon(Icons.folder_shared_rounded, color: VoworaColors.champagneGold),
                tooltip: 'Configure Drive Folder',
                onPressed: () => _showDriveFolderSetupModal(context),
              ),
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
              tooltip: 'Refresh Gallery',
              onPressed: _loadEventFolderAndPhotos,
            ),
          ],
          bottom: TabBar(
            indicatorColor: VoworaColors.champagneGold,
            labelColor: VoworaColors.champagneGold,
            unselectedLabelColor: Colors.white60,
            tabs: const [
              Tab(text: 'Photo Gallery 📸'),
              Tab(text: 'Overview ℹ️'),
            ],
          ),
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
                color: Colors.black.withValues(alpha: 0.85),
              ),
            ),
            SafeArea(
              child: TabBarView(
                children: [
                  // Tab 1: Live Photo Gallery
                  _buildPhotoGalleryTab(context, weddingId),
                  // Tab 2: Photography Overview & Service Details (For Guests & Admin)
                  _buildOverviewTab(context, weddingId, isClient),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoGalleryTab(BuildContext context, String weddingId) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: SupabaseDatabaseService.streamPhotos(weddingId),
      builder: (context, snapshot) {
        // Combine Supabase real-time photos with Google Drive folder photos
        List<GoogleDrivePhotoItem> combinedPhotos = [];

        // 1. Add Supabase real-time photos first
        if (snapshot.hasData && snapshot.data != null) {
          final sbPhotos = snapshot.data!.map((json) {
            final imgUrl = json['image_url'] as String? ?? '';
            final title = json['album_name'] as String? ?? 'Wedding Photo';
            final id = json['id'] as String? ?? 'sb_${json.hashCode}';
            return GoogleDrivePhotoItem(
              id: id,
              name: title,
              thumbnailUrl: imgUrl,
              highResUrl: imgUrl,
              createdTime: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
            );
          }).toList();
          combinedPhotos.addAll(sbPhotos);
        }

        // 2. Add Google Drive folder photos
        combinedPhotos.addAll(_drivePhotos);

        return RefreshIndicator(
          color: VoworaColors.champagneGold,
          backgroundColor: const Color(0xFF1B1714),
          onRefresh: _loadEventFolderAndPhotos,
          child: _isLoading && combinedPhotos.isEmpty
              ? const Center(
                  child: CircularProgressIndicator(color: VoworaColors.champagneGold),
                )
              : _errorMessage != null && combinedPhotos.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline_rounded, color: VoworaColors.error, size: 48),
                            const SizedBox(height: 12),
                            Text(
                              _errorMessage!,
                              style: GoogleFonts.plusJakartaSans(color: Colors.white70),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadEventFolderAndPhotos,
                              style: ElevatedButton.styleFrom(backgroundColor: VoworaColors.champagneGold),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : combinedPhotos.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.photo_library_outlined, color: Colors.white38, size: 64),
                              const SizedBox(height: 16),
                              Text(
                                'No photographs found.',
                                style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 18),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap + above to add photos or link your Google Drive folder.',
                                style: GoogleFonts.plusJakartaSans(color: Colors.white60, fontSize: 12),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Info Header Banner
                            Container(
                              margin: const EdgeInsets.all(16),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    VoworaColors.champagneGold.withValues(alpha: 0.2),
                                    Colors.black.withValues(alpha: 0.5),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: VoworaColors.champagneGold.withValues(alpha: 0.5)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.auto_awesome, color: VoworaColors.champagneGold, size: 22),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Live Wedding Photography Gallery',
                                          style: GoogleFonts.playfairDisplay(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                        ),
                                        Text(
                                          _folderUrl != null ? 'Drive Folder Linked (${combinedPhotos.length} Items)' : 'Cloud Synced Gallery (${combinedPhotos.length} Items)',
                                          style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 11),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '${combinedPhotos.length} Photos',
                                    style: GoogleFonts.plusJakartaSans(color: VoworaColors.champagneGold, fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),

                            // 3-Column Photo Grid
                            Expanded(
                              child: GridView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                  childAspectRatio: 1.0,
                                ),
                                itemCount: combinedPhotos.length,
                                itemBuilder: (context, index) {
                                  final photo = combinedPhotos[index];
                                  return GestureDetector(
                                    onTap: () => _openFullScreenViewer(combinedPhotos, index),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          VoworaCachedImage(
                                            imageUrl: photo.thumbnailUrl,
                                            fit: BoxFit.cover,
                                            contextSize: ImageContextSize.thumbnail,
                                          ),
                                          Positioned(
                                            bottom: 0,
                                            left: 0,
                                            right: 0,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.bottomCenter,
                                                  end: Alignment.topCenter,
                                                  colors: [Colors.black.withValues(alpha: 0.8), Colors.transparent],
                                                ),
                                              ),
                                              child: Text(
                                                photo.name,
                                                style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 9),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
        );
      },
    );
  }

  Widget _buildOverviewTab(BuildContext context, String weddingId, bool isClient) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  VoworaColors.champagneGold.withValues(alpha: 0.3),
                  Colors.black.withValues(alpha: 0.6),
                ],
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: VoworaColors.champagneGold, width: 1.2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'WEDDING PHOTOGRAPHY OVERVIEW',
                  style: GoogleFonts.plusJakartaSans(
                    color: VoworaColors.champagneGold,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Captured Moments & Live Cloud Gallery 📷',
                  style: GoogleFonts.playfairDisplay(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Explore official photography coverage, live Google Drive photo album, and guest moment submissions.',
                  style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Google Drive Sync Card
          Text(
            'Google Drive Live Folder Status',
            style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: Row(
              children: [
                const Icon(Icons.cloud_done_rounded, color: VoworaColors.champagneGold, size: 28),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _folderUrl != null ? 'Linked Drive Folder Active' : 'Default Collection Active',
                        style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _folderUrl ?? 'No custom folder linked yet',
                        style: GoogleFonts.plusJakartaSans(color: Colors.white60, fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (isClient)
                  IconButton(
                    icon: const Icon(Icons.edit_rounded, color: VoworaColors.champagneGold),
                    onPressed: () => _showDriveFolderSetupModal(context),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Photography Coverage Highlights
          Text(
            'Coverage & Service Details',
            style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          _buildOverviewDetailTile(
            title: 'Lead Photographer & Crew',
            subtitle: '1 Senior Lead Photographer + 2 Cinematic Camera Operators',
            icon: Icons.camera_enhance_rounded,
          ),
          _buildOverviewDetailTile(
            title: 'Cinematic Drone & Reels',
            subtitle: '4K Ultra HD Aerial Shots & Instagram Reels Highlights',
            icon: Icons.videocam_rounded,
          ),
          _buildOverviewDetailTile(
            title: 'Delivered Deliverables',
            subtitle: '100 Color Graded Soft Copies + Custom Premium Printed Album',
            icon: Icons.photo_album_rounded,
          ),
          _buildOverviewDetailTile(
            title: 'Guest Moments Submission',
            subtitle: 'Guests can tap + in the Photo Gallery to upload live wedding moments',
            icon: Icons.add_a_photo_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewDetailTile({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Icon(icon, color: VoworaColors.champagneGold, size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(color: Colors.white60, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Full Screen Image Viewer with PageView (Swipe Left/Right) & Pinch-to-Zoom
class _FullScreenGalleryViewer extends StatefulWidget {
  final List<GoogleDrivePhotoItem> photos;
  final int initialIndex;

  const _FullScreenGalleryViewer({
    required this.photos,
    required this.initialIndex,
  });

  @override
  State<_FullScreenGalleryViewer> createState() => _FullScreenGalleryViewerState();
}

class _FullScreenGalleryViewerState extends State<_FullScreenGalleryViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Photo ${_currentIndex + 1} of ${widget.photos.length}',
          style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.photos.length,
        onPageChanged: (idx) => setState(() => _currentIndex = idx),
        itemBuilder: (context, index) {
          final photo = widget.photos[index];
          return InteractiveViewer(
            minScale: 1.0,
            maxScale: 4.0,
            child: Center(
              child: VoworaCachedImage(
                imageUrl: photo.highResUrl,
                fit: BoxFit.contain,
              ),
            ),
          );
        },
      ),
    );
  }
}
