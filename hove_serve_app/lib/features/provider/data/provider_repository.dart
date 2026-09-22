import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../models/provider_models.dart';

final providerRepositoryProvider = Provider<ProviderRepository>((ref) {
  return ProviderRepository(ApiClient());
});

class ProviderRepository {
  ProviderRepository(this._client);

  final ApiClient _client;

  Future<List<CategoryItem>> fetchCategories() async {
    final json = await _client.get('/categories');
    final items = json['items'] as List<dynamic>? ?? const [];
    return items
        .map((e) => CategoryItem.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<List<ProviderSummaryItem>> fetchProviders({
    String? category,
    String? search,
    String sort = 'nearest',
    bool availableOnly = false,
  }) async {
    final query = <String, String>{
      'sort': sort,
      if (category != null && category.isNotEmpty) 'category': category,
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      if (availableOnly) 'available_only': 'true',
    };
    final params = Uri(queryParameters: query).query;
    final json = await _client.get('/providers${params.isEmpty ? '' : '?$params'}');
    final items = json['items'] as List<dynamic>? ?? const [];
    return items
        .map((e) => ProviderSummaryItem.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<ProviderProfileItem> fetchProviderProfile(int userId) async {
    final json = await _client.get('/providers/$userId');
    return ProviderProfileItem.fromJson(json);
  }
}
