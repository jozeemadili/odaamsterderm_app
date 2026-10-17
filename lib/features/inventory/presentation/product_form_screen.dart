import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_exception.dart';
import '../../catalog/data/catalog_models.dart';
import '../../catalog/presentation/catalog_picker_sheet.dart';
import '../data/inventory_models.dart';
import 'inventory_controller.dart';

/// Handles both create and edit: pass [existing] to edit, a [prefillBarcode]
/// when arriving from a barcode scan that found no match, or [duplicateFrom]
/// when stocking a product that already exists at another store — this
/// prefills name/category/unit/pricing but leaves barcode, quantity and the
/// store blank so the two stores stay independent stock rows.
class ProductFormScreen extends ConsumerStatefulWidget {
  const ProductFormScreen({
    super.key,
    this.existing,
    this.prefillBarcode,
    this.duplicateFrom,
  });

  final InventoryItem? existing;
  final String? prefillBarcode;
  final InventoryItem? duplicateFrom;

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(
    text: widget.existing?.name ?? widget.duplicateFrom?.name ?? '',
  );
  late final _skuController = TextEditingController(
    text: widget.existing?.sku ?? widget.duplicateFrom?.sku ?? '',
  );
  late final _barcodeController = TextEditingController(
    text: widget.existing?.barcode ?? widget.prefillBarcode ?? '',
  );
  late final _unitController = TextEditingController(
    text: widget.existing?.unit ?? widget.duplicateFrom?.unit ?? '',
  );
  late final _reorderController = TextEditingController(
    text:
        widget.existing?.reorderLevel.toStringAsFixed(0) ??
        widget.duplicateFrom?.reorderLevel.toStringAsFixed(0) ??
        '0',
  );
  late final _costController = TextEditingController(
    text:
        widget.existing?.unitCost?.toStringAsFixed(0) ??
        widget.duplicateFrom?.unitCost?.toStringAsFixed(0) ??
        '',
  );
  late final _priceController = TextEditingController(
    text:
        widget.existing?.unitPrice?.toStringAsFixed(0) ??
        widget.duplicateFrom?.unitPrice?.toStringAsFixed(0) ??
        '',
  );
  late final _quantityController = TextEditingController();
  int? _categoryId;
  int? _branchId;

  /// Catalog product to link on create (needed to sell on the marketplace);
  /// a duplicate for another store keeps the same catalog product.
  late CatalogProduct? _catalogProduct = widget.duplicateFrom?.product;
  String? _error;
  bool _submitting = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _categoryId =
        widget.existing?.category?.id ?? widget.duplicateFrom?.category?.id;
    _branchId = widget.existing?.branch?.id;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _barcodeController.dispose();
    _unitController.dispose();
    _reorderController.dispose();
    _costController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _scanBarcode() async {
    final code = await context.push<String>('/inventory/scan-for-form');
    if (code != null && code.isNotEmpty) {
      setState(() => _barcodeController.text = code);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _submitting = true;
      _error = null;
    });

    final repo = ref.read(inventoryRepositoryProvider);

    try {
      final item = _isEdit
          ? await repo.update(
              widget.existing!.id,
              name: _nameController.text.trim(),
              sku: _emptyToNull(_skuController.text),
              barcode: _emptyToNull(_barcodeController.text),
              categoryId: _categoryId,
              branchId: _branchId,
              unit: _emptyToNull(_unitController.text),
              reorderLevel: double.tryParse(_reorderController.text),
              unitCost: double.tryParse(_costController.text),
              unitPrice: double.tryParse(_priceController.text),
            )
          : await repo.create(
              name: _nameController.text.trim(),
              sku: _emptyToNull(_skuController.text),
              barcode: _emptyToNull(_barcodeController.text),
              categoryId: _categoryId,
              branchId: _branchId,
              unit: _emptyToNull(_unitController.text),
              reorderLevel: double.tryParse(_reorderController.text) ?? 0,
              unitCost: double.tryParse(_costController.text),
              unitPrice: double.tryParse(_priceController.text),
              quantityOnHand: double.tryParse(_quantityController.text) ?? 0,
              productId: _catalogProduct?.id,
            );

      ref.read(inventoryListControllerProvider.notifier).upsert(item);

      if (mounted) {
        if (_isEdit) {
          context.pop(item);
        } else {
          context.pushReplacement('/inventory/${item.id}');
        }
      }
    } on ApiException catch (e) {
      setState(
        () => _error =
            e.fieldError('name') ?? e.fieldError('barcode') ?? e.message,
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String? _emptyToNull(String value) =>
      value.trim().isEmpty ? null : value.trim();

  Future<void> _addCategory() async {
    final nameController = TextEditingController();
    final created = await showDialog<InventoryCategory>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New category'),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Category name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) return;
              try {
                final category = await ref
                    .read(inventoryRepositoryProvider)
                    .createCategory(name: name);
                if (context.mounted) Navigator.pop(context, category);
              } on ApiException catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(e.message)));
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (created != null) {
      ref.invalidate(inventoryCategoriesProvider);
      setState(() => _categoryId = created.id);
    }
  }

