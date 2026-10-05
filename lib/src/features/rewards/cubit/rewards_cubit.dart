import 'dart:async';
import 'package:customer_mobile_app/src/features/rewards/cubit/rewards_state.dart';
import 'package:customer_mobile_app/src/features/rewards/domain/models/partner_qr_model.dart';
import 'package:customer_mobile_app/src/features/rewards/domain/models/partner_shop_model.dart';
import 'package:customer_mobile_app/src/features/rewards/domain/models/qr_history_model.dart';
import 'package:customer_mobile_app/src/features/rewards/domain/repositories/rewards_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RewardsCubit extends Cubit<RewardsState> {
  RewardsCubit({RewardsRepository? repository})
    : _repository = repository ?? RewardsRepository(),
      super(const RewardsState());

  final RewardsRepository _repository;
  Timer? _countdownTimer;

  Future<void> loadRewards({bool isRefresh = false}) async {
    if (isClosed) return;
    if (isRefresh) {
      emit(state.copyWith(isRefreshing: true, isHistoryLoading: true));
    } else {
      emit(
        state.copyWith(
          isLoading: true,
          isShopsLoading: true,
          isHistoryLoading: true,
        ),
      );
    }

    try {
      final qrFuture = _repository.getMyPartnerQr();
      final shopsFuture = _repository.getQrAvailableShops();
      final transactionsFuture = _repository.getMyPartnerTransactions();

      final results = await Future.wait([
        qrFuture,
        shopsFuture,
        transactionsFuture,
      ]);
      if (isClosed) return;

      final qrModel = results[0] as PartnerQrModel;
      final shops = results[1] as List<PartnerShop>;
      final transactionsResponse = results[2] as PartnerTransactionsResponse;

      final seconds = qrModel.expiresInSeconds ?? 600;
      _startTimer(seconds);

      if (isClosed) return;
      emit(
        state.copyWith(
          isLoading: false,
          isRefreshing: false,
          isShopsLoading: false,
          isHistoryLoading: false,
          partnerQr: qrModel,
          remainingSeconds: seconds,
          allShops: shops,
          filteredShops: _filterShops(
            shops,
            state.selectedCategory,
            state.searchQuery,
          ),
          savingsSummary: transactionsResponse.summary,
          historyItems: transactionsResponse.items,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          isLoading: false,
          isRefreshing: false,
          isShopsLoading: false,
          isHistoryLoading: false,
          errorMessage: 'Failed to load rewards. Tap to retry.',
        ),
      );
    }
  }

  Future<void> loadTransactions({int? shopId, String? search}) async {
    if (isClosed) return;
    emit(state.copyWith(isHistoryLoading: true));
    try {
      final response = await _repository.getMyPartnerTransactions(
        shopId: shopId,
        search: search,
      );
      if (isClosed) return;
      emit(
        state.copyWith(
          isHistoryLoading: false,
          savingsSummary: response.summary,
          historyItems: response.items,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(isHistoryLoading: false));
    }
  }

  void _startTimer(int seconds) {
    _countdownTimer?.cancel();
    var current = seconds;

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (isClosed) {
        timer.cancel();
        return;
      }
      current--;
      if (current <= 0) {
        timer.cancel();
        if (!isClosed) {
          emit(state.copyWith(remainingSeconds: 0));
        }
      } else {
        if (!isClosed) {
          emit(state.copyWith(remainingSeconds: current));
        }
      }
    });
  }

  void setCategory(String category) {
    emit(
      state.copyWith(
        selectedCategory: category,
        filteredShops: _filterShops(
          state.allShops,
          category,
          state.searchQuery,
        ),
      ),
    );
  }

  void setSearchQuery(String query) {
    emit(
      state.copyWith(
        searchQuery: query,
        filteredShops: _filterShops(
          state.allShops,
          state.selectedCategory,
          query,
        ),
      ),
    );
  }

  List<PartnerShop> _filterShops(
    List<PartnerShop> shops,
    String category,
    String query,
  ) {
    final lowerCat = category.toLowerCase();
    final lowerQuery = query.toLowerCase().trim();

    return shops.where((shop) {
      final matchesCategory =
          category == 'All' ||
          shop.category.toLowerCase() == lowerCat ||
          shop.categoryDisplay.toLowerCase().contains(lowerCat);

      final matchesQuery =
          lowerQuery.isEmpty ||
          shop.name.toLowerCase().contains(lowerQuery) ||
          shop.location.toLowerCase().contains(lowerQuery) ||
          shop.address.toLowerCase().contains(lowerQuery) ||
          shop.city.toLowerCase().contains(lowerQuery) ||
          shop.category.toLowerCase().contains(lowerQuery) ||
          shop.categoryDisplay.toLowerCase().contains(lowerQuery) ||
          shop.description.toLowerCase().contains(lowerQuery);

      return matchesCategory && matchesQuery;
    }).toList();
  }

  @override
  Future<void> close() {
    _countdownTimer?.cancel();
    return super.close();
  }
}
