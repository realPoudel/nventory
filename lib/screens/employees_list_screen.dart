import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../design/app_colors.dart';
import '../design/typography.dart';
import '../models/employee_model.dart';
import '../providers.dart';
import '../routing/app_router.dart';
import '../responsive_breakpoints.dart';
import '../ui/app_components.dart';

/// Employees list screen with search, role filter, and directory cards.
class EmployeesListScreen extends ConsumerStatefulWidget {
  const EmployeesListScreen({super.key});

  @override
  ConsumerState<EmployeesListScreen> createState() =>
      _EmployeesListScreenState();
}

class _EmployeesListScreenState extends ConsumerState<EmployeesListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employeesAsync = ref.watch(filteredEmployeesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Employees')),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: EdgeInsets.all(context.responsivePadding),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or email...',
                prefixIcon: const Icon(AppIcons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(AppIcons.close),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(employeeSearchQueryProvider.notifier).state =
                              '';
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                ref.read(employeeSearchQueryProvider.notifier).state = value;
              },
            ),
          ),
          // Role filter chips
          const _RoleFilterChips(),
          // Employee list
          Expanded(
            child: ConstrainedContent(
              maxWidth: 1200,
              child: employeesAsync.when(
              data: (employees) {
                if (employees.isEmpty) {
                  return EmptyState(
                    icon: AppIcons.people,
                    title: 'No employees yet',
                    subtitle: 'Add your first team member to get started.',
                    actionLabel: 'Add Employee',
                    onAction: () => context.push(AppRoutes.employeeAdd),
                  );
                }
                return _EmployeeList(employees: employees);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(AppIcons.error, size: 48, color: AppColors.error),
                    SizedBox(height: 16),
                    Text('Error loading employees', style: AppTextStyles.body),
                  ],
                ),
              ),
            ),
          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.employeeAdd),
        icon: const Icon(AppIcons.add),
        label: const Text('Add Employee'),
      ),
    );
  }
}

class _RoleFilterChips extends ConsumerWidget {
  const _RoleFilterChips();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedRole = ref.watch(selectedEmployeeRoleProvider);

    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          FilterChip(
            label: const Text('All'),
            selected: selectedRole == null,
            onSelected: (_) {
              ref.read(selectedEmployeeRoleProvider.notifier).state = null;
            },
          ),
          const SizedBox(width: 8),
          for (final role in EmployeeRole.values) ...[
            FilterChip(
              label: Text(role.label),
              selected: selectedRole == role,
              onSelected: (_) {
                ref.read(selectedEmployeeRoleProvider.notifier).state = role;
              },
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _EmployeeList extends StatelessWidget {
  const _EmployeeList({required this.employees});

  final List<Employee> employees;

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: (_) => _EmployeeListView(employees: employees),
      tablet: (_) => _EmployeeGridView(employees: employees),
      desktop: (_) => _EmployeeGridView(employees: employees),
    );
  }
}

/// Mobile layout: vertical ListView with ListTile cards.
class _EmployeeListView extends StatelessWidget {
  const _EmployeeListView({required this.employees});

  final List<Employee> employees;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: employees.length,
      itemBuilder: (context, index) {
        final employee = employees[index];
        final avatarColor = Color(employee.avatarColor);

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
            ),
            child: InkWell(
              onTap: () => context.push('/employees/${employee.id}'),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: avatarColor.withValues(alpha: 0.15),
                      child: Text(
                        employee.initials,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: avatarColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Name + details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            employee.fullName,
                            style: AppTextStyles.body.copyWith(color: cs.onSurface),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${employee.role.label} · ${employee.department.label}',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Status + chevron
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (!employee.isActive)
                          Text(
                            'Inactive',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: cs.outline,
                            ),
                          ),
                        const SizedBox(height: 4),
                        Icon(AppIcons.forward, size: 16, color: cs.outline),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Tablet/Desktop layout: responsive GridView with compact cards.
class _EmployeeGridView extends StatelessWidget {
  const _EmployeeGridView({required this.employees});

  final List<Employee> employees;

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = context.gridColumns;
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: _EmployeeGridCard.aspectRatio,
      ),
      itemCount: employees.length,
      itemBuilder: (context, index) {
        return _EmployeeGridCard(employee: employees[index]);
      },
    );
  }
}

/// Compact grid card for an employee.
class _EmployeeGridCard extends StatelessWidget {
  const _EmployeeGridCard({required this.employee});

  final Employee employee;

  /// Aspect ratio for grid card sizing.
  static const double aspectRatio = 0.95;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final avatarColor = Color(employee.avatarColor);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: InkWell(
        onTap: () => context.push('/employees/${employee.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top: avatar + status dot
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: avatarColor.withValues(alpha: 0.15),
                    child: Text(
                      employee.initials,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: avatarColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (!employee.isActive)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: cs.outline,
                        shape: BoxShape.circle,
                      ),
                    )
                  else
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: cs.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              // Full name
              Text(
                employee.fullName,
                style: AppTextStyles.body.copyWith(color: cs.onSurface),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // Role · Department
              Text(
                '${employee.role.label} · ${employee.department.label}',
                style: AppTextStyles.labelSmall.copyWith(
                  color: cs.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // Email
              Text(
                employee.email,
                style: AppTextStyles.labelSmall.copyWith(
                  color: cs.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
