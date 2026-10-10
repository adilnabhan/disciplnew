import 'package:flutter/foundation.dart';
import 'package:customer_mobile_app/src/features/challenges/domain/models/challenge_list_model.dart';

@immutable
class ChallengeListState {
  final List<ChallengeModel> allChallenges;
  final List<ChallengeModel> challenges;
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;
  final bool hasMore;
  final int currentPage;
  final String selectedStatus;
  final String? selectedChallengeType;
  final List<int> selectedPartnerIds;
  final List<ChallengePartner> partners;
  final bool isLoadingPartners;
  final String? selectedCategory;
  final String searchQuery;

  const ChallengeListState({
    this.allChallenges = const [],
    this.challenges = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.hasMore = false,
    this.currentPage = 1,
    this.selectedStatus = 'all',
    this.selectedChallengeType,
    this.selectedPartnerIds = const [],
    this.partners = const [],
    this.isLoadingPartners = false,
    this.selectedCategory,
    this.searchQuery = '',
  });

  ChallengeListState copyWith({
    List<ChallengeModel>? allChallenges,
    List<ChallengeModel>? challenges,
    bool? isLoading,
    bool? isLoadingMore,
    String? errorMessage,
    bool? hasMore,
    int? currentPage,
    String? selectedStatus,
    String? selectedChallengeType,
    bool clearChallengeType = false,
    List<int>? selectedPartnerIds,
    List<ChallengePartner>? partners,
    bool? isLoadingPartners,
    String? selectedCategory,
    bool clearCategory = false,
    String? searchQuery,
  }) {
    return ChallengeListState(
      allChallenges: allChallenges ?? this.allChallenges,
      challenges: challenges ?? this.challenges,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      selectedChallengeType: clearChallengeType 
          ? null 
          : (selectedChallengeType ?? this.selectedChallengeType),
      selectedPartnerIds: selectedPartnerIds ?? this.selectedPartnerIds,
      partners: partners ?? this.partners,
      isLoadingPartners: isLoadingPartners ?? this.isLoadingPartners,
      selectedCategory: clearCategory 
          ? null 
          : (selectedCategory ?? this.selectedCategory),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}