  Future<void> _addStore() async {
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    final created = await showDialog<Branch>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New store'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Store name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(
                labelText: 'Address (optional)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) return;
              try {
                final branch = await ref
                    .read(inventoryRepositoryProvider)
                    .createBranch(
                      name: name,
                      address: _emptyToNull(addressController.text),
                    );
                if (context.mounted) Navigator.pop(context, branch);
              } on ApiException catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(e.message)));
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (created != null) {
      ref.invalidate(inventoryBranchesProvider);
      setState(() => _branchId = created.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(inventoryCategoriesProvider);
    final branchesAsync = ref.watch(inventoryBranchesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEdit
              ? 'Edit product'
              : widget.duplicateFrom != null
              ? 'Stock at another store'
              : 'New product',
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (_error != null) ...[
                Text(_error!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 12),
              ],
              if (!_isEdit) ...[
                Card(
                  margin: EdgeInsets.zero,
                  child: ListTile(
                    leading: const Icon(Icons.menu_book_outlined),
                    title: Text(
                      _catalogProduct?.displayName ??
                          'Catalog product (optional)',
                    ),
                    subtitle: Text(
                      _catalogProduct == null
                          ? 'Link it to sell on the marketplace'
                          : [
                              _catalogProduct!.animalTypeName,
                              _catalogProduct!.unit,
                            ].whereType<String>().join(' · '),
                    ),
                    trailing: _catalogProduct == null
                        ? const Icon(Icons.search)
                        : IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () =>
                                setState(() => _catalogProduct = null),
                          ),
                    onTap: () async {
                      final picked = await showCatalogPicker(
                        context,
                        initialSearch: _nameController.text.trim(),
                      );
                      if (picked == null) return;
                      setState(() {
                        _catalogProduct = picked;
                        if (_nameController.text.trim().isEmpty) {
                          _nameController.text = picked.displayName;
                        }
                        if (_unitController.text.trim().isEmpty) {
                          _unitController.text = picked.unit;
                        }
                      });
                    },
                  ),
                ),
                const SizedBox(height: 12),
              ],
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Product name'),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _skuController,
                      decoration: const InputDecoration(labelText: 'SKU'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _barcodeController,
                      decoration: InputDecoration(
                        labelText: 'Barcode (optional)',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.qr_code_scanner),
                          tooltip: 'Scan barcode',
                          onPressed: _scanBarcode,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  'Leave barcode blank to have one generated automatically.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
              categoriesAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (_, _) => const SizedBox.shrink(),
                data: (categories) => Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int?>(
                        key: ValueKey('category-$_categoryId'),
                        initialValue: _categoryId,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: _isEdit ? 'Category' : 'Category *',
                        ),
                        items: [
                          if (_isEdit)
                            const DropdownMenuItem(
                              value: null,
                              child: Text('Uncategorized'),
                            ),
                          for (final c in categories)
                            DropdownMenuItem(value: c.id, child: Text(c.name)),
                        ],
                        onChanged: (v) => setState(() => _categoryId = v),
                        validator: _isEdit
                            ? null
                            : (v) => v == null ? 'Pick a category' : null,
                      ),
                    ),
                    IconButton(
                      onPressed: _addCategory,
                      icon: const Icon(Icons.add_box_outlined),
                      tooltip: 'Add category',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              branchesAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (_, _) => const SizedBox.shrink(),
                data: (branches) => Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int?>(
                        key: ValueKey('branch-$_branchId'),
                        initialValue: _branchId,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: _isEdit ? 'Store' : 'Store *',
                        ),
                        items: [
                          if (_isEdit)
                            const DropdownMenuItem(
                              value: null,
                              child: Text('Not assigned'),
                            ),
                          for (final b in branches)
                            DropdownMenuItem(value: b.id, child: Text(b.name)),
                        ],
                        onChanged: (v) => setState(() => _branchId = v),
                        validator: _isEdit
                            ? null
                            : (v) => v == null ? 'Pick a store' : null,
                      ),
                    ),
                    IconButton(
                      onPressed: _addStore,
                      icon: const Icon(Icons.add_business_outlined),
                      tooltip: 'Add store',
                    ),
                  ],
                ),
              ),
              if (widget.duplicateFrom != null && _branchId == null)
                const Padding(
                  padding: EdgeInsets.only(top: 4, bottom: 8),
                  child: Text(
                    'Pick the store this copy is for — the original stays untouched at its own store.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _unitController,
                decoration: const InputDecoration(
                  labelText: 'Unit',
                  hintText: 'pcs, kg, ltr...',
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _reorderController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Reorder level',
                      ),
                    ),
                  ),
                  if (!_isEdit) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _quantityController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Starting quantity',
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _costController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Unit cost'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Selling price',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_isEdit ? 'Save changes' : 'Add product'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
