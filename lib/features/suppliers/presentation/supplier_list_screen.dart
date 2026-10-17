import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format/currency.dart';
import '../data/supplier_models.dart';
import 'supplier_controller.dart';

class SupplierListScreen extends ConsumerStatefulWidget {
  const SupplierListScreen({super.key});

  @override
  ConsumerState<SupplierListScreen> createState() => _SupplierListScreenState();
}

class _SupplierListScreenState extends ConsumerState<SupplierListScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >
          _scrollController.position.maxScrollExtent - 300) {
        ref.read(supplierListControllerProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(supplierListControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Suppliers')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final supplier = await context.push<Supplier>('/suppliers/new');
          if (supplier != null) {
            ref.read(supplierListControllerProvider.notifier).upsert(supplier);
          }
        },
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(supplierListControllerProvider.notifier).load(),
        child: _buildBody(state),
      ),
    );
  }

  Widget _buildBody(SupplierListState state) {
    if (state.isLoading && state.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null && state.items.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 80),
          Center(
              child: Text('Could not load suppliers.\n${state.error}',
                  textAlign: TextAlign.center)),
        ],
      );
    }
    if (state.items.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 80),
          Center(child: Text('No suppliers yet. Tap + to add one.')),
        ],
      );
    }

    return ListView.separated(
      controller: _scrollController,
      itemCount: state.items.length + (state.hasMore ? 1 : 0),
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        if (index >= state.items.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }
        final supplier = state.items[index];
        return ListTile(
          title: Text(supplier.name),
          subtitle: Text([
            if (supplier.contactPerson != null) supplier.contactPerson!,
            if (supplier.phone != null) supplier.phone!
          ].join(' · ')),
          trailing: supplier.outstandingBalance > 0
              ? Text(formatTzs(supplier.outstandingBalance),
                  style: const TextStyle(color: Colors.redAccent))
              : null,
          onTap: () => context.push('/suppliers/${supplier.id}'),
        );
      },
    );
  }
}
