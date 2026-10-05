class QrRedemptionHistoryItem {
  const QrRedemptionHistoryItem({
    required this.id,
    required this.shopName,
    required this.shopCategory,
    required this.location,
    required this.redeemedAt,
    required this.billAmount,
    required this.discountPercent,
    required this.discountAmount,
    required this.finalAmount,
    required this.qrRef,
    this.merchantId,
    this.shopLogo,
    this.photo,
    this.shopCity,
    this.shopAddress,
    this.productDetails,
    this.items = const [],
    this.invoiceNumber,
    this.pointsAwarded = 0,
    this.status = 'completed',
    this.notes,
    this.staffName,
    this.customerName,
    this.customerMobile,
    this.date,
    this.time,
    this.isVerified = true,
  });

  factory QrRedemptionHistoryItem.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic val, [double defaultVal = 0]) {
      if (val == null) return defaultVal;
      if (val is num) return val.toDouble();
      if (val is String) {
        return double.tryParse(val.replaceAll(RegExp('[^0-9.]'), '')) ??
            defaultVal;
      }
      return defaultVal;
    }

    int parseInt(dynamic val, [int defaultVal = 0]) {
      if (val == null) return defaultVal;
      if (val is num) return val.toInt();
      if (val is String) {
        return int.tryParse(val) ?? defaultVal;
      }
      return defaultVal;
    }

    DateTime parseDateTime() {
      if (json['created_at'] != null) {
        final parsed = DateTime.tryParse(json['created_at'].toString());
        if (parsed != null) return parsed;
      }
      if (json['redeemed_at'] != null) {
        final parsed = DateTime.tryParse(json['redeemed_at'].toString());
        if (parsed != null) return parsed;
      }
      if (json['date'] != null) {
        final parsed = DateTime.tryParse(json['date'].toString());
        if (parsed != null) return parsed;
      }
      return DateTime.now();
    }

    final rawItems = json['items'];
    var itemsList = const <String>[];
    if (rawItems is List) {
      itemsList = rawItems.map((e) => e.toString()).toList();
    }

    final shopName =
        json['shop_name']?.toString() ??
        json['merchant_name']?.toString() ??
        'Partner Store';
    final shopCategory =
        json['shop_category']?.toString() ??
        json['merchant_category']?.toString() ??
        'General';
    final invoiceNo = json['invoice_number']?.toString();
    final qrRef = invoiceNo ?? json['qr_ref']?.toString() ?? '#INV-000';

    final billAmount = parseDouble(
      json['bill_amount'] ?? json['purchase_amount'],
    );
    final discountPercent = parseDouble(
      json['discount_percentage'] ??
          json['discount_get'] ??
          json['discount_percent'],
      10,
    );
    final discountAmount = parseDouble(
      json['how_much_saved'] ?? json['discount_amount'],
    );
    final finalAmount = parseDouble(
      json['final_amount_paid'] ??
          json['final_amount'] ??
          (billAmount - discountAmount),
    );

    final address = json['shop_address']?.toString() ?? '';
    final city = json['shop_city']?.toString() ?? '';
    final rawLoc = json['location']?.toString() ?? '';
    String location;
    if (rawLoc.isNotEmpty) {
      location = rawLoc;
    } else if (address.isNotEmpty &&
        city.isNotEmpty &&
        !address.contains(city)) {
      location = '$address, $city';
    } else if (address.isNotEmpty) {
      location = address;
    } else if (city.isNotEmpty) {
      location = city;
    } else {
      location = 'Partner Location';
    }

    final statusStr = json['status']?.toString() ?? 'completed';

    return QrRedemptionHistoryItem(
      id: json['id']?.toString() ?? '',
      merchantId: parseInt(json['merchant']),
      shopName: shopName,
      shopCategory: shopCategory,
      shopLogo: json['logo']?.toString() ?? json['shop_logo']?.toString(),
      photo: json['photo']?.toString(),
      location: location,
      shopCity: city.isNotEmpty ? city : null,
      shopAddress: address.isNotEmpty ? address : null,
      redeemedAt: parseDateTime(),
      billAmount: billAmount,
      discountPercent: discountPercent,
      discountAmount: discountAmount,
      finalAmount: finalAmount,
      qrRef: qrRef,
      invoiceNumber: invoiceNo,
      productDetails: json['product_details']?.toString(),
      items: itemsList,
      pointsAwarded: parseInt(json['points_awarded']),
      status: statusStr,
      notes: json['notes']?.toString(),
      staffName: json['staff_name']?.toString(),
      customerName: json['customer_name']?.toString(),
      customerMobile: json['customer_mobile']?.toString(),
      date: json['date']?.toString(),
      time: json['time']?.toString(),
      isVerified:
          statusStr == 'completed' || (json['is_verified'] as bool? ?? true),
    );
  }

  final String id;
  final int? merchantId;
  final String shopName;
  final String shopCategory;
  final String? shopLogo;
  final String? photo;
  final String location;
  final String? shopCity;
  final String? shopAddress;
  final DateTime redeemedAt;
  final double billAmount;
  final double discountPercent;
  final double discountAmount;
  final double finalAmount;
  final String qrRef;
  final String? invoiceNumber;
  final String? productDetails;
  final List<String> items;
  final int pointsAwarded;
  final String status;
  final String? notes;
  final String? staffName;
  final String? customerName;
  final String? customerMobile;
  final String? date;
  final String? time;
  final bool isVerified;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'merchant': merchantId,
      'shop_name': shopName,
      'shop_category': shopCategory,
      'shop_logo': shopLogo,
      'photo': photo,
      'location': location,
      'shop_city': shopCity,
      'shop_address': shopAddress,
      'redeemed_at': redeemedAt.toIso8601String(),
      'bill_amount': billAmount,
      'discount_percent': discountPercent,
      'discount_amount': discountAmount,
      'final_amount': finalAmount,
      'qr_ref': qrRef,
      'invoice_number': invoiceNumber,
      'product_details': productDetails,
      'items': items,
      'points_awarded': pointsAwarded,
      'status': status,
      'notes': notes,
      'staff_name': staffName,
      'customer_name': customerName,
      'customer_mobile': customerMobile,
      'date': date,
      'time': time,
      'is_verified': isVerified,
    };
  }

  static const List<QrRedemptionHistoryItem> emptyList = [];
}

