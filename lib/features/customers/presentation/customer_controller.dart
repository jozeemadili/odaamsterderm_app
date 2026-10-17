import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_controller.dart';
import '../data/customer_models.dart';
import '../data/customer_repository.dart';

final customerRepositoryProvider =
    Provider((ref) => CustomerRepository(ref.watch(apiClientProvider)));

class CustomerListState {
  const CustomerListState({
    this.items = const [],
    this.search = '',
    this.page = 1,
    this.hasMore = true,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
  });

  final List<Customer> items;
  final String search;
  final int page;
  final bool hasMore;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;

  CustomerListState copyWith({
    List<Customer>? items,
    String? search,
    int? page,
    bool? hasMore,
    bool? isLoading,
    bool? isLoadingMore,
    Object? error = _unset,
  }) {
    return CustomerListState(
      items: items ?? this.items,
      search: search ?? this.search,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: identical(error, _unset) ? this.error : error as String?,
    );
  }
}

const _unset = Object();

class CustomerListController extends StateNotifier<CustomerListState> {
  CustomerListController(this._repository) : super(const CustomerListState()) {
    load();
  }

  final CustomerRepository _repository;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _repository.list(search: state.search, page: 1);
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
      final result =
          await _repository.list(search: state.search, page: nextPage);
      state = state.copyWith(
          items: [...state.items, ...result.items],
          page: nextPage,
          hasMore: result.hasMore,
          isLoadingMore: false);
    } catch (_) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  void setSearch(String value) {
    state = state.copyWith(search: value);
    load();
  }

  void upsert(Customer customer) {
    final index = state.items.indexWhere((c) => c.id == customer.id);
    if (index == -1) {
      state = state.copyWith(items: [customer, ...state.items]);
    } else {
      final updated = [...state.items];
      updated[index] = customer;
      state = state.copyWith(items: updated);
    }
  }
}

final customerListControllerProvider = StateNotifierProvider.autoDispose<
    CustomerListController, CustomerListState>(
  (ref) => CustomerListController(ref.watch(customerRepositoryProvider)),
);

final customerDetailProvider =
    FutureProvider.autoDispose.family<CustomerDetail, int>(
  (ref, id) => ref.watch(customerRepositoryProvider).get(id),
);
