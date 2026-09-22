import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../../provider/data/provider_repository.dart';
import '../../provider/models/provider_models.dart';
import '../data/booking_repository.dart';
import '../models/booking_models.dart';

class BookingScreen extends ConsumerStatefulWidget {
  const BookingScreen({required this.provider, super.key});

  final ProviderProfileItem provider;

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _date;
  TimeOfDay? _time;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      initialDate: _date ?? DateTime.now().add(const Duration(days: 1)),
    );
    if (selected != null) setState(() => _date = selected);
  }

  Future<void> _pickTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: _time ?? const TimeOfDay(hour: 10, minute: 0),
    );
    if (selected != null) setState(() => _time = selected);
  }

  Future<void> _submit() async {
    final claims = ref.read(authProvider).claims;
    final clientId = (claims?['user_id'] as num?)?.toInt();
    if (clientId == null ||
        _date == null ||
        _time == null ||
        _addressController.text.trim().isEmpty) {
      setState(() =>
          _error = 'Select a date, time, and enter your service address.');
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final categories =
          await ref.read(providerRepositoryProvider).fetchCategories();
      final category = _findCategory(categories);
      if (category == null) {
        throw Exception('No service category is available for this provider.');
      }
      final scheduledAt = DateTime(
        _date!.year,
        _date!.month,
        _date!.day,
        _time!.hour,
        _time!.minute,
      );
      final repository = ref.read(bookingRepositoryProvider);
      final booking = await repository.create(
        clientId: clientId,
        providerId: widget.provider.userId,
        categoryId: category.id,
        scheduledAt: scheduledAt,
        address: _addressController.text,
        customerNotes: _notesController.text,
      );
      await repository.confirm(booking.id);
      final summary = await repository.summary(booking.id);
      final progress = await repository.progress(booking.id);
      if (!mounted) {
        return;
      }
      await _showConfirmation(summary, progress);
    } catch (error) {
      if (mounted) {
        setState(
            () => _error = error.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  CategoryItem? _findCategory(List<CategoryItem> categories) {
    final providerCategories = widget.provider.categories.toLowerCase();
    for (final category in categories) {
      if (providerCategories.contains(category.name.toLowerCase())) {
        return category;
      }
    }
    return categories.isEmpty ? null : categories.first;
  }

  Future<void> _showConfirmation(
      BookingSummary summary, BookingProgress progress) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Booking secured'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${summary.categoryName} with ${summary.providerName}'),
            const SizedBox(height: 8),
            Text('Estimated total: ৳${summary.total.toStringAsFixed(0)}'),
            const SizedBox(height: 16),
            ...progress.steps.map(
              (step) => ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  step.state == 'done' || step.state == 'in_progress'
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                ),
                title: Text(step.label),
                trailing: Text(step.state),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confirm Booking')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(widget.provider.name,
              style: Theme.of(context).textTheme.headlineSmall),
          Text(widget.provider.categories),
          const SizedBox(height: 24),
          ListTile(
            title: const Text('Service date'),
            subtitle: Text(_date == null
                ? 'Choose a date'
                : '${_date!.day}/${_date!.month}/${_date!.year}'),
            trailing: const Icon(Icons.calendar_month),
            onTap: _pickDate,
          ),
          ListTile(
            title: const Text('Time window'),
            subtitle: Text(_time?.format(context) ?? 'Choose a time'),
            trailing: const Icon(Icons.schedule),
            onTap: _pickTime,
          ),
          TextField(
            controller: _addressController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Service address',
              hintText: 'House, road, area',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: const InputDecoration(
                labelText: 'Special instructions (optional)'),
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(_error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _submitting ? null : _submit,
            icon: _submitting
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.lock_outline),
            label:
                Text(_submitting ? 'Securing booking...' : 'Confirm Booking'),
          ),
        ],
      ),
    );
  }
}
