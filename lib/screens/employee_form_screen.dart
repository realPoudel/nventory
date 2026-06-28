import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/errors.dart';
import '../core/result.dart';
import '../core/validators.dart';
import '../design/typography.dart';
import '../models/employee_model.dart';
import '../providers.dart';
import '../ui/app_components.dart';

/// Add/edit employee form — Dialog-style centered layout.
class EmployeeFormScreen extends ConsumerStatefulWidget {
  const EmployeeFormScreen({super.key, this.employee});

  final Employee? employee;

  @override
  ConsumerState<EmployeeFormScreen> createState() => _EmployeeFormScreenState();
}

class _EmployeeFormScreenState extends ConsumerState<EmployeeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _hourlyRateController;

  EmployeeRole _selectedRole = EmployeeRole.staff;
  Department _selectedDepartment = Department.warehouse;
  bool _isSubmitting = false;

  bool get isEditing => widget.employee != null;

  @override
  void initState() {
    super.initState();
    final emp = widget.employee;
    _firstNameController = TextEditingController(text: emp?.firstName ?? '');
    _lastNameController = TextEditingController(text: emp?.lastName ?? '');
    _emailController = TextEditingController(text: emp?.email ?? '');
    _phoneController = TextEditingController(text: emp?.phone ?? '');
    _hourlyRateController = TextEditingController(text: emp?.hourlyRate.toStringAsFixed(2) ?? '0.00');
    _selectedRole = emp?.role ?? EmployeeRole.staff;
    _selectedDepartment = emp?.department ?? Department.warehouse;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _hourlyRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.3),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520, maxHeight: 580),
          child: Material(
            elevation: 24,
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(context),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildFields(),
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
              isEditing ? 'Edit Employee' : 'Add Employee',
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

  Widget _buildFields() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: 'First Name',
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                validator: (value) {
                  final result = Validators.required(value, 'First name');
                  return result.error?.message;
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Last Name',
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                validator: (value) {
                  final result = Validators.required(value, 'Last name');
                  return result.error?.message;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.email_outlined, size: 18),
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            final result = Validators.email(value, 'Email');
            return result.error?.message;
          },
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _phoneController,
          decoration: const InputDecoration(
            labelText: 'Phone',
            prefixIcon: Icon(Icons.phone_outlined, size: 18),
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            hintText: '+1 555-0123',
          ),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<EmployeeRole>(
                initialValue: _selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Role',
                  prefixIcon: Icon(Icons.badge_outlined, size: 18),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                items: EmployeeRole.values.map((r) => DropdownMenuItem(value: r, child: Text(r.label))).toList(),
                onChanged: (v) => v != null ? setState(() => _selectedRole = v) : null,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: DropdownButtonFormField<Department>(
                initialValue: _selectedDepartment,
                decoration: const InputDecoration(
                  labelText: 'Department',
                  prefixIcon: Icon(Icons.business_outlined, size: 18),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                items: Department.values.map((d) => DropdownMenuItem(value: d, child: Text(d.label))).toList(),
                onChanged: (v) => v != null ? setState(() => _selectedDepartment = v) : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _hourlyRateController,
          decoration: const InputDecoration(
            labelText: 'Hourly Rate',
            prefixText: '\$ ',
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (value) {
            final result = Validators.nonNegative(num.tryParse(value ?? ''), 'Hourly rate');
            return result.error?.message;
          },
        ),
      ],
    );
  }

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
              onPressed: _isSubmitting ? null : _saveEmployee,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: _isSubmitting
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(isEditing ? 'Update' : 'Add Employee'),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _saveEmployee() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    final employee = isEditing
        ? widget.employee!.copyWith(
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            email: _emailController.text.trim(),
            phone: _phoneController.text.trim(),
            role: _selectedRole,
            department: _selectedDepartment,
            hourlyRate: double.tryParse(_hourlyRateController.text) ?? 0,
          )
        : Employee.create(
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            email: _emailController.text.trim(),
            phone: _phoneController.text.trim(),
            role: _selectedRole,
            department: _selectedDepartment,
            hourlyRate: double.tryParse(_hourlyRateController.text) ?? 0,
          );

    final result = isEditing
        ? await ref.read(employeeCrudProvider.notifier).update(employee)
        : await ref.read(employeeCrudProvider.notifier).create(employee);

    setState(() => _isSubmitting = false);
    if (!mounted) {
      return;
    }

    switch (result) {
      case Ok<Employee, AppError>():
        ref.invalidate(employeesProvider);
        ref.invalidate(filteredEmployeesProvider);
        ref.invalidate(workforceStatsProvider);
        if (mounted) {
          showPremiumToast(context, message: isEditing ? 'Employee updated' : 'Employee added', type: ToastType.success);
          context.pop();
        }
      case Err<Employee, AppError>(:final error):
        if (mounted) {
          showPremiumToast(context, message: error.message, type: ToastType.error);
        }
    }
  }
}
