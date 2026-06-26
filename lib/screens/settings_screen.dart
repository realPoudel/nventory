import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../design/typography.dart';
import '../providers.dart';
import '../responsive_breakpoints.dart';
import '../ui/app_components.dart';

/// Settings screen with company profile, preferences, and theme toggle.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ConstrainedContent(
        maxWidth: 800,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(context.responsivePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: 'Company Profile'),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        initialValue: settings.companyName,
                        decoration: const InputDecoration(
                          labelText: 'Company Name',
                          hintText: 'Enter your company name',
                          prefixIcon: Icon(Icons.business_outlined),
                        ),
                        onChanged: (value) {
                          ref
                              .read(appSettingsProvider.notifier)
                              .updateCompanyName(value);
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        initialValue: settings.panNumber,
                        decoration: const InputDecoration(
                          labelText: 'PAN Number',
                          hintText: '9-digit Nepal PAN',
                          prefixIcon: Icon(Icons.credit_card_outlined),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          ref
                              .read(appSettingsProvider.notifier)
                              .updatePanNumber(value);
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        initialValue: settings.registrationNumber,
                        decoration: const InputDecoration(
                          labelText: 'Registration Number',
                          hintText: 'Company registration number',
                          prefixIcon: Icon(Icons.description_outlined),
                        ),
                        onChanged: (value) {
                          ref
                              .read(appSettingsProvider.notifier)
                              .updateRegistrationNumber(value);
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        initialValue: settings.registrationLocation,
                        decoration: const InputDecoration(
                          labelText: 'Registration Location',
                          hintText: 'e.g., Kathmandu, Nepal',
                          prefixIcon: Icon(Icons.location_on_outlined),
                        ),
                        onChanged: (value) {
                          ref
                              .read(appSettingsProvider.notifier)
                              .updateRegistrationLocation(value);
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: settings.currency,
                        decoration: const InputDecoration(
                          labelText: 'Currency',
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'NPR',
                            child: Text('NPR (₨)'),
                          ),
                          DropdownMenuItem(
                            value: 'USD',
                            child: Text('USD (\$)'),
                          ),
                          DropdownMenuItem(
                            value: 'EUR',
                            child: Text('EUR (€)'),
                          ),
                          DropdownMenuItem(
                            value: 'GBP',
                            child: Text('GBP (£)'),
                          ),
                          DropdownMenuItem(
                            value: 'JPY',
                            child: Text('JPY (¥)'),
                          ),
                          DropdownMenuItem(
                            value: 'INR',
                            child: Text('INR (₹)'),
                          ),
                          DropdownMenuItem(
                            value: 'CAD',
                            child: Text('CAD (C\$)'),
                          ),
                          DropdownMenuItem(
                            value: 'AUD',
                            child: Text('AUD (A\$)'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            ref
                                .read(appSettingsProvider.notifier)
                                .updateCurrency(value);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const SectionHeader(title: 'Inventory Preferences'),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextFormField(
                        initialValue: settings.lowStockThreshold.toString(),
                        decoration: const InputDecoration(
                          labelText: 'Low Stock Threshold',
                          helperText:
                              'Alert when any item stock falls to this level',
                          prefixIcon: Icon(AppIcons.warning),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          final threshold = int.tryParse(value);
                          if (threshold != null && threshold > 0) {
                            ref
                                .read(appSettingsProvider.notifier)
                                .updateLowStockThreshold(threshold);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const SectionHeader(title: 'Appearance'),
              const SizedBox(height: 8),
              Card(
                child: RadioGroup<ThemeMode>(
                  groupValue: themeMode,
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(themeModeProvider.notifier).state = value;
                    }
                  },
                  child: const Column(
                    children: [
                      RadioListTile<ThemeMode>(
                        title: Text('System'),
                        subtitle: Text(
                          'Follow system theme',
                          style: AppTextStyles.caption,
                        ),
                        value: ThemeMode.system,
                      ),
                      RadioListTile<ThemeMode>(
                        title: Text('Light'),
                        subtitle: Text(
                          'Always use light theme',
                          style: AppTextStyles.caption,
                        ),
                        value: ThemeMode.light,
                      ),
                      RadioListTile<ThemeMode>(
                        title: Text('Dark'),
                        subtitle: Text(
                          'Always use dark theme',
                          style: AppTextStyles.caption,
                        ),
                        value: ThemeMode.dark,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const SectionHeader(title: 'About'),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                'nV',
                                style: AppTextStyles.h4.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'nVentory',
                                style: AppTextStyles.h4.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                'Version 0.1.0',
                                style: AppTextStyles.caption.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Premium inventory and workforce management app built with Flutter and Material Design 3.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
