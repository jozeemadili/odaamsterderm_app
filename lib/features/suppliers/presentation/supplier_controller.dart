import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_controller.dart';
import '../data/supplier_models.dart';
import '../data/supplier_repository.dart';

final supplierRepositoryProvider =
    Provider((ref) => SupplierRepository(ref.watch(apiClientProvider)));

class SupplierListState {
  const SupplierListState({
    this.items = const [],
    this.page = 1,
    this.hasMore = true,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
  });

  final List<Supplier> items;
  final int page;
  final bool hasMore;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;

  SupplierListState copyWith({
    List<Supplier>? items,
    int? page,
    bool? hasMore,
    bool? isLoading,
    bool? isLoadingMore,
    Object? error = _unset,
  }) {
    return SupplierListState(
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

class SupplierListController extends StateNotifier<SupplierListState> {
  SupplierListController(this._repository) : super(const SupplierListState()) {
    load();
  }

  final SupplierRepository _repository;

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

  void upsert(Supplier supplier) {
    final index = state.items.indexWhere((s) => s.id == supplier.id);
    if (index == -1) {
      state = state.copyWith(items: [supplier, ...state.items]);
    } else {
      final updated = [...state.items];
      updated[index] = supplier;
      state = state.copyWith(items: updated);
    }
  }
}

final supplierListControllerProvider = StateNotifierProvider.autoDispose<
    SupplierListController, SupplierListState>(
  (ref) => SupplierListController(ref.watch(supplierRepositoryProvider)),
);

final supplierDetailProvider = FutureProvider.autoDispose.family<Supplier, int>(
  (ref, id) => ref.watch(supplierRepositoryProvider).get(id),
);
