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
    final photoUrl = json['photo']?.toString();
    final bannerUrl = json['banner']?.toString() ??
        json['banner_image']?.toString() ??
        json['cover_image']?.toString() ??
        json['cover']?.toString() ??
        json['shop_banner']?.toString();
    final logoUrl = json['logo']?.toString() ??
        json['shop_logo']?.toString() ??
        photoUrl;

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
    return null;
  }

  String? get logoUrl {
    if (logo != null && logo!.isNotEmpty) return logo;
    if (photo != null && photo!.isNotEmpty) return photo;
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

  static const List<PartnerShop> sampleShops = [
    PartnerShop(
      id: 'fahhh_1',
      name: 'Fahhh',
      category: 'hotel',
      categoryDisplay: 'Hotel & Resort',
      discountPercentage: '10.00',
      minPurchase: '100.00',
      maxDiscount: '500.00',
      address: 'Kerala, Kozhikode',
      city: 'Kozhikode',
      contactPhone: '+91 9876543210',
      qrCodeData: 'DISC-FAHHH-01',
      photo:
          'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=800&auto=format&fit=crop&q=80',
      banner:
          'https://images.unsplash.com/photo-1540555700478-4be289fbecef?w=1200&auto=format&fit=crop&q=80',
      logo:
          'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=200&auto=format&fit=crop&q=80',
      description: 'Experience comfort, luxury, and unforgettable moments.',
      distance: '0.8 km away',
      rating: 4.9,
      totalReviews: 540,
    ),
    PartnerShop(
      id: '1',
      name: 'Healthy Protein Bar',
      category: 'cafe',
      categoryDisplay: 'Health Cafe & Salad Bar',
      address: 'Beach Road',
      city: 'Kozhikode',
      pincode: '673001',
      contactPhone: '+91 9876543210',
      contactEmail: 'cafe@health.com',
      qrCodeData: 'DISC-SHOP-1',
      distance: '1.2 km away',
      totalReviews: 420,
      timings: '10:00 AM - 10:30 PM',
      banner:
          'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=1200&auto=format&fit=crop&q=80',
      logo:
          'https://images.unsplash.com/photo-1550547660-d9450f859349?w=200&auto=format&fit=crop&q=80',
      description:
          'Healthy meal partner offering fresh nutrient-rich bowls, shakes and toasts.',
    ),
    PartnerShop(
      id: '2',
      name: 'Protein Hub Nutrition',
      category: 'nutrition',
      categoryDisplay: 'Sports Nutrition & Vitamins',
      discountPercentage: '20.00',
      minDiscountPercentage: '10.00',
      minPurchase: '1000.00',
      maxDiscount: '200.00',
      address: 'Palarivattom Junction',
      pincode: '682025',
      contactPhone: '+91 9845012345',
      contactEmail: 'info@proteinhub.com',
      rewardPointsPer100Inr: 10,
      qrCodeData: 'DISC-SHOP-2',
      distance: '2.5 km away',
      rating: 4.9,
      totalReviews: 280,
      timings: '9:30 AM - 9:30 PM',
      banner:
          'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=1200&auto=format&fit=crop&q=80',
      logo:
          'https://images.unsplash.com/photo-1584735935682-2f2b69dff9d2?w=200&auto=format&fit=crop&q=80',
      description:
          '100% genuine whey proteins, creatine, BCAAs, multivitamins & athlete nutrition.',
    ),
    PartnerShop(
      id: '3',
      name: 'FitBites Kitchen & Grill',
      category: 'restaurant',
      categoryDisplay: 'Health Grill & Whole Foods',
      minPurchase: '300.00',
      maxDiscount: '150.00',
      address: 'Stadium Link Rd, Kaloor',
      pincode: '682017',
      contactPhone: '+91 9812345678',
      contactEmail: 'orders@fitbites.in',
      qrCodeData: 'DISC-SHOP-3',
      distance: '3.1 km away',
      rating: 4.7,
      totalReviews: 315,
      timings: '11:00 AM - 11:00 PM',
      banner:
          'https://images.unsplash.com/photo-1544025162-d76694265947?w=1200&auto=format&fit=crop&q=80',
      logo:
          'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=200&auto=format&fit=crop&q=80',
      description:
          'Authentic coal-grilled healthy chicken, high-protein quinoa bowls and salads.',
    ),
    PartnerShop(
      id: '4',
      name: 'Raw Pressed Detox Bar',
      category: 'cafe',
      categoryDisplay: 'Cold Pressed Juices & Smoothies',
      address: 'Panampilly Nagar Main Ave',
      pincode: '682036',
      contactPhone: '+91 9745678901',
      contactEmail: 'hello@rawpressed.in',
      rewardPointsPer100Inr: 4,
      qrCodeData: 'DISC-SHOP-4',
      distance: '4.2 km away',
      totalReviews: 190,
      timings: '7:30 AM - 10:30 PM',
      banner:
          'https://images.unsplash.com/photo-1610970881699-44a5587cabec?w=1200&auto=format&fit=crop&q=80',
      logo:
          'https://images.unsplash.com/photo-1534353473418-4cfa6c56fd38?w=200&auto=format&fit=crop&q=80',
      description:
          'Cold-pressed raw detox juices, protein smoothies and wholesome hydrating bowls.',
    ),
    PartnerShop(
      id: '5',
      name: 'IronGear Athletics',
      category: 'retail',
      categoryDisplay: 'Sportswear & Training Gear',
      discountPercentage: '10.00',
      minPurchase: '500.00',
      maxDiscount: '300.00',
      address: 'MG Road',
      city: 'Ernakulam',
      pincode: '682011',
      contactPhone: '+91 9998887776',
      contactEmail: 'care@irongear.com',
      qrCodeData: 'DISC-SHOP-5',
      distance: '5.0 km away',
      rating: 4.6,
      totalReviews: 145,
      timings: '10:00 AM - 9:00 PM',
      banner:
          'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=1200&auto=format&fit=crop&q=80',
      logo:
          'https://images.unsplash.com/photo-1556906781-9a412961c28c?w=200&auto=format&fit=crop&q=80',
      description:
          'Breathable dry-fit activewear, lifting belts, wrist wraps and training accessories.',
    ),
  ];
}
