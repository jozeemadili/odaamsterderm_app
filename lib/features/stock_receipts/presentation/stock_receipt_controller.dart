import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_controller.dart';
import '../data/stock_receipt_models.dart';
import '../data/stock_receipt_repository.dart';

final stockReceiptRepositoryProvider =
    Provider((ref) => StockReceiptRepository(ref.watch(apiClientProvider)));

class StockReceiptListState {
  const StockReceiptListState({
    this.items = const [],
    this.page = 1,
    this.hasMore = true,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
  });

  final List<StockReceipt> items;
  final int page;
  final bool hasMore;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;

  StockReceiptListState copyWith({
    List<StockReceipt>? items,
    int? page,
    bool? hasMore,
    bool? isLoading,
    bool? isLoadingMore,
    Object? error = _unset,
  }) {
    return StockReceiptListState(
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

class StockReceiptListController extends StateNotifier<StockReceiptListState> {
  StockReceiptListController(this._repository)
      : super(const StockReceiptListState()) {
    load();
  }

  final StockReceiptRepository _repository;

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

  void upsert(StockReceipt receipt) {
    final index = state.items.indexWhere((r) => r.id == receipt.id);
    if (index == -1) {
      state = state.copyWith(items: [receipt, ...state.items]);
    } else {
      final updated = [...state.items];
      updated[index] = receipt;
      state = state.copyWith(items: updated);
    }
  }
}

final stockReceiptListControllerProvider = StateNotifierProvider.autoDispose<
    StockReceiptListController, StockReceiptListState>(
  (ref) =>
      StockReceiptListController(ref.watch(stockReceiptRepositoryProvider)),
);

final stockReceiptDetailProvider =
    FutureProvider.autoDispose.family<StockReceipt, int>(
  (ref, id) => ref.watch(stockReceiptRepositoryProvider).get(id),
);
