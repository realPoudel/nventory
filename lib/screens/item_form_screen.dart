import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/errors.dart';
import '../core/result.dart';
import '../core/validators.dart';
import '../design/typography.dart';
import '../models/item_model.dart';
import '../models/category_model.dart';
import '../providers.dart';
import '../ui/app_components.dart';

/// Add/edit item form — Dialog-style centered layout.
/// Like Linear/Notion modal overlay with close button.
class ItemFormScreen extends ConsumerStatefulWidget {
  const ItemFormScreen({super.key, this.item});

  final Item? item;

  @override
  ConsumerState<ItemFormScreen> createState() => _ItemFormScreenState();
}

class _ItemFormScreenState extends ConsumerState<ItemFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _skuController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _quantityController;
  late final TextEditingController _costPriceController;
  late final TextEditingController _sellingPriceController;
  late final TextEditingController _lowStockController;
  late final TextEditingController _locationController;

  UnitOfMeasure _selectedUnit = UnitOfMeasure.pieces;
  String? _selectedCategoryId;
  bool _isSubmitting = false;

  bool get isEditing => widget.item != null;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _nameController = TextEditingController(text: item?.name ?? '');
    _skuController = TextEditingController(text: item?.sku ?? '');
    _descriptionController = TextEditingController(text: item?.description ?? '');
    _quantityController = TextEditingController(text: item?.quantity.toString() ?? '0');
    _costPriceController = TextEditingController(text: item?.costPrice.toStringAsFixed(2) ?? '0.00');
    _sellingPriceController = TextEditingController(text: item?.sellingPrice.toStringAsFixed(2) ?? '0.00');
    _lowStockController = TextEditingController(text: item?.lowStockThreshold.toString() ?? '10');
    _locationController = TextEditingController(text: item?.location ?? '');
    _selectedUnit = item?.unit ?? UnitOfMeasure.pieces;
    _selectedCategoryId = item?.categoryId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    _costPriceController.dispose();
    _sellingPriceController.dispose();
    _lowStockController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.3),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520, maxHeight: 640),
          child: Material(
            elevation: 24,
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with close + title
                _buildHeader(context),
                // Form body
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildFields(categoriesAsync),
                          const SizedBox(height: 24),
                          _buildActions(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Dialog header: title + close button
  Widget _buildHeader(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              isEditing ? 'Edit Item' : 'Add Item',
              style: AppTextStyles.h4.copyWith(color: cs.onSurface),
            ),
          ),
          IconButton(
            icon: Icon(AppIcons.close, size: 18, color: cs.onSurfaceVariant),
            onPressed: () => context.pop(),
          ),
        ],
      ),
    );
  }

  /// Form fields — compact minimal layout
  Widget _buildFields(AsyncValue<List<Category>> categoriesAsync) {
    return Column(
      children: [
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Item Name',
            hintText: 'Enter item name',
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          validator: (value) {
            final result = Validators.required(value, 'Item name');
            return result.error?.message;
          },
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _skuController,
          decoration: const InputDecoration(
            labelText: 'SKU',
            hintText: 'e.g., ITEM-001',
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            prefixIcon: Icon(AppIcons.barcode, size: 18),
          ),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (value) {
            final result = Validators.sku(value, 'SKU');
            return result.error?.message;
          },
        ),
        const SizedBox(height: 14),

        categoriesAsync.when(
          data: (categories) => DropdownButtonFormField<String>(
            initialValue: _selectedCategoryId,
            decoration: const InputDecoration(
              labelText: 'Category',
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              prefixIcon: Icon(AppIcons.category, size: 18),
            ),
            items: [
              const DropdownMenuItem<String>(value: null, child: Text('No Category')),
              ...categories.map((c) => DropdownMenuItem<String>(value: c.id, child: Text(c.name))),
            ],
            onChanged: (value) => setState(() => _selectedCategoryId = value),
          ),
          loading: () => const LinearProgressIndicator(),
          error: (_, _) => const SizedBox.shrink(),
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            labelText: 'Description',
            hintText: 'Optional description',
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _costPriceController,
                decoration: const InputDecoration(
                  labelText: 'Cost',
                  prefixText: '\$ ',
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  final result = Validators.nonNegative(num.tryParse(value ?? ''), 'Cost price');
                  return result.error?.message;
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                controller: _sellingPriceController,
                decoration: const InputDecoration(
                  labelText: 'Price',
                  prefixText: '\$ ',
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  final result = Validators.nonNegative(num.tryParse(value ?? ''), 'Selling price');
                  return result.error?.message;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (isEditing) {
                    return null;
                  }
                  final result = Validators.nonNegative(int.tryParse(value ?? ''), 'Quantity');
                  return result.error?.message;
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: DropdownButtonFormField<UnitOfMeasure>(
                initialValue: _selectedUnit,
                decoration: const InputDecoration(
                  labelText: 'Unit',
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                items: UnitOfMeasure.values.map((u) => DropdownMenuItem(value: u, child: Text(u.abbreviation))).toList(),
                onChanged: (v) => v != null ? setState(() => _selectedUnit = v) : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _locationController,
          decoration: const InputDecoration(
            labelText: 'Location',
            hintText: 'Aisle 3, Shelf B',
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            prefixIcon: Icon(AppIcons.location, size: 18),
          ),
        ),
      ],
    );
  }

  /// Dialog actions: Cancel + Save
  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 40,
            child: OutlinedButton(
              onPressed: () => context.pop(),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Cancel'),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 40,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _saveItem,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: _isSubmitting
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(isEditing ? 'Update' : 'Add Item'),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    final item = isEditing
        ? widget.item!.copyWith(
            name: _nameController.text.trim(),
            sku: _skuController.text.trim().toUpperCase(),
            description: _descriptionController.text.trim(),
            categoryId: _selectedCategoryId,
            unit: _selectedUnit,
            costPrice: double.tryParse(_costPriceController.text) ?? 0,
            sellingPrice: double.tryParse(_sellingPriceController.text) ?? 0,
            lowStockThreshold: int.tryParse(_lowStockController.text) ?? 10,
            location: _locationController.text.trim(),
          )
        : Item.create(
            name: _nameController.text.trim(),
            sku: _skuController.text.trim().toUpperCase(),
            description: _descriptionController.text.trim(),
            categoryId: _selectedCategoryId,
            quantity: int.tryParse(_quantityController.text) ?? 0,
            unit: _selectedUnit,
            costPrice: double.tryParse(_costPriceController.text) ?? 0,
            sellingPrice: double.tryParse(_sellingPriceController.text) ?? 0,
            lowStockThreshold: int.tryParse(_lowStockController.text) ?? 10,
            location: _locationController.text.trim(),
          );

    final result = isEditing
        ? await ref.read(itemCrudProvider.notifier).update(item)
        : await ref.read(itemCrudProvider.notifier).create(item);

    setState(() => _isSubmitting = false);
    if (!mounted) {
      return;
    }

    switch (result) {
      case Ok<Item, AppError>():
        ref.invalidate(itemsProvider);
        ref.invalidate(filteredItemsProvider);
        ref.invalidate(dashboardStatsProvider);
        if (mounted) {
          showPremiumToast(context, message: isEditing ? 'Item updated' : 'Item created', type: ToastType.success);
          context.pop();
        }
      case Err<Item, AppError>(:final error):
        if (mounted) {
          showPremiumToast(context, message: 'Error: ${error.message}', type: ToastType.error);
        }
    }
  }
}
