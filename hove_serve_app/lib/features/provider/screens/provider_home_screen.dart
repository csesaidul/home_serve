import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants.dart';
import '../data/provider_repository.dart';
import '../models/provider_models.dart';

class ProviderBrowseQuery {
  const ProviderBrowseQuery({this.search = '', this.sort = 'nearest', this.availableOnly = false});

  final String search;
  final String sort;
  final bool availableOnly;

  @override
  bool operator ==(Object other) =>
      other is ProviderBrowseQuery &&
      other.search == search &&
      other.sort == sort &&
      other.availableOnly == availableOnly;

  @override
  int get hashCode => Object.hash(search, sort, availableOnly);
}

final providerHomeControllerProvider =
    FutureProvider.autoDispose.family<List<ProviderSummaryItem>, ProviderBrowseQuery>((ref, query) {
  return ref.watch(providerRepositoryProvider).fetchProviders(
        search: query.search,
        sort: query.sort,
        availableOnly: query.availableOnly,
      );
});

class ProviderHomeScreen extends ConsumerStatefulWidget {
  const ProviderHomeScreen({super.key});

  @override
  ConsumerState<ProviderHomeScreen> createState() => _ProviderHomeScreenState();
}

class _ProviderHomeScreenState extends ConsumerState<ProviderHomeScreen> {
  ProviderBrowseQuery _query = const ProviderBrowseQuery();

  void _selectTab(String sort, {bool availableOnly = false}) {
    setState(() {
      _query = ProviderBrowseQuery(
        search: _query.search,
        sort: sort,
        availableOnly: availableOnly,
      );
    });
  }

  Future<void> _searchProviders() async {
    final search = await showDialog<String>(
      context: context,
      builder: (context) => _SearchProviderDialog(initialSearch: _query.search),
    );
    if (search != null && mounted) {
      setState(() => _query = ProviderBrowseQuery(
            search: search,
            sort: _query.sort,
            availableOnly: _query.availableOnly,
          ));
    }
  }
  Future<void> _openFilters() async {
    final selection = await showModalBottomSheet<_ProviderFilterSelection>(
      context: context,
      showDragHandle: true,
      builder: (context) => _ProviderFilterSheet(query: _query),
    );
    if (selection != null && mounted) {
      setState(() => _query = ProviderBrowseQuery(
            search: _query.search,
            sort: selection.sort,
            availableOnly: selection.availableOnly,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final providersAsync = ref.watch(providerHomeControllerProvider(_query));

    return Scaffold(
      backgroundColor: const Color(0xffedf2f4),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xfff4f6f7),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                    const SizedBox(width: 8),
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: const Color(0xff0d6f7d),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.home_repair_service_rounded, size: 16, color: Colors.white),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Home services', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                          Text('Live providers', style: TextStyle(fontSize: 12, color: Color(0xff4c5f6b))),
                        ],
                      ),
                    ),
                    IconButton(onPressed: _searchProviders, icon: const Icon(Icons.search_rounded, size: 22)),
                    const SizedBox(width: 8),
                    IconButton(onPressed: _openFilters, icon: const Icon(Icons.tune_rounded, size: 22)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(child: _FilterTab(label: 'Nearest (< 2 km)', active: _query.sort == 'nearest' && !_query.availableOnly, onTap: _selectTab)),
                    Expanded(child: _FilterTab(label: 'Top Rated (4.8+)', active: _query.sort == 'rating' && !_query.availableOnly, onTap: _selectTab)),
                    Expanded(child: _FilterTab(label: 'Available now', active: _query.availableOnly, onTap: (sort) => _selectTab(sort, availableOnly: true))),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  providersAsync.when(
                    data: (providers) => 'Showing ${providers.length} providers',
                    loading: () => 'Loading providers...',
                    error: (_, __) => 'Providers unavailable',
                  ),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: const Color(0xff4c5f6b)),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: providersAsync.when(
                  data: (providers) {
                    if (providers.isEmpty) {
                      return const Center(child: Text('No providers found'));
                    }

                    return ListView.separated(
                      itemCount: providers.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = providers[index];
                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _ProviderAvatar(item: item),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item.name,
                                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
                                          ),
                                        ),
                                        if (item.verified)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: const Color(0xffdef5eb),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: const Text(
                                              'Verified',
                                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xff0d7a5d)),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(Icons.star_rounded, size: 18, color: Color(0xfff4b63d)),
                                        const SizedBox(width: 4),
                                        Text(item.ratingAvg.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.w700)),
                                        const SizedBox(width: 8),
                                        Text('(${item.jobSuccessPct}% success)', style: const TextStyle(color: Color(0xff5a6873))),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      item.skills.split(',').take(3).join(' • '),
                                      style: const TextStyle(color: Color(0xff4c5f6b), fontSize: 13),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        const Icon(Icons.schedule_rounded, size: 16, color: Color(0xff0d7a9d)),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            item.available ? 'Available now' : item.responseTime,
                                            style: const TextStyle(color: Color(0xff4c5f6b)),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () => context.push('/provider/${item.userId}'),
                                          child: const Text('View Profile', style: TextStyle(color: Color(0xff0c7ea0), fontWeight: FontWeight.w700)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const Center(child: Text('Unable to load providers')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

class _SearchProviderDialog extends StatefulWidget {
  const _SearchProviderDialog({required this.initialSearch});

  final String initialSearch;

  @override
  State<_SearchProviderDialog> createState() => _SearchProviderDialogState();
}

class _SearchProviderDialogState extends State<_SearchProviderDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialSearch);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    Navigator.of(context).pop(_controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Search providers'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textInputAction: TextInputAction.search,
        decoration: const InputDecoration(hintText: 'Name, service, or location'),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(''), child: const Text('Clear')),
        FilledButton(onPressed: _submit, child: const Text('Search')),
      ],
    );
  }
}