class UserSavingsSummaryModel {
  const UserSavingsSummaryModel({
    required this.totalSaved,
    required this.totalSpent,
    required this.totalRedemptions,
    required this.thisMonthSaved,
    required this.averageDiscountPercent,
    this.totalFinalPaid = 0,
    this.totalPointsEarned = 0,
  });

  factory UserSavingsSummaryModel.fromJson(
    Map<String, dynamic> json, {
    List<QrRedemptionHistoryItem>? items,
  }) {
    double parseDouble(dynamic val, [double defaultVal = 0]) {
      if (val == null) return defaultVal;
      if (val is num) return val.toDouble();
      if (val is String) {
        return double.tryParse(val.replaceAll(RegExp('[^0-9.]'), '')) ??
            defaultVal;
      }
      return defaultVal;
    }

    int parseInt(dynamic val, [int defaultVal = 0]) {
      if (val == null) return defaultVal;
      if (val is num) return val.toInt();
      if (val is String) {
        return int.tryParse(val) ?? defaultVal;
      }
      return defaultVal;
    }

    final summaryObj =
        json['summary'] is Map<String, dynamic>
            ? json['summary'] as Map<String, dynamic>
            : null;

    final totalSaved = parseDouble(
      json['total_saved_money'] ??
          summaryObj?['total_saved_money'] ??
          summaryObj?['total_savings_inr'] ??
          json['total_saved'],
    );

    final totalSpent = parseDouble(
      json['total_purchase_amount'] ??
          summaryObj?['total_purchase_amount'] ??
          json['total_spent'],
    );

    final totalFinalPaid = parseDouble(
      json['total_final_paid'] ??
          summaryObj?['total_final_paid'] ??
          (totalSpent - totalSaved > 0 ? totalSpent - totalSaved : 0),
    );

    final totalRedemptions = parseInt(
      json['total_qr_codes_used'] ??
          summaryObj?['total_qr_codes_used'] ??
          summaryObj?['total_transactions'] ??
          summaryObj?['total_visits'] ??
          json['count'] ??
          json['total_redemptions'],
    );

    final totalPointsEarned = parseInt(
      json['total_points_earned'] ?? summaryObj?['total_points_earned'],
    );

    final avgDiscount = parseDouble(
      summaryObj?['average_discount_percentage'] ??
          json['average_discount_percent'],
    );

    // Calculate this month's savings from items if available, or fallback gracefully
    var thisMonthSaved = parseDouble(json['this_month_saved']);
    if (thisMonthSaved == 0 && items != null && items.isNotEmpty) {
      final now = DateTime.now();
      thisMonthSaved = items
          .where(
            (item) =>
                item.redeemedAt.month == now.month &&
                item.redeemedAt.year == now.year,
          )
          .fold<double>(0, (acc, item) => acc + item.discountAmount);
    }
    if (thisMonthSaved == 0) {
      thisMonthSaved = totalSaved;
    }

    return UserSavingsSummaryModel(
      totalSaved: totalSaved,
      totalSpent: totalSpent,
      totalFinalPaid: totalFinalPaid,
      totalRedemptions: totalRedemptions,
      totalPointsEarned: totalPointsEarned,
      thisMonthSaved: thisMonthSaved,
      averageDiscountPercent: avgDiscount,
    );
  }

  final double totalSaved;
  final double totalSpent;
  final double totalFinalPaid;
  final int totalRedemptions;
  final int totalPointsEarned;
  final double thisMonthSaved;
  final double averageDiscountPercent;

  Map<String, dynamic> toJson() {
    return {
      'total_saved_money': totalSaved,
      'total_purchase_amount': totalSpent,
      'total_final_paid': totalFinalPaid,
      'total_qr_codes_used': totalRedemptions,
      'total_points_earned': totalPointsEarned,
      'this_month_saved': thisMonthSaved,
      'average_discount_percent': averageDiscountPercent,
    };
  }

  static const UserSavingsSummaryModel empty = UserSavingsSummaryModel(
    totalSaved: 0,
    totalSpent: 0,
    totalRedemptions: 0,
    thisMonthSaved: 0,
    averageDiscountPercent: 0,
  );
}

class PartnerTransactionsResponse {
  const PartnerTransactionsResponse({
    required this.summary,
    required this.items,
    this.count = 0,
    this.next,
    this.previous,
  });

  factory PartnerTransactionsResponse.fromJson(Map<String, dynamic> json) {
    var items = <QrRedemptionHistoryItem>[];
    if (json['results'] is List) {
      items =
          (json['results'] as List)
              .whereType<Map<String, dynamic>>()
              .map(QrRedemptionHistoryItem.fromJson)
              .toList();
    }

    final summary = UserSavingsSummaryModel.fromJson(json, items: items);
    final count = (json['count'] as num?)?.toInt() ?? items.length;

    return PartnerTransactionsResponse(
      summary: summary,
      items: items,
      count: count,
      next: json['next']?.toString(),
      previous: json['previous']?.toString(),
    );
  }

  final UserSavingsSummaryModel summary;
  final List<QrRedemptionHistoryItem> items;
  final int count;
  final String? next;
  final String? previous;
}
