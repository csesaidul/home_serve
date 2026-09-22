import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants.dart';
import '../data/booking_repository.dart';
import '../models/booking_models.dart';

class BookingDetailsData {
  const BookingDetailsData({required this.summary, required this.progress});

  final BookingSummary summary;
  final BookingProgress progress;
}

final bookingDetailsProvider = FutureProvider.autoDispose
    .family<BookingDetailsData, int>((ref, bookingId) async {
  final repository = ref.watch(bookingRepositoryProvider);
  final results = await Future.wait([
    repository.summary(bookingId),
    repository.progress(bookingId),
  ]);
  return BookingDetailsData(
    summary: results[0] as BookingSummary,
    progress: results[1] as BookingProgress,
  );
});

class BookingDetailsScreen extends ConsumerWidget {
  const BookingDetailsScreen({required this.bookingId, super.key});

  final int bookingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final details = ref.watch(bookingDetailsProvider(bookingId));
    return Scaffold(
      appBar: AppBar(title: const Text('Booking Details')),
      body: details.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Unable to load booking details.\n$error',
                textAlign: TextAlign.center),
          ),
        ),
        data: (data) => _BookingDetailsContent(data: data),
      ),
    );
  }
}

class _BookingDetailsContent extends StatelessWidget {
  const _BookingDetailsContent({required this.data});

  final BookingDetailsData data;

  @override
  Widget build(BuildContext context) {
    final summary = data.summary;
    final date = summary.scheduledAt;
    final dateText = '${date.day}/${date.month}/${date.year} at '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      children: [
        _HeaderCard(summary: summary, status: data.progress.currentStatus),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'Schedule & Address',
          children: [
            _InfoRow(
                icon: Icons.calendar_month_outlined,
                label: 'Scheduled time',
                value: dateText),
            _InfoRow(
                icon: Icons.location_on_outlined,
                label: 'Service address',
                value: summary.address),
          ],
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'Payment Summary',
          children: [
            _PriceRow(label: 'Base service charge', value: summary.baseCharge),
            _PriceRow(
                label: 'Safety & platform fee', value: summary.platformFee),
            const Divider(height: 24),
            _PriceRow(
                label: 'Estimated total',
                value: summary.total,
                emphasized: true),
            const SizedBox(height: 4),
            const Text('Payment mode: Post-pay',
                style: TextStyle(color: Colors.blueGrey)),
          ],
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'Booking Progress',
          children: data.progress.steps
              .map((step) => _ProgressRow(step: step))
              .toList(),
        ),
      ],
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.summary, required this.status});

  final BookingSummary summary;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: summary.providerId == null
            ? null
            : () => context.push('/provider/${summary.providerId}'),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              _ProviderAvatar(summary: summary),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(summary.categoryName,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text('Provider: ${summary.providerName}'),
                    if (summary.providerId != null)
                      const Text('View provider profile',
                          style: TextStyle(color: Colors.teal, fontSize: 12)),
                  ],
                ),
              ),
              _StatusChip(status: status),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProviderAvatar extends StatelessWidget {
  const _ProviderAvatar({required this.summary});

  final BookingSummary summary;

  @override
  Widget build(BuildContext context) {
    final photo = summary.providerPhoto;
    return CircleAvatar(
      radius: 27,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      backgroundImage: photo == null || photo.isEmpty
          ? null
          : NetworkImage('${AppConstants.apiBaseUrl}$photo'),
      child: photo == null || photo.isEmpty
          ? Icon(Icons.person_outline,
              color: Theme.of(context).colorScheme.primary)
          : null,
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 21, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(label, style: const TextStyle(color: Colors.blueGrey)),
                const SizedBox(height: 3),
                Text(value)
              ])),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow(
      {required this.label, required this.value, this.emphasized = false});

  final String label;
  final double value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label,
            style: TextStyle(
                fontWeight: emphasized ? FontWeight.w700 : FontWeight.normal)),
        Text('৳${value.toStringAsFixed(0)}',
            style: TextStyle(
                fontWeight: FontWeight.w700, fontSize: emphasized ? 18 : null)),
      ]),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({required this.step});

  final BookingProgressStep step;

  @override
  Widget build(BuildContext context) {
    final active = step.state == 'done' || step.state == 'in_progress';
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(active ? Icons.check_circle : Icons.radio_button_unchecked,
          color: active ? Colors.green : Colors.blueGrey),
      title: Text(step.label),
      trailing: Text(step.state.replaceAll('_', ' '),
          style: const TextStyle(color: Colors.blueGrey)),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final active = status == 'accepted' || status == 'en_route';
    return Chip(
      label: Text(status.replaceAll('_', ' ').toUpperCase()),
      labelStyle: TextStyle(
          fontSize: 10,
          color: active ? Colors.green.shade800 : Colors.blueGrey.shade700,
          fontWeight: FontWeight.w700),
      backgroundColor: active ? Colors.green.shade50 : Colors.blueGrey.shade50,
      side: BorderSide.none,
    );
  }
}
