import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/errors.dart';
import '../core/result.dart';
import '../core/validators.dart';
import '../design/typography.dart';
import '../models/employee_model.dart';
import '../providers.dart';
import '../responsive_breakpoints.dart';
import '../ui/app_components.dart';

/// Add/Edit employee form screen.
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
    _hourlyRateController = TextEditingController(
      text: emp?.hourlyRate.toStringAsFixed(2) ?? '0.00',
    );
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
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Employee' : 'Add Employee'),
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : _saveEmployee,
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
                const SectionHeader(title: 'Personal Information'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(
                        labelText: 'First Name *',
                      ),
                      validator: (value) {
                        final result = Validators.required(value, 'First name');
                        return result.error?.message;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(
                        labelText: 'Last Name *',
                      ),
                      validator: (value) {
                        final result = Validators.required(value, 'Last name');
                        return result.error?.message;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email *',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  final result = Validators.email(value, 'Email');
                  return result.error?.message;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  prefixIcon: Icon(Icons.phone_outlined),
                  hintText: 'e.g., +1 555-0123',
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 24),
              const SectionHeader(title: 'Job Details'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<EmployeeRole>(
                      initialValue: _selectedRole,
                      decoration: const InputDecoration(
                        labelText: 'Role *',
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                      items: EmployeeRole.values.map((role) {
                        return DropdownMenuItem<EmployeeRole>(
                          value: role,
                          child: Text(role.label),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedRole = value);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<Department>(
                      initialValue: _selectedDepartment,
                      decoration: const InputDecoration(
                        labelText: 'Department *',
                        prefixIcon: Icon(Icons.business_outlined),
                      ),
                      items: Department.values.map((dept) {
                        return DropdownMenuItem<Department>(
                          value: dept,
                          child: Text(dept.label),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedDepartment = value);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _hourlyRateController,
                decoration: const InputDecoration(
                  labelText: 'Hourly Rate',
                  prefixText: '\$ ',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  final result = Validators.nonNegative(
                    num.tryParse(value ?? ''),
                    'Hourly rate',
                  );
                  return result.error?.message;
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
        ),
      ),
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
          showPremiumSnackBar(
            context,
            message: isEditing ? 'Employee updated' : 'Employee added',
            icon: AppIcons.success,
          );
          context.pop();
        }
      case Err<Employee, AppError>(:final error):
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
