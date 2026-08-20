import 'package:flutter/foundation.dart';

@immutable
class BannerModel {
  const BannerModel({
    this.id,
    this.organization,
    this.bannerImage,
    this.title,
    this.contactNumber,
    this.websiteUrl,
    this.visibility,
    this.redirectType,
    this.isActive,
    this.displayOrder,
    this.createdAt,
    this.whatsappNumber,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    final rawWhatsapp = json['whatsapp_number'] ??
        json['whatsapp_link'] ??
        json['whatsapp_url'] ??
        json['whatsapp'] ??
        json['contact_number'];
    return BannerModel(
      id: json['id'] as int?,
      organization: json['organization'] as int?,
      bannerImage: (json['image'] ?? json['banner_image']) as String?,
      title: json['title'] as String?,
      contactNumber:
          (json['whatsapp_number'] ?? json['contact_number']) as String?,
      websiteUrl: json['website_url'] as String?,
      visibility: json['visibility'] as String?,
      redirectType: json['redirect_type'] as String?,
      isActive: json['is_active'] as bool?,
      displayOrder: json['display_order'] as int?,
      createdAt: json['created_at'] as String?,
      whatsappNumber: rawWhatsapp?.toString(),
    );
  }

  final int? id;
  final int? organization;
  final String? bannerImage;
  final String? title;
  final String? contactNumber;
  final String? websiteUrl;
  final String? visibility;
  final String? redirectType;
  final bool? isActive;
  final int? displayOrder;
  final String? createdAt;
  final String? whatsappNumber;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organization': organization,
      'image': bannerImage,
      'banner_image': bannerImage,
      'title': title,
      'whatsapp_number': whatsappNumber ?? contactNumber,
      'contact_number': contactNumber,
      'website_url': websiteUrl,
      'visibility': visibility,
      'redirect_type': redirectType,
      'is_active': isActive,
      'display_order': displayOrder,
      'created_at': createdAt,
    };
  }
}

