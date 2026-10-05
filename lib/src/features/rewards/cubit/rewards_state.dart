import 'package:customer_mobile_app/src/features/rewards/domain/models/partner_qr_model.dart';
import 'package:customer_mobile_app/src/features/rewards/domain/models/partner_shop_model.dart';
import 'package:customer_mobile_app/src/features/rewards/domain/models/qr_history_model.dart';
import 'package:flutter/foundation.dart';

@immutable
class RewardsState {
  const RewardsState({
    this.isLoading = false,
    this.isRefreshing = false,
    this.isShopsLoading = false,
    this.isHistoryLoading = false,
    this.partnerQr,
    this.errorMessage,
    this.remainingSeconds = 600,
    this.selectedCategory = 'All',
    this.searchQuery = '',
    this.allShops = const [],
    this.filteredShops = const [],
    this.savingsSummary = UserSavingsSummaryModel.empty,
    this.historyItems = const [],
    this.historyFilter = 'All',
    this.historySearchQuery = '',
  });

  final bool isLoading;
  final bool isRefreshing;
  final bool isShopsLoading;
  final bool isHistoryLoading;
  final PartnerQrModel? partnerQr;
  final String? errorMessage;
  final int remainingSeconds;
  final String selectedCategory;
  final String searchQuery;
  final List<PartnerShop> allShops;
  final List<PartnerShop> filteredShops;
  final UserSavingsSummaryModel savingsSummary;
  final List<QrRedemptionHistoryItem> historyItems;
  final String historyFilter;
  final String historySearchQuery;

  RewardsState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    bool? isShopsLoading,
    bool? isHistoryLoading,
    PartnerQrModel? partnerQr,
    String? errorMessage,
    int? remainingSeconds,
    String? selectedCategory,
    String? searchQuery,
    List<PartnerShop>? allShops,
    List<PartnerShop>? filteredShops,
    UserSavingsSummaryModel? savingsSummary,
    List<QrRedemptionHistoryItem>? historyItems,
    String? historyFilter,
    String? historySearchQuery,
  }) {
    return RewardsState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isShopsLoading: isShopsLoading ?? this.isShopsLoading,
      isHistoryLoading: isHistoryLoading ?? this.isHistoryLoading,
      partnerQr: partnerQr ?? this.partnerQr,
      errorMessage: errorMessage,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      allShops: allShops ?? this.allShops,
      filteredShops: filteredShops ?? this.filteredShops,
      savingsSummary: savingsSummary ?? this.savingsSummary,
      historyItems: historyItems ?? this.historyItems,
      historyFilter: historyFilter ?? this.historyFilter,
      historySearchQuery: historySearchQuery ?? this.historySearchQuery,
    );
  }
}
