import 'package:flutter/material.dart';

import '../../models/conference/conference_event.dart';
import '../../services/conference_repository.dart';
import 'conference_wizard_screen.dart';

class ConferenceCreateScreen extends StatefulWidget {
  const ConferenceCreateScreen({super.key, this.conference});

  final ConferenceEvent? conference;

  @override
  State<ConferenceCreateScreen> createState() => _ConferenceCreateScreenState();
}

class _ConferenceCreateScreenState extends State<ConferenceCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _sloganController;
  late final TextEditingController _organizerController;
  late final TextEditingController _emailController;
  late final TextEditingController _locationController;
  DateTime? _eventDate;
  bool _isSaving = false;

  bool get _isEditing => widget.conference != null;

  @override
  void initState() {
    super.initState();
    final event = widget.conference;
    _titleController = TextEditingController(text: event?.title ?? '');
    _sloganController = TextEditingController(text: event?.slogan ?? '');
    _organizerController = TextEditingController(
      text: event?.organizerName ?? '',
    );
    _emailController = TextEditingController(text: event?.organizerEmail ?? '');
    _locationController = TextEditingController(
      text: event?.location ?? 'Dhaka',
    );
    _eventDate = event?.eventDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _sloganController.dispose();
    _organizerController.dispose();
    _emailController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final date = await showDatePicker(
      context: context,
      initialDate: _eventDate ?? today.add(const Duration(days: 14)),
      firstDate: today,
      lastDate: DateTime(today.year + 5),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFFE9DED5),
            onPrimary: Colors.black,
            surface: Colors.white,
            onSurface: Colors.black,
          ),
        ),
        child: child!,
      ),
    );
    if (date != null) setState(() => _eventDate = date);
  }

  Future<void> _create() async {
    if (!_formKey.currentState!.validate()) return;
    if (_eventDate == null) {
      _showMessage('Select an event date to continue.');
      return;
    }

    setState(() => _isSaving = true);
    try {
      if (_isEditing) {
        final updated = await ConferenceRepository.updateConferenceDetails(
          event: widget.conference!,
          title: _titleController.text,
          slogan: _sloganController.text,
          organizerName: _organizerController.text,
          organizerEmail: _emailController.text,
          location: _locationController.text,
        );
        if (!mounted) return;
        Navigator.of(context).pop(updated);
        return;
      }

      final event = await ConferenceRepository.createConference(
        title: _titleController.text,
        slogan: _sloganController.text,
        eventDate: _eventDate!,
        organizerName: _organizerController.text,
        organizerEmail: _emailController.text,
        location: _locationController.text,
      );
      if (!mounted) return;
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => ConferenceWizardScreen(conference: event),
        ),
      );
    } catch (error) {
      if (mounted) _showMessage('Could not save conference: $error');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    const textColor = Colors.black;
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFFE9DED5),
          onPrimary: Colors.black,
          surface: Colors.white,
          onSurface: Colors.black,
        ),
        textTheme: theme.textTheme.apply(
          bodyColor: Colors.black,
          displayColor: Colors.black,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF8F1EA),
          foregroundColor: Colors.black,
          titleTextStyle: TextStyle(color: Colors.black, fontSize: 20),
        ),
        inputDecorationTheme: theme.inputDecorationTheme.copyWith(
          labelStyle: const TextStyle(color: Colors.black),
          hintStyle: const TextStyle(color: Colors.black),
          errorStyle: const TextStyle(color: Colors.black),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: Colors.black),
        ),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F1EA),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF8F1EA),
          foregroundColor: textColor,
          elevation: 0,
          title: Text(
            _isEditing ? 'Edit Conference' : 'Create Conference',
            style: const TextStyle(color: textColor),
          ),
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
              children: [
                Text(
                  _isEditing
                      ? 'Update conference details'
                      : 'Start with the details',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your conference and provider selections will be saved together.',
                  style: TextStyle(color: textColor, height: 1.4),
                ),
                const SizedBox(height: 24),
                _field(
                  controller: _titleController,
                  label: 'Conference Title',
                  validator: _required,
                ),
                const SizedBox(height: 14),
                _field(
                  controller: _sloganController,
                  label: 'Moto',
                  validator: _required,
                ),
                const SizedBox(height: 14),
                InkWell(
                  onTap: _isSaving || _isEditing ? null : _selectDate,
                  borderRadius: BorderRadius.circular(14),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Event Date',
                      labelStyle: TextStyle(color: textColor),
                      floatingLabelStyle: TextStyle(color: textColor),
                      prefixIcon: Icon(
                        Icons.calendar_today_outlined,
                        color: textColor,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                      ),
                    ),
                    child: Text(
                      _eventDate == null
                          ? 'Choose a date'
                          : MaterialLocalizations.of(
                              context,
                            ).formatMediumDate(_eventDate!),
                      style: const TextStyle(color: textColor),
                    ),
                  ),
                ),
                if (_isEditing) ...[
                  const SizedBox(height: 5),
                  const Text(
                    'Change the event date from the conference summary.',
                    style: TextStyle(color: textColor, fontSize: 12),
                  ),
                ],
                const SizedBox(height: 14),
                _field(
                  controller: _organizerController,
                  label: 'Organizer Name',
                  validator: _required,
                ),
                const SizedBox(height: 14),
                _field(
                  controller: _emailController,
                  label: 'Organizer Email',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    final requiredError = _required(value);
                    if (requiredError != null) return requiredError;
                    final email = value!.trim();
                    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)
                        ? null
                        : 'Enter a valid email address.';
                  },
                ),
                const SizedBox(height: 14),
                _field(
                  controller: _locationController,
                  label: 'City / Location',
                  validator: _required,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _create,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE9DED5),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox.square(
                            dimension: 21,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black,
                            ),
                          )
                        : Text(_isEditing ? 'Save changes' : 'Continue'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: TextCapitalization.sentences,
      validator: validator,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black),
        floatingLabelStyle: const TextStyle(color: Colors.black),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE9DED5)),
        ),
      ),
    );
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'This field is required.' : null;
}
