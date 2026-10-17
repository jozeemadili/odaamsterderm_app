import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_controller.dart';
import '../data/expense_models.dart';
import '../data/expense_repository.dart';

final expenseRepositoryProvider =
    Provider((ref) => ExpenseRepository(ref.watch(apiClientProvider)));

class ExpenseListState {
  const ExpenseListState({
    this.items = const [],
    this.page = 1,
    this.hasMore = true,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
  });

  final List<Expense> items;
  final int page;
  final bool hasMore;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;

  ExpenseListState copyWith({
    List<Expense>? items,
    int? page,
    bool? hasMore,
    bool? isLoading,
    bool? isLoadingMore,
    Object? error = _unset,
  }) {
    return ExpenseListState(
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

class ExpenseListController extends StateNotifier<ExpenseListState> {
  ExpenseListController(this._repository) : super(const ExpenseListState()) {
    load();
  }

  final ExpenseRepository _repository;

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

  void upsert(Expense expense) {
    state = state.copyWith(items: [expense, ...state.items]);
  }
}

final expenseListControllerProvider =
    StateNotifierProvider.autoDispose<ExpenseListController, ExpenseListState>(
  (ref) => ExpenseListController(ref.watch(expenseRepositoryProvider)),
);
