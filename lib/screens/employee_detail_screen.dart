import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/errors.dart';
import '../core/result.dart';
import '../design/app_colors.dart';
import '../design/typography.dart';
import '../models/employee_model.dart';
import '../models/task_model.dart';
import '../providers.dart';
import '../routing/app_router.dart';
import '../responsive_breakpoints.dart';
import '../ui/app_components.dart';
import '../ui/hero_section.dart';

/// Employee detail screen with profile, contact, tasks, and shift info.
class EmployeeDetailScreen extends ConsumerWidget {
  const EmployeeDetailScreen({super.key, required this.employeeId});

  final String employeeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employeeAsync = ref.watch(employeeByIdProvider(employeeId));
    final tasksAsync = ref.watch(tasksByEmployeeProvider(employeeId));

    return employeeAsync.when(
      data: (employee) {
        if (employee == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Employee Not Found')),
            body: const Center(child: Text('Employee not found')),
          );
        }
        return _EmployeeDetailView(employee: employee, tasksAsync: tasksAsync);
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  AppIcons.error,
                  size: 48,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                const Text('Failed to load employee', style: AppTextStyles.h4),
                const SizedBox(height: 8),
                Text(
                  '$error',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmployeeDetailView extends ConsumerWidget {
  const _EmployeeDetailView({required this.employee, required this.tasksAsync});

  final Employee employee;
  final AsyncValue<List<Task>> tasksAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(employee.fullName),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(AppIcons.more),
            onSelected: (value) async {
              switch (value) {
                case 'edit':
                  context.push('${AppRoutes.employeeAdd}?id=${employee.id}');
                case 'deactivate':
                  _confirmDeactivate(context, ref);
                case 'delete':
                  _confirmDelete(context, ref);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: ListTile(
                  leading: Icon(AppIcons.edit),
                  title: Text('Edit'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              if (employee.isActive)
                const PopupMenuItem(
                  value: 'deactivate',
                  child: ListTile(
                    leading: Icon(Icons.person_off_outlined),
                    title: Text('Deactivate'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              const PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(AppIcons.delete),
                  title: Text('Delete'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: ConstrainedContent(
        maxWidth: 900,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(context.responsivePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HeroSection(
                title: employee.fullName,
                subtitle:
                    '${employee.role.label} · ${employee.department.label}',
                showLogo: true,
              ),
              const SizedBox(height: 12),
              ResponsiveBuilder(
                mobile: (_) => _buildMobileLayout(context, cs),
                tablet: (_) => _buildWideLayout(context, cs, 280),
                desktop: (_) => _buildWideLayout(context, cs, 320),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildContactCard(cs),
        const SizedBox(height: 12),
        _buildEmploymentCard(cs),
        const SizedBox(height: 12),
        _buildTasksSection(context, cs),
        const SizedBox(height: 12),
        _buildTimestampsCard(),
      ],
    );
  }

  Widget _buildWideLayout(
    BuildContext context,
    ColorScheme cs,
    double rightWidth,
  ) {
    return _TwoColumnDetail(
      left: [
        _buildContactCard(cs),
        const SizedBox(height: 12),
        _buildEmploymentCard(cs),
      ],
      right: [
        _buildTasksSection(context, cs),
        const SizedBox(height: 12),
        _buildTimestampsCard(),
      ],
      rightWidth: rightWidth,
    );
  }

  // === Shared card builders ===

  Widget _buildContactCard(ColorScheme cs) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Contact', style: AppTextStyles.labelLarge),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.email_outlined, size: 20),
                const SizedBox(width: 12),
                Text(employee.email, style: AppTextStyles.body),
              ],
            ),
            if (employee.phone.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.phone_outlined, size: 20),
                  const SizedBox(width: 12),
                  Text(employee.phone, style: AppTextStyles.body),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmploymentCard(ColorScheme cs) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Employment', style: AppTextStyles.labelLarge),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Role', style: AppTextStyles.labelMedium),
                      Text(
                        employee.role.label,
                        style: AppTextStyles.body.copyWith(color: cs.onSurface),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Department',
                        style: AppTextStyles.labelMedium,
                      ),
                      Text(
                        employee.department.label,
                        style: AppTextStyles.body.copyWith(color: cs.onSurface),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (employee.hourlyRate > 0) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Hourly Rate',
                          style: AppTextStyles.labelMedium,
                        ),
                        Text(
                          '₨${employee.hourlyRate.toStringAsFixed(2)}/hr',
                          style: AppTextStyles.body.copyWith(color: cs.primary),
                        ),
                      ],
                    ),
                  ),
                  const Expanded(child: SizedBox.shrink()),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTasksSection(BuildContext context, ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Assigned Tasks',
          subtitle: '${tasksAsync.value?.length ?? 0} tasks',
        ),
        tasksAsync.when(
          data: (tasks) {
            if (tasks.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      'No tasks assigned',
                      style: AppTextStyles.body.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              );
            }
            return Column(
              children: tasks.map((task) => _TaskCard(task: task)).toList(),
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (_, _) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildTimestampsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(AppIcons.clock, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Added: ${_formatDate(employee.createdAt)}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(AppIcons.refresh, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Updated: ${_formatDate(employee.updatedAt)}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeactivate(BuildContext context, WidgetRef ref) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Deactivate Employee',
      message: 'Are you sure you want to deactivate "${employee.fullName}"?',
      confirmLabel: 'Deactivate',
      cancelLabel: 'Cancel',
    );

    if (!confirmed || !context.mounted) {
      return;
    }

    final result = await ref
        .read(employeeCrudProvider.notifier)
        .deactivate(employee.id);

    switch (result) {
      case Ok<Employee, AppError>():
        ref.invalidate(employeeByIdProvider(employee.id));
        ref.invalidate(employeesProvider);
        ref.invalidate(filteredEmployeesProvider);
        ref.invalidate(workforceStatsProvider);
        if (context.mounted) {
          showPremiumToast(
            context,
            message: 'Employee deactivated',
            type: ToastType.success,
          );
        }
      case Err<Employee, AppError>(:final error):
        if (context.mounted) {
          showPremiumToast(
            context,
            message: error.message,
            type: ToastType.error,
          );
        }
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete Employee',
      message:
          'Are you sure you want to delete "${employee.fullName}"? This cannot be undone.',
      confirmLabel: 'Delete',
      cancelLabel: 'Cancel',
      isDestructive: true,
    );

    if (!confirmed || !context.mounted) {
      return;
    }

    final result = await ref
        .read(employeeCrudProvider.notifier)
        .delete(employee.id);

    switch (result) {
      case Ok<void, AppError>():
        ref.invalidate(employeesProvider);
        ref.invalidate(filteredEmployeesProvider);
        ref.invalidate(workforceStatsProvider);
        if (context.mounted) {
          showPremiumToast(
            context,
            message: 'Employee deleted',
            type: ToastType.success,
          );
          context.pop();
        }
      case Err<void, AppError>(:final error):
        if (context.mounted) {
          showPremiumToast(
            context,
            message: error.message,
            type: ToastType.error,
          );
        }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

/// Two-column layout for tablet/desktop detail views.
class _TwoColumnDetail extends StatelessWidget {
  const _TwoColumnDetail({
    required this.left,
    required this.right,
    required this.rightWidth,
  });

  final List<Widget> left;
  final List<Widget> right;
  final double rightWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final leftWidth = constraints.maxWidth - rightWidth - 16;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: leftWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: left,
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: rightWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: right,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final priorityColor = switch (task.priority) {
      TaskPriority.urgent => cs.error,
      TaskPriority.high => AppColors.warning,
      TaskPriority.medium => cs.primary,
      TaskPriority.low => cs.outline,
    };
    final statusColor = switch (task.status) {
      TaskStatus.completed => cs.primary,
      TaskStatus.inProgress => cs.tertiary,
      TaskStatus.pending => AppColors.warning,
      TaskStatus.cancelled => cs.outline,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: AppTextStyles.body.copyWith(color: cs.onSurface),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    task.status.label,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.flag_outlined, size: 14, color: priorityColor),
                const SizedBox(width: 4),
                Text(
                  '${task.priority.label} · ${task.type.label}',
                  style: AppTextStyles.caption.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            if (task.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                task.description,
                style: AppTextStyles.caption.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
