import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/provider_repository.dart';
import '../models/provider_models.dart';

final categoryBrowseProvidersProvider = FutureProvider.autoDispose<List<ProviderSummaryItem>>((ref) {
  return ref.watch(providerRepositoryProvider).fetchProviders(sort: 'nearest');
});

class CategoryBrowseScreen extends ConsumerWidget {
  const CategoryBrowseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final providersAsync = ref.watch(categoryBrowseProvidersProvider);

    return Scaffold(
      backgroundColor: const Color(0xffedf2f4),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xfff5f7f8),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                    const SizedBox(width: 12),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xff0d6f7d),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Icon(Icons.electrical_services_rounded, color: Colors.white, size: 18),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          providersAsync.when(
                            data: (providers) => Text(
                              providers.isEmpty ? 'Home services' : providers.first.categories,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                            ),
                            loading: () => const Text('Loading services'),
                            error: (_, __) => const Text('Home services'),
                          ),
                          providersAsync.when(
                            data: (providers) => Text(
                              '${providers.length} nearby',
                              style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
                            ),
                            loading: () => Text('Loading providers', style: TextStyle(color: colors.onSurfaceVariant)),
                            error: (_, __) => Text('Providers unavailable', style: TextStyle(color: colors.onSurfaceVariant)),
                          ),
                        ],
                      ),
                    ),
                    IconButton(onPressed: () {}, icon: const Icon(Icons.search_rounded)),
                    IconButton(onPressed: () {}, icon: const Icon(Icons.tune_rounded)),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    Expanded(child: _FilterChip(text: 'Nearest (< 2 km)', isSelected: true)),
                    Expanded(child: _FilterChip(text: 'Top Rated (4.8+)', isSelected: false)),
                    Expanded(child: _FilterChip(text: 'Available now', isSelected: false)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  providersAsync.when(
                    data: (providers) => 'Showing ${providers.length} providers',
                    loading: () => 'Loading providers...',
                    error: (_, __) => 'Providers unavailable',
                  ),
                  style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: providersAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const Center(child: Text('Unable to load providers')),
                  data: (providers) => ListView.separated(
                  itemCount: providers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final provider = providers[index];
                    final tagList = provider.skills.split(',').take(3).toList();

                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          )
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _AvatarCircle(
                            initials: _initials(provider.name),
                            color: const Color(0xffdfe7e8),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        provider.name,
                                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                    if (provider.verified)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: const Color(0xffdff6eb),
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
                                    const Icon(Icons.star_rounded, color: Color(0xfff6b51e), size: 18),
                                    const SizedBox(width: 4),
                                    Text(
                                      provider.ratingAvg.toStringAsFixed(1),
                                      style: const TextStyle(fontWeight: FontWeight.w700),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '(${provider.jobSuccessPct}% success)',
                                      style: TextStyle(color: colors.onSurfaceVariant),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      provider.distanceText,
                                      style: TextStyle(color: colors.onSurfaceVariant),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: tagList
                                      .map((skill) => Text(skill, style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13)))
                                      .toList(),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    const Icon(Icons.access_time_rounded, size: 16, color: Color(0xff1a8f8d)),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        provider.available ? 'Available now' : provider.responseTime,
                                        style: TextStyle(color: colors.onSurfaceVariant),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {},
                                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                                      child: const Text(
                                        'View Profile',
                                        style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xff0d7a9d)),
                                      ),
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
                ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first.substring(0, 2).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.text, required this.isSelected});

  final String text;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xffdff7ff) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? const Color(0xff0f6d87) : const Color(0xff49535a),
          ),
        ),
      ),
    );
  }
}

class _AvatarCircle extends StatelessWidget {
  const _AvatarCircle({required this.initials, required this.color});

  final String initials;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xff1d2e39)),
        ),
      ),
    );
  }
}
