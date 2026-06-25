import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/errors.dart';
import '../core/result.dart';
import '../core/validators.dart';
import '../design/typography.dart';
import '../models/item_model.dart';
import '../providers.dart';
import '../responsive_breakpoints.dart';
import '../ui/app_components.dart';

/// Add/Edit item form screen.
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
    _descriptionController = TextEditingController(
      text: item?.description ?? '',
    );
    _quantityController = TextEditingController(
      text: item?.quantity.toString() ?? '0',
    );
    _costPriceController = TextEditingController(
      text: item?.costPrice.toStringAsFixed(2) ?? '0.00',
    );
    _sellingPriceController = TextEditingController(
      text: item?.sellingPrice.toStringAsFixed(2) ?? '0.00',
    );
    _lowStockController = TextEditingController(
      text: item?.lowStockThreshold.toString() ?? '10',
    );
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
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Item' : 'Add Item'),
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : _saveItem,
            child: Text(
              'Save',
              style: AppTextStyles.button.copyWith(
                color: _isSubmitting
                    ? Theme.of(context).colorScheme.outline
                    : Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
      body: ConstrainedContent(
        maxWidth: 800,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(context.responsivePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Basic info section
              const SectionHeader(title: 'Basic Information'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Item Name *',
                  hintText: 'Enter item name',
                ),
                validator: (value) {
                  final result = Validators.required(value, 'Item name');
                  return result.error?.message;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _skuController,
                decoration: const InputDecoration(
                  labelText: 'SKU *',
                  hintText: 'e.g., ITEM-001',
                  prefixIcon: Icon(AppIcons.barcode),
                ),
                validator: (value) {
                  final result = Validators.sku(value, 'SKU');
                  return result.error?.message;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Optional description',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Category dropdown
              categoriesAsync.when(
                data: (categories) => DropdownButtonFormField<String>(
                  initialValue: _selectedCategoryId,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    prefixIcon: Icon(AppIcons.category),
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('No Category'),
                    ),
                    ...categories.map(
                      (c) => DropdownMenuItem<String>(
                        value: c.id,
                        child: Text(c.name),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedCategoryId = value);
                  },
                ),
                loading: () => const LinearProgressIndicator(),
                error: (_, _) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 24),
              const SectionHeader(title: 'Pricing & Stock'),
              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _costPriceController,
                      decoration: const InputDecoration(
                        labelText: 'Cost Price',
                        prefixText: '\$ ',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) {
                        final result = Validators.nonNegative(
                          num.tryParse(value ?? ''),
                          'Cost price',
                        );
                        return result.error?.message;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _sellingPriceController,
                      decoration: const InputDecoration(
                        labelText: 'Selling Price',
                        prefixText: '\$ ',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) {
                        final result = Validators.nonNegative(
                          num.tryParse(value ?? ''),
                          'Selling price',
                        );
                        return result.error?.message;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _quantityController,
                      decoration: const InputDecoration(
                        labelText: 'Quantity *',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (isEditing) {
                          return null;
                        }
                        final result = Validators.nonNegative(
                          int.tryParse(value ?? ''),
                          'Quantity',
                        );
                        return result.error?.message;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<UnitOfMeasure>(
                      initialValue: _selectedUnit,
                      decoration: const InputDecoration(labelText: 'Unit'),
                      items: UnitOfMeasure.values.map((unit) {
                        return DropdownMenuItem<UnitOfMeasure>(
                          value: unit,
                          child: Text(unit.abbreviation),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedUnit = value);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _lowStockController,
                      decoration: const InputDecoration(
                        labelText: 'Low Stock Threshold',
                        helperText: 'Alert when stock falls to this level',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        final result = Validators.nonNegative(
                          int.tryParse(value ?? ''),
                          'Threshold',
                        );
                        return result.error?.message;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Location',
                        hintText: 'e.g., Aisle 3, Shelf B',
                        prefixIcon: Icon(AppIcons.location),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
        ),
      ),
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
          showPremiumSnackBar(
            context,
            message: isEditing ? 'Item updated' : 'Item created',
            icon: AppIcons.success,
          );
          context.pop();
        }
      case Err<Item, AppError>(:final error):
        if (mounted) {
          showPremiumSnackBar(
            context,
            message: 'Error: ${error.message}',
            icon: AppIcons.error,
          );
        }
    }
  }
}
