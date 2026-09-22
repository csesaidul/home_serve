import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/booking_models.dart';

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return BookingRepository(
    ref.watch(apiClientProvider),
    ref.watch(secureStorageProvider),
  );
});

class BookingRepository {
  BookingRepository(this._client, this._storage);

  final ApiClient _client;
  final SecureStorageService _storage;

  Future<String?> _token() => _storage.readToken();

  Future<List<BookingItem>> listForClient(int clientId) async {
    final json = await _client.get(
      '/booking?client_id=$clientId',
      token: await _token(),
    );
    final items = json['items'] as List<dynamic>? ?? const [];
    return items
        .map((item) =>
            BookingItem.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<BookingItem> create({
    required int clientId,
    required int providerId,
    required int categoryId,
    required DateTime scheduledAt,
    required String address,
    String? customerNotes,
  }) async {
    final json = await _client.post(
      '/booking',
      {
        'client_id': clientId,
        'provider_id': providerId,
        'category_id': categoryId,
        'scheduled_at': scheduledAt.toUtc().toIso8601String(),
        'address': address,
        if (customerNotes != null && customerNotes.trim().isNotEmpty)
          'customer_notes': customerNotes.trim(),
      },
      token: await _token(),
    );
    return BookingItem.fromJson(json);
  }

  Future<BookingItem> confirm(int bookingId) async {
    final json = await _client.post(
      '/booking/$bookingId/confirm',
      {},
      token: await _token(),
    );
    return BookingItem.fromJson(json);
  }

  Future<BookingSummary> summary(int bookingId) async {
    final json = await _client.get(
      '/booking/$bookingId/summary',
      token: await _token(),
    );
    return BookingSummary.fromJson(json);
  }

  Future<BookingProgress> progress(int bookingId) async {
    final json = await _client.get(
      '/booking/$bookingId/progress',
      token: await _token(),
    );
    return BookingProgress.fromJson(json);
  }
}
