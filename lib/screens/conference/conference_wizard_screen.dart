import 'package:flutter/material.dart';

import '../../models/conference/conference_event.dart';
import '../../models/conference/conference_provider.dart';
import '../../models/conference/conference_service_booking.dart';
import '../../services/conference_repository.dart';
import '../../widgets/conference_progress_indicator.dart';
import '../../widgets/conference_provider_image.dart';
import 'conference_booking_selection_sheet.dart';
import 'conference_summary_screen.dart';

class ConferenceWizardScreen extends StatefulWidget {
  const ConferenceWizardScreen({
    super.key,
    required this.conference,
    this.initialStep = 0,
    this.returnToSummary = false,
  });

  final ConferenceEvent conference;
  final int initialStep;
  final bool returnToSummary;

  @override
  State<ConferenceWizardScreen> createState() => _ConferenceWizardScreenState();
}

class _ConferenceWizardScreenState extends State<ConferenceWizardScreen> {
  late int _currentStep;
  List<ConferenceProvider> _providers = [];
  List<ConferenceServiceBooking> _bookings = [];
  final Set<String> _skippedCategories = {};
  final _searchController = TextEditingController();
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;

  ConferenceServiceCategory get _category =>
      ConferenceServiceCategory.steps[_currentStep];

  String get _providerHeading => switch (_category.key) {
    'hall' => 'Choose Best Halls of Your City',
    'food' => 'Choose Best Restaurants of Your City',
    'sound' => 'Choose Best Sound & Screen Providers of Your City',
    'decoration' => 'Choose Best Decorators of Your City',
    'photography' => 'Choose Best Photographers of Your City',
    'transportation' => 'Choose Best Transport Providers of Your City',
    _ => 'Choose Best Providers of Your City',
  };

