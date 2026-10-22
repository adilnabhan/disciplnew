import 'package:customer_mobile_app/imports_bindings.dart';

@immutable
class BugReportItem {
  const BugReportItem({
    this.id,
    this.userId,
    this.userName,
    this.userEmail,
    this.title,
    this.subject,
    this.text,
    this.description,
    this.note,
    this.image,
    this.imageUrl,
    this.images = const [],
    this.status,
    this.statusDisplay,
    this.createdAt,
    this.updatedAt,
  });

  factory BugReportItem.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      try {
        return DateTime.parse(val.toString());
      } catch (_) {
        return null;
      }
    }

    int? parseInt(dynamic val) {
      if (val == null) return null;
      if (val is num) return val.toInt();
      return int.tryParse(val.toString());
    }

    final rawTitle = json['title'] ?? json['subject'];
    final rawText = json['text'];
    final rawDesc = json['description'];
    final rawNote = json['note'] ??
        json['admin_note'] ??
        json['notes'] ??
        json['response'] ??
        json['reply'] ??
        json['admin_response'] ??
        json['resolution_note'] ??
        json['dev_note'];

    final noteStr = rawNote?.toString().trim();

    final List<String> parsedImages = [];
    void addImageUrl(dynamic val) {
      if (val == null) return;
      if (val is String && val.trim().isNotEmpty) {
        final s = val.trim();
        if (s.startsWith('http')) {
          if (!parsedImages.contains(s)) parsedImages.add(s);
        } else {
          const base = 'https://discipl-backend.onrender.com';
          final full = s.startsWith('/') ? '$base$s' : '$base/$s';
          if (!parsedImages.contains(full)) parsedImages.add(full);
        }
      } else if (val is Map) {
        final url = val['image_url'] ?? val['image'] ?? val['url'] ?? val['file'];
        addImageUrl(url);
      }
    }

    final rawImages = json['images'] ??
        json['image_urls'] ??
        json['screenshots'] ??
        json['attachments'];
    if (rawImages is List) {
      for (final item in rawImages) {
        addImageUrl(item);
      }
    }

    final singleImg = json['image_url'] ?? json['image'];
    if (singleImg != null && parsedImages.isEmpty) {
      addImageUrl(singleImg);
    }

    return BugReportItem(
      id: parseInt(json['id']),
      userId: parseInt(json['user_id'] ?? json['user']),
      userName: json['user_name'] as String?,
      userEmail: json['user_email'] as String?,
      title: (rawTitle ?? rawText) as String?,
      subject: (rawTitle ?? rawText) as String?,
      text: (rawText ?? rawTitle ?? rawDesc) as String?,
      description: (rawDesc ?? rawText) as String?,
      note: (noteStr != null && noteStr.isNotEmpty) ? noteStr : null,
      image: json['image'] as String?,
      imageUrl: (json['image_url'] ?? json['image']) as String?,
      images: parsedImages,
      status: json['status'] as String? ?? 'not_resolved',
      statusDisplay: json['status_display'] as String? ?? 'Not Resolved',
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
    );
  }

  final int? id;
  final int? userId;
  final String? userName;
  final String? userEmail;
  final String? title;
  final String? subject;
  final String? text;
  final String? description;
  final String? note;
  final String? image;
  final String? imageUrl;
  final List<String> images;
  final String? status;
  final String? statusDisplay;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'user_email': userEmail,
      'title': title,
      'subject': subject,
      'text': text,
      'description': description,
      'note': note,
      'image': image,
      'image_url': imageUrl,
      'images': images,
      'status': status,
      'status_display': statusDisplay,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  bool get isResolved => status?.toLowerCase() == 'resolved';
  bool get isInReview => status?.toLowerCase() == 'in_review';
  bool get isNotResolved => !isResolved && !isInReview;

  String? get fullImageUrl {
    if (imageUrl != null && imageUrl!.startsWith('http')) {
      return imageUrl;
    }
    if (image != null && image!.startsWith('http')) {
      return image;
    }
    if (image != null && image!.isNotEmpty) {
      const base = 'https://discipl-backend.onrender.com';
      return image!.startsWith('/') ? '$base$image' : '$base/$image';
    }
    return imageUrl;
  }

  List<String> get allImageUrls {
    if (images.isNotEmpty) return images;
    if (fullImageUrl != null && fullImageUrl!.isNotEmpty) {
      return [fullImageUrl!];
    }
    return const [];
  }
}


