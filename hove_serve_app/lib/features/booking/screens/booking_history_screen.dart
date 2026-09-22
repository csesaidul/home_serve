import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/providers/auth_provider.dart';
import '../data/booking_repository.dart';
import '../models/booking_models.dart';

final bookingHistoryProvider =
    FutureProvider.autoDispose<List<BookingItem>>((ref) async {
  final clientId =
      (ref.watch(authProvider).claims?['user_id'] as num?)?.toInt();
  if (clientId == null) return const [];
  return ref.watch(bookingRepositoryProvider).listForClient(clientId);
});

class BookingHistoryScreen extends ConsumerWidget {
  const BookingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookings = ref.watch(bookingHistoryProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Bookings')),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(bookingHistoryProvider.future),
        child: bookings.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              const SizedBox(height: 180),
              Center(child: Text('Unable to load bookings: $error')),
            ],
          ),
          data: (items) => items.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: 180),
                    Center(child: Text('No bookings yet')),
                  ],
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) =>
                      _BookingCard(booking: items[index]),
                ),
        ),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking});

  final BookingItem booking;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final date = booking.scheduledAt;
    final dateText = date == null
        ? 'Schedule unavailable'
        : '${date.day}/${date.month}/${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/booking/${booking.id}/details'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      booking.categoryName ?? 'Home service',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  _StatusChip(status: booking.status),
                ],
              ),
              const SizedBox(height: 10),
              Text('Provider: ${booking.providerName ?? 'Assigned provider'}'),
              Text(dateText),
              if (booking.address?.isNotEmpty == true) Text(booking.address!),
              if (booking.priceEstimate != null)
                Text(
                    'Estimated price: ৳${booking.priceEstimate!.toStringAsFixed(0)}'),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final isActive = status == 'accepted' || status == 'en_route';
    return Chip(
      label: Text(status.replaceAll('_', ' ').toUpperCase()),
      labelStyle: TextStyle(
        fontSize: 11,
        color: isActive ? Colors.green.shade800 : Colors.blueGrey.shade700,
        fontWeight: FontWeight.w700,
      ),
      backgroundColor:
          isActive ? Colors.green.shade50 : Colors.blueGrey.shade50,
      side: BorderSide.none,
    );
  }
}