class _FilterTab extends StatelessWidget {
  const _FilterTab({required this.label, required this.active, required this.onTap});

  final String label;
  final bool active;
  final ValueChanged<String> onTap;

  String get _sort => label.startsWith('Top') ? 'rating' : 'nearest';

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(_sort),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: active ? const Color(0xffdff6fb) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color: active ? const Color(0xff0f6d87) : const Color(0xff55606b),
          ),
        ),
      ),
    );
  }
}

class _ProviderFilterSelection {
  const _ProviderFilterSelection({required this.sort, required this.availableOnly});

  final String sort;
  final bool availableOnly;
}

class _ProviderFilterSheet extends StatefulWidget {
  const _ProviderFilterSheet({required this.query});

  final ProviderBrowseQuery query;

  @override
  State<_ProviderFilterSheet> createState() => _ProviderFilterSheetState();
}

class _ProviderFilterSheetState extends State<_ProviderFilterSheet> {
  late String _sort = widget.query.sort;
  late bool _availableOnly = widget.query.availableOnly;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Filter & Sort', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            const Text('Sort by', style: TextStyle(fontWeight: FontWeight.w700)),
            _SortOption(
              label: 'Nearest first',
              selected: _sort == 'nearest',
              onTap: () => setState(() => _sort = 'nearest'),
            ),
            _SortOption(
              label: 'Top rated',
              selected: _sort == 'rating',
              onTap: () => setState(() => _sort = 'rating'),
            ),
            CheckboxListTile(title: const Text('Available now'), value: _availableOnly, onChanged: (value) => setState(() => _availableOnly = value ?? false)),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(_ProviderFilterSelection(sort: _sort, availableOnly: _availableOnly)),
                child: const Text('Apply filters'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SortOption extends StatelessWidget {
  const _SortOption({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      leading: Icon(
        selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        color: selected ? const Color(0xff0d8caf) : const Color(0xffc5cdd5),
      ),
      onTap: onTap,
    );
  }
}

class _ProviderAvatar extends StatelessWidget {
  const _ProviderAvatar({required this.item});

  final ProviderSummaryItem item;

  @override
  Widget build(BuildContext context) {
    final imageUrl = item.profilePhoto;
    return Container(
      width: 56,
      height: 56,
      decoration: const BoxDecoration(color: Color(0xffdfe7e8), shape: BoxShape.circle),
      clipBehavior: Clip.antiAlias,
      child: imageUrl.isEmpty
          ? Center(child: Text(_initials(item.name)))
          : Image.network(
              '${AppConstants.apiBaseUrl}$imageUrl',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Center(child: Text(_initials(item.name))),
            ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.substring(0, 2).toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
