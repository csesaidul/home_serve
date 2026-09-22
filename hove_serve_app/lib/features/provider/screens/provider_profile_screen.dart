import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants.dart';
import '../data/provider_repository.dart';
import '../models/provider_models.dart';

final providerProfileControllerProvider =
    FutureProvider.family.autoDispose<ProviderProfileItem, int>((ref, userId) {
  return ref.watch(providerRepositoryProvider).fetchProviderProfile(userId);
});

class ProviderProfileScreen extends ConsumerWidget {
  const ProviderProfileScreen({this.userId = 3, super.key});

  final int userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(providerProfileControllerProvider(userId));
    return Scaffold(
      body: SafeArea(
        child: profileAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Center(child: Text('Unable to load provider profile')),
          data: (profile) => _ProviderProfileContent(profile: profile),
        ),
      ),
    );
  }
}

class _ProviderProfileContent extends StatelessWidget {
  const _ProviderProfileContent({required this.profile});

  final ProviderProfileItem profile;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final skills = profile.skills.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 60,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    ),
                    const Spacer(),
                    IconButton(onPressed: () {}, icon: const Icon(Icons.favorite_border_rounded)),
                    IconButton(onPressed: () {}, icon: const Icon(Icons.share_rounded)),
                    IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert_rounded)),
                  ],
                ),
              ),
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 104,
                      height: 104,
                      decoration: BoxDecoration(
                        color: const Color(0xffd9e8ec),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: profile.profilePhoto.isEmpty
                          ? Center(
                              child: Text(
                                _initials(profile.name),
                                style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w700),
                              ),
                            )
                          : Image.network(
                              '${AppConstants.apiBaseUrl}${profile.profilePhoto}',
                              width: 104,
                              height: 104,
                              fit: BoxFit.cover,
                              alignment: Alignment.center,
                              filterQuality: FilterQuality.high,
                              errorBuilder: (_, __, ___) => Center(
                                child: Text(
                                  _initials(profile.name),
                                  style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w700),
                                ),
                            ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      profile.name,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xffeaf8f1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Verified Specialist',
                        style: TextStyle(color: Color(0xff0d7a5d), fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.star_rounded, color: Color(0xfff2b443), size: 20),
                        Text(
                          ' ${profile.ratingAvg.toStringAsFixed(1)} (${profile.reviews.length} reviews)',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '• ${profile.location}',
                          style: TextStyle(color: colors.onSurfaceVariant),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: skills
                          .map(
                            (skill) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                              decoration: BoxDecoration(
                                color: const Color(0xffedf4f5),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                skill,
                                style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xff3a4d5d)),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 22),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _StatColumn(label: 'Completed', value: '${profile.jobSuccessPct} Jobs'),
                          _StatColumn(label: 'Rating', value: '${profile.ratingAvg.toStringAsFixed(1)} ★'),
                          _StatColumn(label: 'Response', value: profile.responseTime),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              DefaultTabController(
                length: 4,
                child: Column(
                  children: [
                    TabBar(
                      isScrollable: true,
                      labelColor: const Color(0xff0d7a9d),
                      unselectedLabelColor: colors.onSurfaceVariant,
                      indicatorColor: const Color(0xff0d7a9d),
                      indicatorWeight: 3,
                      tabs: const [
                        Tab(text: 'About'),
                        Tab(text: 'Services & Rates'),
                        Tab(text: 'Portfolio'),
                        Tab(text: 'Reviews'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 520,
                      child: TabBarView(
                        children: [
                          SingleChildScrollView(child: _AboutTab(content: profile.bio)),
                          SingleChildScrollView(child: _ServicesTab()),
                          SingleChildScrollView(child: _PortfolioTab(items: profile.portfolio)),
                          SingleChildScrollView(child: _ReviewsTab(items: profile.reviews)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff0f7b99),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_month_rounded),
                      SizedBox(width: 8),
                      Text('Book Now', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    ],
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
    if (parts.length == 1) return parts.first.substring(0, 2).toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(fontSize: 12, color: Color(0xff587186), letterSpacing: 0.5),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
      ],
    );
  }
}

class _AboutTab extends StatelessWidget {
  const _AboutTab({required this.content});

  final String content;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('About Technician', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        Text(content, style: const TextStyle(fontSize: 16, height: 1.6, color: Color(0xff465a69))),
        const SizedBox(height: 18),
        const Text('CORE SKILLS & EQUIPMENT', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 0.8)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: const [
            'Circuit Breaker Installation',
            'IPS Setup',
            'Ceiling Fan & Chandelier',
            'Smart Home Automation',
            'Short Circuit Repair',
            'Earth Leakage Testing',
          ].map((item) => Chip(label: Text(item))).toList(),
        ),
        const SizedBox(height: 20),
        const Row(
          children: [
            Icon(Icons.check_circle, color: Color(0xff1d8259)),
            SizedBox(width: 8),
            Text('NID Verified'),
            SizedBox(width: 18),
            Icon(Icons.check_circle, color: Color(0xff1d8259)),
            SizedBox(width: 8),
            Text('Police Cleared'),
          ],
        ),
      ],
    );
  }
}

class _ServicesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Services & Rates', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        SizedBox(height: 20),
        _PricingRow(label: 'Circuit Breaker', value: '৳ 1,200'),
        _PricingRow(label: 'Ceiling Fan Fitting', value: '৳ 800'),
        _PricingRow(label: 'Inverter AC Service', value: '৳ 1,500'),
        _PricingRow(label: 'DB Box Repair', value: '৳ 2,200'),
      ],
    );
  }
}

class _PortfolioTab extends StatelessWidget {
  const _PortfolioTab({required this.items});

  final List<PortfolioItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recent Work & Portfolio', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 16),
        Row(
          children: items
              .map(
                (item) => Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xff1f3c5a),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.flash_on_rounded, color: Colors.white, size: 30),
                        const SizedBox(height: 8),
                        Text(item.title, style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _ReviewsTab extends StatelessWidget {
  const _ReviewsTab({required this.items});

  final List<ReviewItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < items.length; index++) ...[
          if (index > 0) const SizedBox(height: 16),
          _ReviewItem(review: items[index]),
        ],
      ],
    );
  }
}

class _ReviewItem extends StatelessWidget {
  const _ReviewItem({required this.review});

  final ReviewItem review;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _ReviewerAvatar(review: review),
            const SizedBox(width: 10),
            Expanded(
              child: Text(review.clientName, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            ),
            const Spacer(),
            const Text('Verified', style: TextStyle(fontSize: 12, color: Color(0xff587186))),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: List.generate(
            5,
            (i) => Icon(
              Icons.star_rounded,
              color: i < review.rating ? const Color(0xfff4b63d) : const Color(0xffd7dfe8),
              size: 16,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(review.comment, style: const TextStyle(height: 1.5, color: Color(0xff495b68))),
      ],
    );
  }
}

class _ReviewerAvatar extends StatelessWidget {
  const _ReviewerAvatar({required this.review});

  final ReviewItem review;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        color: Color(0xffdfe7e8),
        shape: BoxShape.circle,
      ),
      child: review.profilePhoto.isEmpty
          ? Center(child: Text(_initials(review.clientName)))
          : Image.network(
              '${AppConstants.apiBaseUrl}${review.profilePhoto}',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Center(child: Text(_initials(review.clientName))),
            ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.substring(0, 2).toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

class _PricingRow extends StatelessWidget {
  const _PricingRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 16))),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xff0d7a9d))),
        ],
      ),
    );
  }
}
