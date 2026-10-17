import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_controller.dart';
import '../data/payment_models.dart';
import '../data/payment_repository.dart';

final paymentRepositoryProvider =
    Provider((ref) => PaymentRepository(ref.watch(apiClientProvider)));

class PaymentListState {
  const PaymentListState({
    this.items = const [],
    this.page = 1,
    this.hasMore = true,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
  });

  final List<PaymentRecord> items;
  final int page;
  final bool hasMore;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;

  PaymentListState copyWith({
    List<PaymentRecord>? items,
    int? page,
    bool? hasMore,
    bool? isLoading,
    bool? isLoadingMore,
    Object? error = _unset,
  }) {
    return PaymentListState(
      items: items ?? this.items,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: identical(error, _unset) ? this.error : error as String?,
    );
  }
}

const _unset = Object();

class PaymentListController extends StateNotifier<PaymentListState> {
  PaymentListController(this._repository) : super(const PaymentListState()) {
    load();
  }

  final PaymentRepository _repository;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _repository.list(page: 1);
      state = state.copyWith(
          items: result.items,
          page: 1,
          hasMore: result.hasMore,
          isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final nextPage = state.page + 1;
      final result = await _repository.list(page: nextPage);
      state = state.copyWith(
          items: [...state.items, ...result.items],
          page: nextPage,
          hasMore: result.hasMore,
          isLoadingMore: false);
    } catch (_) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  void upsert(PaymentRecord payment) {
    state = state.copyWith(items: [payment, ...state.items]);
  }
}

final paymentListControllerProvider =
    StateNotifierProvider.autoDispose<PaymentListController, PaymentListState>(
  (ref) => PaymentListController(ref.watch(paymentRepositoryProvider)),
);
