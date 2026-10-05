import 'package:flutter/material.dart';

@immutable
class PartnerShop {
  const PartnerShop({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    this.photo,
    this.banner,
    this.logo,
    this.discountPercentage = '15.00',
    this.minDiscountPercentage = '5.00',
    this.minPurchase = '200.00',
    this.maxDiscount = '100.00',
    this.qrCodeAvailable = true,
    this.qrCodeImage,
    this.qrCodeData,
    this.categoryDisplay = '',
    this.address = '',
    this.city = 'Kochi',
    this.state = 'Kerala',
    this.pincode = '',
    this.contactPhone,
    this.contactEmail,
    this.rewardPointsPer100Inr = 5,
    this.isActive = true,
    this.distance = 'Nearby',
    this.rating = 4.8,
    this.totalReviews = 120,
    this.timings = '10:00 AM - 10:00 PM',
  });

  factory PartnerShop.fromJson(Map<String, dynamic> json) {
    final photoUrl = _resolveUrl(
      json['photo'] ?? json['image'] ?? json['shop_photo'],
    );
    final bannerUrl = _resolveUrl(
      json['banner'] ??
          json['banner_image'] ??
          json['banner_img'] ??
          json['cover_image'] ??
          json['cover'] ??
          json['shop_banner'] ??
          json['banner_url'] ??
          json['image'] ??
          json['shop_image'] ??
          json['photo'],
    );
    final logoUrl = _resolveUrl(
      json['logo'] ??
          json['shop_logo'] ??
          json['logo_image'] ??
          json['logo_url'] ??
          photoUrl ??
          bannerUrl,
    );

    return PartnerShop(
      id: json['id']?.toString() ?? '',
      name: (json['name'] ?? json['shop_name'] ?? '').toString(),
      photo: photoUrl,
      banner: bannerUrl,
      logo: logoUrl,
      discountPercentage: (json['discount_percentage'] ?? '15.00').toString(),
      minDiscountPercentage:
          (json['min_discount_percentage'] ?? '5.00').toString(),
      minPurchase:
          (json['min_purchase'] ?? json['min_bill_amount'] ?? '200.00')
              .toString(),
      maxDiscount:
          (json['max_discount'] ?? json['max_discount_amount'] ?? '100.00')
              .toString(),
      qrCodeAvailable: json['qr_code_available'] as bool? ?? true,
      qrCodeImage: json['qr_code_image']?.toString(),
      qrCodeData: json['qr_code_data']?.toString(),
      category: (json['category'] ?? 'cafe').toString(),
      categoryDisplay: (json['category_display'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      city: (json['city'] ?? '').toString(),
      state: (json['state'] ?? '').toString(),
      pincode: (json['pincode'] ?? '').toString(),
      contactPhone: json['contact_phone']?.toString(),
      contactEmail: json['contact_email']?.toString(),
      rewardPointsPer100Inr:
          (json['reward_points_per_100_inr'] as num?)?.toInt() ?? 5,
      isActive: json['is_active'] as bool? ?? true,
      distance: (json['distance'] ?? 'Nearby').toString(),
      rating: (json['rating'] as num?)?.toDouble() ?? 4.8,
      totalReviews: (json['total_reviews'] as num?)?.toInt() ?? 120,
      timings: (json['timings'] ?? '10:00 AM - 10:00 PM').toString(),
    );
  }

  static String? _resolveUrl(dynamic val) {
    if (val == null) return null;
    final str = val.toString().trim();
    if (str.isEmpty || str == 'null' || str == 'None') return null;
    if (str.startsWith('http://') || str.startsWith('https://')) {
      return str;
    }
    final cleanPath = str.startsWith('/') ? str : '/$str';
    return 'https://discipl-backend.onrender.com$cleanPath';
  }

  final String id;
  final String name;
  final String? photo;
  final String? banner;
  final String? logo;
  final String discountPercentage;
  final String minDiscountPercentage;
  final String minPurchase;
  final String maxDiscount;
  final bool qrCodeAvailable;
  final String? qrCodeImage;
  final String? qrCodeData;
  final String category;
  final String categoryDisplay;
  final String description;
  final String address;
  final String city;
  final String state;
  final String pincode;
  final String? contactPhone;
  final String? contactEmail;
  final int rewardPointsPer100Inr;
  final bool isActive;
  final String distance;
  final double rating;
  final int totalReviews;
  final String timings;

  String? get bannerUrl {
    if (banner != null && banner!.trim().isNotEmpty) return banner;
    if (photo != null && photo!.trim().isNotEmpty) return photo;
    return null;
  }

  String? get logoUrl {
    if (logo != null && logo!.trim().isNotEmpty) return logo;
    if (photo != null && photo!.trim().isNotEmpty) return photo;
    if (banner != null && banner!.trim().isNotEmpty) return banner;
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'photo': photo,
      'banner': banner,
      'logo': logo,
      'discount_percentage': discountPercentage,
      'min_discount_percentage': minDiscountPercentage,
      'min_purchase': minPurchase,
      'max_discount': maxDiscount,
      'qr_code_available': qrCodeAvailable,
      'qr_code_image': qrCodeImage,
      'qr_code_data': qrCodeData,
      'category': category,
      'category_display': categoryDisplay,
      'description': description,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'contact_phone': contactPhone,
      'contact_email': contactEmail,
      'reward_points_per_100_inr': rewardPointsPer100Inr,
      'is_active': isActive,
      'distance': distance,
      'rating': rating,
      'total_reviews': totalReviews,
      'timings': timings,
    };
  }

  String get discountTag {
    final pct = double.tryParse(discountPercentage);
    if (pct != null && pct > 0) {
      final formatted =
          pct % 1 == 0 ? pct.toInt().toString() : pct.toStringAsFixed(1);
      return '$formatted% OFF';
    }
    return '$discountPercentage% OFF';
  }

  String get minPurchaseTag {
    final amt = double.tryParse(minPurchase);
    if (amt != null && amt > 0) {
      return 'Min ₹${amt.toInt()}';
    }
    return 'Min ₹$minPurchase';
  }

  String get maxDiscountTag {
    final amt = double.tryParse(maxDiscount);
    if (amt != null && amt > 0) {
      return 'Up to ₹${amt.toInt()}';
    }
    return 'Up to ₹$maxDiscount';
  }

  String get location {
    if (address.isNotEmpty && city.isNotEmpty) {
      return '$address, $city';
    }
    return address.isNotEmpty ? address : city;
  }

  String get fullAddress {
    final parts =
        [address, city, state, pincode].where((s) => s.isNotEmpty).toList();
    return parts.isNotEmpty ? parts.join(', ') : 'Address not specified';
  }

  String get displayCategory {
    if (categoryDisplay.isNotEmpty) return categoryDisplay;
    if (category.isEmpty) return 'General';
    return category[0].toUpperCase() + category.substring(1);
  }

  IconData get iconData {
    switch (category.toLowerCase()) {
      case 'cafe':
      case 'dining & cafes':
        return Icons.local_cafe_rounded;
      case 'restaurant':
        return Icons.restaurant_rounded;
      case 'nutrition':
      case 'supplements':
        return Icons.fitness_center_rounded;
      case 'healthy drinks':
        return Icons.local_drink_rounded;
      case 'sports gear':
      case 'retail':
        return Icons.shopping_bag_rounded;
      case 'spa':
        return Icons.spa_rounded;
      case 'hotel':
        return Icons.hotel_rounded;
      default:
        return Icons.storefront_rounded;
    }
  }

  Color get themeColor {
    switch (category.toLowerCase()) {
      case 'cafe':
      case 'dining & cafes':
        return const Color(0xFF10B981);
      case 'restaurant':
        return const Color(0xFFEF4444);
      case 'nutrition':
      case 'supplements':
        return const Color(0xFF3B82F6);
      case 'healthy drinks':
        return const Color(0xFFF59E0B);
      case 'sports gear':
      case 'retail':
        return const Color(0xFF8B5CF6);
      case 'spa':
        return const Color(0xFFEC4899);
      case 'hotel':
        return const Color(0xFF6366F1);
      default:
        return const Color(0xFF0F172A);
    }
  }

  static const List<PartnerShop> sampleShops = [];
}
