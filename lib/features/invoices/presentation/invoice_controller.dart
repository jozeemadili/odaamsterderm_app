import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_controller.dart';
import '../../customers/data/customer_repository.dart';
import '../data/invoice_models.dart';
import '../data/invoice_repository.dart';

final invoiceRepositoryProvider =
    Provider((ref) => InvoiceRepository(ref.watch(apiClientProvider)));
final customerRepositoryProvider =
    Provider((ref) => CustomerRepository(ref.watch(apiClientProvider)));

class InvoiceListState {
  const InvoiceListState({
    this.items = const [],
    this.status,
    this.page = 1,
    this.hasMore = true,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
  });

  final List<Invoice> items;
  final String? status;
  final int page;
  final bool hasMore;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;

  InvoiceListState copyWith({
    List<Invoice>? items,
    Object? status = _unset,
    int? page,
    bool? hasMore,
    bool? isLoading,
    bool? isLoadingMore,
    Object? error = _unset,
  }) {
    return InvoiceListState(
      items: items ?? this.items,
      status: identical(status, _unset) ? this.status : status as String?,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: identical(error, _unset) ? this.error : error as String?,
    );
  }
}

const _unset = Object();

class InvoiceListController extends StateNotifier<InvoiceListState> {
  InvoiceListController(this._repository) : super(const InvoiceListState()) {
    load();
  }

  final InvoiceRepository _repository;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _repository.list(status: state.status, page: 1);
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
          await _repository.list(status: state.status, page: nextPage);
      state = state.copyWith(
          items: [...state.items, ...result.items],
          page: nextPage,
          hasMore: result.hasMore,
          isLoadingMore: false);
    } catch (_) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  void setStatus(String? status) {
    state = state.copyWith(status: status);
    load();
  }

  void upsert(Invoice invoice) {
    final index = state.items.indexWhere((i) => i.id == invoice.id);
    if (index == -1) {
      state = state.copyWith(items: [invoice, ...state.items]);
    } else {
      final updated = [...state.items];
      updated[index] = invoice;
      state = state.copyWith(items: updated);
    }
  }
}

final invoiceListControllerProvider =
    StateNotifierProvider.autoDispose<InvoiceListController, InvoiceListState>(
  (ref) => InvoiceListController(ref.watch(invoiceRepositoryProvider)),
);

final invoiceDetailProvider = FutureProvider.autoDispose.family<Invoice, int>(
  (ref, id) => ref.watch(invoiceRepositoryProvider).get(id),
);
