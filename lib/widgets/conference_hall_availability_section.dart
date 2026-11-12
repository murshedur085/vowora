import 'package:flutter/material.dart';

class ConferenceHallAvailabilitySection extends StatelessWidget {
  const ConferenceHallAvailabilitySection({super.key, required this.details});

  final Map<String, dynamic> details;

  @override
  Widget build(BuildContext context) {
    final facilities = details['facilities'];
    final policies = details['policies'];
    final options = [
      _HallAvailabilityOption(
        'AC support',
        _facilityValue('ac', 'AC', facilities),
      ),
      _HallAvailabilityOption(
        'Wi-Fi',
        _facilityValue('wifi', 'WiFi', facilities),
      ),
      _HallAvailabilityOption(
        'Parking',
        _facilityValue('parking', 'Parking', facilities),
      ),
      _HallAvailabilityOption(
        'Outside food',
        _policyValue(policies, 'outside_food'),
        isPolicy: true,
      ),
      _HallAvailabilityOption(
        'Outside decoration',
        _policyValue(policies, 'outside_decoration'),
        isPolicy: true,
      ),
      _HallAvailabilityOption(
        'Outside sound system',
        _policyValue(policies, 'outside_sound'),
        isPolicy: true,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Facilities & policies',
          style: TextStyle(
            color: Color(0xFF3E2C26),
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final itemWidth = (constraints.maxWidth - 8) / 2;
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: options
                  .map(
                    (option) => SizedBox(
                      width: itemWidth,
                      child: _AvailabilityCard(option: option),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  bool? _facilityValue(String key, String facility, dynamic rawFacilities) {
    final value = details[key];
    if (value is bool) return value;
    if (rawFacilities is List) return rawFacilities.contains(facility);
    return null;
  }

  bool? _policyValue(dynamic rawPolicies, String key) {
    if (rawPolicies is! Map) return null;
    final value = rawPolicies[key];
    return value is bool ? value : null;
  }
}

class _HallAvailabilityOption {
  const _HallAvailabilityOption(
    this.label,
    this.value, {
    this.isPolicy = false,
  });

  final String label;
  final bool? value;
  final bool isPolicy;
}

class _AvailabilityCard extends StatelessWidget {
  const _AvailabilityCard({required this.option});

  final _HallAvailabilityOption option;

  @override
  Widget build(BuildContext context) {
    final value = option.value;
    final color = value == null
        ? const Color(0xFF8A7A75)
        : value
        ? const Color(0xFF39734A)
        : const Color(0xFF9A5147);
    final status = value == null
        ? 'Not specified'
        : option.isPolicy
        ? value
              ? 'Allowed'
              : 'Not allowed'
        : value
        ? 'Available'
        : 'Not available';

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE9DED5)),
      ),
      child: Row(
        children: [
          Icon(
            value == null
                ? Icons.help_outline_rounded
                : value
                ? Icons.check_circle_outline_rounded
                : Icons.cancel_outlined,
            color: color,
            size: 18,
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  option.label,
                  style: const TextStyle(
                    color: Color(0xFF3E2C26),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  status,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
