import 'package:flutter/material.dart';

class CategoryItem {
  const CategoryItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.basePrice,
  });

  final int id;
  final String name;
  final String icon;
  final double basePrice;

  factory CategoryItem.fromJson(Map<String, dynamic> json) => CategoryItem(
        id: json['id'] as int? ?? 0,
        name: json['name'] as String? ?? '',
        icon: json['icon'] as String? ?? '',
        basePrice: (json['base_price'] as num?)?.toDouble() ?? 0,
      );
}

class ProviderSummaryItem {
  const ProviderSummaryItem({
    required this.userId,
    required this.name,
    required this.profilePhoto,
    required this.categories,
    required this.skills,
    required this.location,
    required this.ratingAvg,
    required this.startingPrice,
    required this.responseTime,
    required this.jobSuccessPct,
    required this.available,
    required this.distanceText,
    required this.verified,
  });

  final int userId;
  final String name;
  final String profilePhoto;
  final String categories;
  final String skills;
  final String location;
  final double ratingAvg;
  final double startingPrice;
  final String responseTime;
  final int jobSuccessPct;
  final bool available;
  final String distanceText;
  final bool verified;

  factory ProviderSummaryItem.fromJson(Map<String, dynamic> json) => ProviderSummaryItem(
        userId: json['user_id'] as int? ?? 0,
        name: json['name'] as String? ?? '',
        profilePhoto: json['profile_photo'] as String? ?? '',
        categories: json['categories'] as String? ?? '',
        skills: json['skills'] as String? ?? '',
        location: json['location'] as String? ?? '',
        ratingAvg: (json['rating_avg'] as num?)?.toDouble() ?? 0,
        startingPrice: (json['starting_price'] as num?)?.toDouble() ?? 0,
        responseTime: json['response_time'] as String? ?? '',
        jobSuccessPct: json['job_success_pct'] as int? ?? 0,
        available: json['available'] == true || json['available'] == 1,
        distanceText: json['distance_text'] as String? ?? '',
        verified: json['verified'] == true || json['verified'] == 1,
      );
}

class ProviderProfileItem {
  const ProviderProfileItem({
    required this.userId,
    required this.name,
    required this.profilePhoto,
    required this.bio,
    required this.skills,
    required this.categories,
    required this.location,
    required this.yearsExperience,
    required this.jobSuccessPct,
    required this.responseTime,
    required this.startingPrice,
    required this.ratingAvg,
    required this.verified,
    required this.status,
    required this.portfolio,
    required this.reviews,
  });

  final int userId;
  final String name;
  final String profilePhoto;
  final String bio;
  final String skills;
  final String categories;
  final String location;
  final int yearsExperience;
  final int jobSuccessPct;
  final String responseTime;
  final double startingPrice;
  final double ratingAvg;
  final bool verified;
  final String status;
  final List<PortfolioItem> portfolio;
  final List<ReviewItem> reviews;

  factory ProviderProfileItem.fromJson(Map<String, dynamic> json) => ProviderProfileItem(
        userId: json['user_id'] as int? ?? 0,
        name: json['name'] as String? ?? '',
        profilePhoto: json['profile_photo'] as String? ?? '',
        bio: json['bio'] as String? ?? '',
        skills: json['skills'] as String? ?? '',
        categories: json['categories'] as String? ?? '',
        location: json['location'] as String? ?? '',
        yearsExperience: json['years_experience'] as int? ?? 0,
        jobSuccessPct: json['job_success_pct'] as int? ?? 0,
        responseTime: json['response_time'] as String? ?? '',
        startingPrice: (json['starting_price'] as num?)?.toDouble() ?? 0,
        ratingAvg: (json['rating_avg'] as num?)?.toDouble() ?? 0,
        verified: json['verified'] == true || json['verified'] == 1,
        status: json['status'] as String? ?? 'pending',
        portfolio: (json['portfolio'] as List<dynamic>? ?? const [])
            .map((e) => PortfolioItem.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        reviews: (json['reviews'] as List<dynamic>? ?? const [])
            .map((e) => ReviewItem.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );
}

class PortfolioItem {
  const PortfolioItem({
    required this.title,
    required this.description,
    required this.imageUrl,
  });

  final String title;
  final String description;
  final String imageUrl;

  factory PortfolioItem.fromJson(Map<String, dynamic> json) => PortfolioItem(
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        imageUrl: json['image_url'] as String? ?? '',
      );
}

class ReviewItem {
  const ReviewItem({
    required this.id,
    required this.rating,
    required this.comment,
    required this.clientName,
    required this.profilePhoto,
    required this.createdAt,
  });

  final int id;
  final int rating;
  final String comment;
  final String clientName;
  final String profilePhoto;
  final String createdAt;

  factory ReviewItem.fromJson(Map<String, dynamic> json) => ReviewItem(
        id: json['id'] as int? ?? 0,
        rating: json['rating'] as int? ?? 0,
        comment: json['comment'] as String? ?? '',
        clientName: json['client_name'] as String? ?? 'Anonymous',
        profilePhoto: json['client_profile_photo'] as String? ?? '',
        createdAt: json['created_at'] as String? ?? '',
      );
}

class CategoryBadgeColor {
  static const List<Color> palette = [
    Color(0xff1d7755),
    Color(0xff1b6b8f),
    Color(0xffa65a00),
    Color(0xff7a4f9d),
    Color(0xff0d7a9d),
  ];
}
