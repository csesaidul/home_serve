class BookingItem {
  const BookingItem({required this.id, required this.status});

  final int id;
  final String status;

  factory BookingItem.fromJson(Map<String, dynamic> json) => BookingItem(
        id: (json['id'] as num?)?.toInt() ?? 0,
        status: json['status'] as String? ?? 'requested',
      );
}

class BookingSummary {
  const BookingSummary({
    required this.bookingId,
    required this.categoryName,
    required this.address,
    required this.scheduledAt,
    required this.baseCharge,
    required this.platformFee,
    required this.total,
    required this.providerName,
  });

  final int bookingId;
  final String categoryName;
  final String address;
  final DateTime scheduledAt;
  final double baseCharge;
  final double platformFee;
  final double total;
  final String providerName;

  factory BookingSummary.fromJson(Map<String, dynamic> json) {
    final payment = Map<String, dynamic>.from(json['payment'] as Map? ?? {});
    final provider = Map<String, dynamic>.from(json['provider'] as Map? ?? {});
    return BookingSummary(
      bookingId: (json['booking_id'] as num?)?.toInt() ?? 0,
      categoryName: json['category_name'] as String? ?? 'Home service',
      address: json['address'] as String? ?? '',
      scheduledAt:
          DateTime.tryParse(json['scheduled_at'].toString()) ?? DateTime.now(),
      baseCharge: (payment['base_inspection_charge'] as num?)?.toDouble() ?? 0,
      platformFee:
          (payment['safety_and_platform_fee'] as num?)?.toDouble() ?? 0,
      total: (payment['estimated_total'] as num?)?.toDouble() ?? 0,
      providerName: provider['name'] as String? ?? 'Selected provider',
    );
  }
}

class BookingProgress {
  const BookingProgress({required this.currentStatus, required this.steps});

  final String currentStatus;
  final List<BookingProgressStep> steps;

  factory BookingProgress.fromJson(Map<String, dynamic> json) =>
      BookingProgress(
        currentStatus: json['current_status'] as String? ?? 'requested',
        steps: (json['steps'] as List<dynamic>? ?? const [])
            .map((step) => BookingProgressStep.fromJson(
                Map<String, dynamic>.from(step as Map)))
            .toList(),
      );
}

class BookingProgressStep {
  const BookingProgressStep({required this.label, required this.state});

  final String label;
  final String state;

  factory BookingProgressStep.fromJson(Map<String, dynamic> json) =>
      BookingProgressStep(
        label: json['label'] as String? ?? '',
        state: json['state'] as String? ?? 'pending',
      );
}