  ConferenceServiceBooking? get _currentBooking {
    for (final booking in _bookings) {
      if (booking.category == _category.key) return booking;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _currentStep = widget.initialStep
        .clamp(0, ConferenceServiceCategory.steps.length - 1)
        .toInt();
    _loadStep();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadStep() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final values = await Future.wait([
        ConferenceRepository.getProviders(
          category: _category.key,
          city: widget.conference.location,
        ),
        ConferenceRepository.getBookings(widget.conference),
      ]);
      if (!mounted) return;
      setState(() {
        _providers = values[0] as List<ConferenceProvider>;
        _bookings = values[1] as List<ConferenceServiceBooking>;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _selectProvider(ConferenceProvider provider) async {
    final current = _currentBooking;
    final draft = await showModalBottomSheet<ConferenceBookingDraft>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFF8F1EA),
      builder: (_) => ConferenceBookingSelectionSheet(
        provider: provider,
        previousDetails: current?.providerId == provider.id
            ? current!.selectionDetails
            : {},
      ),
    );
    if (draft == null || !mounted) return;

    setState(() => _isSaving = true);
    try {
      final booking = await ConferenceRepository.saveBooking(
        event: widget.conference,
        provider: provider,
        packageName: draft.packageName,
        totalPrice: draft.totalPrice,
        selectionDetails: draft.details,
      );
      if (!mounted) return;
      setState(() {
        _bookings = [
          ..._bookings.where((item) => item.category != _category.key),
          booking,
        ];
        _skippedCategories.remove(_category.key);
        _isSaving = false;
      });
      _showMessage('${_category.label} selection saved.');
      _advance();
    } catch (error) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      _showMessage(
        error is ConferenceBookingUnavailableException
            ? error.toString()
            : 'Could not save this booking: $error',
      );
    }
  }

  void _skip() {
    if (_currentBooking == null) {
      _skippedCategories.add(_category.key);
    }
    _advance();
  }

  void _advance() {
    if (_currentStep == ConferenceServiceCategory.steps.length - 1) {
      _finish();
      return;
    }
    _setStep(_currentStep + 1);
  }

  void _back() {
    if (_currentStep == 0) {
      Navigator.of(context).maybePop();
      return;
    }
    _setStep(_currentStep - 1);
  }

  void _setStep(int index) {
    setState(() {
      _currentStep = index;
      _searchController.clear();
    });
    _loadStep();
  }

  void _finish() {
    if (widget.returnToSummary) {
      Navigator.of(context).pop();
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => ConferenceSummaryScreen(
          conference: widget.conference,
          showProfileHint: true,
        ),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.black)),
        backgroundColor: const Color(0xFFE9DED5),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const text = Colors.black;
    final bookedCategories = _bookings.map((item) => item.category).toSet();
    final query = _searchController.text.trim().toLowerCase();
    final visibleProviders = _providers
        .where((provider) => provider.name.toLowerCase().contains(query))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F1EA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F1EA),
        foregroundColor: text,
        elevation: 0,
        title: const Text(
          'Conference services',
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          onPressed: _back,
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        actions: [
          IconButton(
            tooltip: 'Conference summary',
            onPressed: _finish,
            icon: const Icon(Icons.receipt_long_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 14),
              child: ConferenceProgressIndicator(
                labels: ConferenceServiceCategory.steps
                    .map((step) => step.label)
                    .toList(),
                currentIndex: _currentStep,
                bookedCategories: bookedCategories,
                skippedCategories: _skippedCategories,
                onStepSelected: _setStep,
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFB88A68),
                      ),
                    )
                  : _error != null
                  ? _buildError()
                  : _providers.isEmpty
                  ? _buildEmpty()
                  : visibleProviders.isEmpty
                  ? _buildSearchEmpty()
                  : Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 2, 20, 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _providerHeading,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      color: text,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 20,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_category.label} near ${widget.conference.location}',
                                style: const TextStyle(color: Colors.black),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _searchController,
                                onChanged: (_) => setState(() {}),
                                decoration: InputDecoration(
                                  hintText: 'Search providers',
                                  hintStyle: const TextStyle(
                                    color: Colors.black,
                                  ),
                                  prefixIcon: const Icon(Icons.search_rounded),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                style: const TextStyle(color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                            itemCount: visibleProviders.length,
                            itemBuilder: (context, index) => _providerCard(
                              visibleProviders[index],
                              bookedCategories,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
            _buildNavigation(bookedCategories),
          ],
        ),
      ),
    );
  }

  Widget _providerCard(
    ConferenceProvider provider,
    Set<String> bookedCategories,
  ) {
    final isSelected = _currentBooking?.providerId == provider.id;
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: isSelected ? const Color(0xFFB88A68) : const Color(0xFFE9DED5),
          width: isSelected ? 1.5 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 2.6,
            child: ConferenceProviderImage(
              imageUrl: provider.imageUrl,
              placeholderIcon: _providerPlaceholder(provider.category),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        provider.name,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  '${provider.city} · From ৳${provider.startingPrice}',
                  style: const TextStyle(color: Colors.black),
                ),
                if (provider.rating != null ||
                    _contactFor(provider).isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    [
                      if (provider.rating != null)
                        '★ ${provider.rating!.toStringAsFixed(1)}',
                      if (_contactFor(provider).isNotEmpty)
                        _contactFor(provider),
                    ].join(' · '),
                    style: const TextStyle(color: Colors.black, fontSize: 11),
                  ),
                ],
                if (provider.description.isNotEmpty) ...[
                  const SizedBox(height: 7),
                  Text(
                    provider.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _isSaving
                        ? null
                        : () => _selectProvider(provider),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Color(0xFFB88A68)),
                    ),
                    child: Text(isSelected ? 'Edit selection' : 'View details'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigation(Set<String> bookedCategories) {
    final hasBooking = bookedCategories.contains(_category.key);
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE9DED5))),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _back,
              style: OutlinedButton.styleFrom(foregroundColor: Colors.black),
              child: Text(_currentStep == 0 ? 'Exit' : 'Back'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextButton(
              onPressed: _skip,
              style: TextButton.styleFrom(foregroundColor: Colors.black),
              child: Text(
                _currentStep == ConferenceServiceCategory.steps.length - 1
                    ? 'Finish'
                    : 'Skip',
              ),
            ),
          ),
          if (hasBooking) ...[
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton(
                onPressed: _advance,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFE9DED5),
                  foregroundColor: Colors.black,
                ),
                child: const Text('Continue'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _contactFor(ConferenceProvider provider) =>
      (provider.details['contact_phone'] ??
              provider.details['phone'] ??
              provider.details['contact'])
          ?.toString() ??
      '';

  IconData _providerPlaceholder(String category) => switch (category) {
    'food' => Icons.restaurant_rounded,
    'sound' => Icons.speaker_group_outlined,
    'decoration' => Icons.local_florist_outlined,
    'photography' => Icons.camera_alt_outlined,
    'transportation' => Icons.directions_car_outlined,
    _ => Icons.business_rounded,
  };

  Widget _buildError() => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_outlined, size: 40),
          const SizedBox(height: 12),
          const Text(
            'Providers could not be loaded.',
            style: TextStyle(color: Colors.black),
          ),
          const SizedBox(height: 6),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black, fontSize: 12),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _loadStep,
            style: OutlinedButton.styleFrom(foregroundColor: Colors.black),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    ),
  );

  Widget _buildEmpty() => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.search_off_rounded,
            size: 42,
            color: Color(0xFFB88A68),
          ),
          const SizedBox(height: 12),
          Text(
            'No ${_category.label.toLowerCase()} found in ${widget.conference.location}.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'You can skip this step or add providers in the Supabase conference_providers table.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black, fontSize: 12),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: _loadStep,
            style: OutlinedButton.styleFrom(foregroundColor: Colors.black),
            child: const Text('Retry'),
          ),
        ],
      ),
    ),
  );

  Widget _buildSearchEmpty() => const Center(
    child: Padding(
      padding: EdgeInsets.all(28),
      child: Text(
        'No providers match your search.',
        style: TextStyle(color: Colors.black),
      ),
    ),
  );
}
