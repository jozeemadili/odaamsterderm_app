import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_controller.dart';
import '../data/inventory_models.dart';
import '../data/inventory_repository.dart';

final inventoryRepositoryProvider = Provider(
  (ref) => InventoryRepository(ref.watch(apiClientProvider)),
);

final inventoryCategoriesProvider = FutureProvider.autoDispose(
  (ref) => ref.watch(inventoryRepositoryProvider).categories(),
);

final inventoryBranchesProvider = FutureProvider.autoDispose(
  (ref) => ref.watch(inventoryRepositoryProvider).branches(),
);

class InventoryListState {
  const InventoryListState({
    this.items = const [],
    this.search = '',
    this.categoryId,
    this.page = 1,
    this.hasMore = true,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
  });

  final List<InventoryItem> items;
  final String search;
  final int? categoryId;
  final int page;
  final bool hasMore;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;

  InventoryListState copyWith({
    List<InventoryItem>? items,
    String? search,
    Object? categoryId = _unset,
    int? page,
    bool? hasMore,
    bool? isLoading,
    bool? isLoadingMore,
    Object? error = _unset,
  }) {
    return InventoryListState(
      items: items ?? this.items,
      search: search ?? this.search,
      categoryId: identical(categoryId, _unset)
          ? this.categoryId
          : categoryId as int?,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: identical(error, _unset) ? this.error : error as String?,
    );
  }
}

const _unset = Object();

class InventoryListController extends StateNotifier<InventoryListState> {
  InventoryListController(this._repository)
    : super(const InventoryListState()) {
    load();
  }

  final InventoryRepository _repository;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _repository.list(
        search: state.search,
        categoryId: state.categoryId,
        page: 1,
      );
      state = state.copyWith(
        items: result.items,
        page: 1,
        hasMore: result.hasMore,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final nextPage = state.page + 1;
      final result = await _repository.list(
        search: state.search,
        categoryId: state.categoryId,
        page: nextPage,
      );
      state = state.copyWith(
        items: [...state.items, ...result.items],
        page: nextPage,
        hasMore: result.hasMore,
        isLoadingMore: false,
      );
    } catch (_) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  void setSearch(String value) {
    state = state.copyWith(search: value);
    load();
  }

  void setCategory(int? categoryId) {
    state = state.copyWith(categoryId: categoryId);
    load();
  }

  /// Replaces or inserts a single item after it's created/edited elsewhere,
  /// so the list reflects the change without a full reload.
  void upsert(InventoryItem item) {
    final index = state.items.indexWhere((i) => i.id == item.id);
    if (index == -1) {
      state = state.copyWith(items: [item, ...state.items]);
    } else {
      final updated = [...state.items];
      updated[index] = item;
      state = state.copyWith(items: updated);
    }
  }

  void remove(int id) {
    state = state.copyWith(
      items: state.items.where((i) => i.id != id).toList(),
    );
  }
}

final inventoryListControllerProvider =
    StateNotifierProvider.autoDispose<
      InventoryListController,
      InventoryListState
    >((ref) => InventoryListController(ref.watch(inventoryRepositoryProvider)));
