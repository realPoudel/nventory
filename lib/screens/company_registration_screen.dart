import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/errors.dart';
import '../core/result.dart';
import '../core/validators.dart';
import '../design/app_colors.dart';
import '../design/typography.dart';
import '../persistence/hive_manager.dart';
import '../persistence/safe_hive.dart';
import '../providers.dart';
import '../responsive_breakpoints.dart';
import '../ui/app_components.dart';

/// Nepal PAN number validator.
/// Nepal PAN is a 9-digit numeric string.
Result<String, ValidationError> nepalPan(String? value, String fieldName) {
  if (value == null || value.trim().isEmpty) {
    return Err(RequiredFieldError(fieldName));
  }
  final cleaned = value.trim().replaceAll(RegExp(r'[\s-]'), '');
  final panRegex = RegExp(r'^\d{9}$');
  if (!panRegex.hasMatch(cleaned)) {
    return Err(InvalidFormatError(fieldName, 'a valid 9-digit Nepal PAN'));
  }
  return Ok(cleaned);
}

/// Company registration model for onboarding.
class CompanyRegistration {
  const CompanyRegistration({
    required this.companyName,
    required this.panNumber,
    required this.registrationNumber,
    required this.registrationLocation,
  });

  final String companyName;
  final String panNumber;
  final String registrationNumber;
  final String registrationLocation;

  Map<String, dynamic> toMap() => {
    'companyName': companyName,
    'panNumber': panNumber,
    'registrationNumber': registrationNumber,
    'registrationLocation': registrationLocation,
  };

  factory CompanyRegistration.fromMap(Map<String, dynamic> map) =>
      CompanyRegistration(
        companyName: map['companyName'] as String? ?? '',
        panNumber: map['panNumber'] as String? ?? '',
        registrationNumber: map['registrationNumber'] as String? ?? '',
        registrationLocation: map['registrationLocation'] as String? ?? '',
      );
}

/// Company registration notifier for handling save logic.
class CompanyRegistrationNotifier extends StateNotifier<AsyncValue<void>> {
  CompanyRegistrationNotifier() : super(const AsyncValue.data(null));

  Future<Result<void, AppError>> save(CompanyRegistration company) async {
    state = const AsyncValue.loading();
    try {
      final box = await HiveManager.getBox(HiveBoxes.settings);
      await box.put('company_registration', company.toMap());
      await box.put('has_completed_onboarding', true);
      state = const AsyncValue.data(null);
      return const Ok(null);
    } catch (e) {
      state = const AsyncValue.data(null);
      return Err(HiveWriteError('company_registration', e));
    }
  }
}

final companyRegistrationProvider =
    StateNotifierProvider<CompanyRegistrationNotifier, AsyncValue<void>>(
      (ref) => CompanyRegistrationNotifier(),
    );

/// Check if user has completed onboarding.
Future<bool> hasCompletedOnboarding() async {
  final box = await HiveManager.getBox(HiveBoxes.settings);
  return box.safeGet<bool>('has_completed_onboarding') ?? false;
}

/// Premium Company Registration / Welcome Screen.
/// First-launch landing page with hero, branding, and company setup form.
/// Multi-step experience: Welcome → Features → Registration Form.
class CompanyRegistrationScreen extends ConsumerStatefulWidget {
  const CompanyRegistrationScreen({super.key});

  @override
  ConsumerState<CompanyRegistrationScreen> createState() =>
      _CompanyRegistrationScreenState();
}

class _CompanyRegistrationScreenState
    extends ConsumerState<CompanyRegistrationScreen> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();
  final _companyNameController = TextEditingController();
  final _panController = TextEditingController();
  final _regNumberController = TextEditingController();
  final _locationController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _companyNameController.dispose();
    _panController.dispose();
    _regNumberController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: ConstrainedContent(
          maxWidth: 640,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: _currentStep == 0
                ? _buildWelcomeHero(context, cs)
                : _currentStep == 1
                ? _buildFeaturesShowcase(context, cs)
                : _buildRegistrationForm(context, cs),
          ),
        ),
      ),
    );
  }

  // === Step 0: Welcome Hero ===
  Widget _buildWelcomeHero(BuildContext context, ColorScheme cs) {
    return SingleChildScrollView(
      key: const ValueKey('welcome'),
      padding: EdgeInsets.all(context.responsivePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          // Animated Logo
          _HeroLogo(color: cs.primaryContainer),
          const SizedBox(height: 32),
          Text(
            'Welcome to nVentory',
            style: AppTextStyles.h2.copyWith(color: cs.onSurface),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Smart Inventory & Workforce Management\nBuilt for Nepal, Ready for the World',
            style: AppTextStyles.body.copyWith(color: cs.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          // Value propositions
          _ValueProposition(
            icon: AppIcons.inventory,
            title: 'Track Everything',
            description:
                'Monitor stock levels, movements, and valuations — all offline',
            color: cs.primary,
          ),
          const SizedBox(height: 12),
          _ValueProposition(
            icon: AppIcons.people,
            title: 'Manage Your Team',
            description:
                'Assign tasks, track hours, and manage workforce efficiently',
            color: cs.secondary,
          ),
          const SizedBox(height: 12),
          _ValueProposition(
            icon: AppIcons.analytics,
            title: 'Insights That Matter',
            description:
                'Real-time analytics and reports to grow your business',
            color: cs.tertiary,
          ),
          const SizedBox(height: 40),
          // CTA Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => setState(() => _currentStep = 1),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Get Started', style: AppTextStyles.button),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Takes less than 2 minutes to set up',
            style: AppTextStyles.caption.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  // === Step 1: Features Showcase ===
  Widget _buildFeaturesShowcase(BuildContext context, ColorScheme cs) {
    return SingleChildScrollView(
      key: const ValueKey('features'),
      padding: EdgeInsets.all(context.responsivePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          // Progress indicator
          Row(
            children: [
              _ProgressDot(isActive: true, color: cs.primary),
              const SizedBox(width: 8),
              _ProgressDot(isActive: true, color: cs.primary),
              const SizedBox(width: 8),
              _ProgressDot(isActive: false, color: cs.outline),
            ],
          ),
          const SizedBox(height: 32),
          Center(
            child: Text(
              'Why nVentory?',
              style: AppTextStyles.h3.copyWith(color: cs.onSurface),
            ),
          ),
          const SizedBox(height: 24),
          // Feature cards
          _FeatureCard(
            icon: Icons.cloud_off_outlined,
            title: '100% Offline',
            description:
                'Works without internet. Your data stays on your device — fast and secure.',
            color: cs.primary,
          ),
          const SizedBox(height: 12),
          const _FeatureCard(
            icon: Icons.currency_exchange_outlined,
            title: 'Nepal Ready',
            titleSuffix: '🇳🇵',
            description:
                'NPR currency, Nepal PAN validation, and local business format support.',
            color: AppColors.success,
          ),
          const SizedBox(height: 12),
          _FeatureCard(
            icon: Icons.security_outlined,
            title: 'Crash-Safe',
            description:
                'Write-ahead logging ensures your data survives app crashes and power loss.',
            color: cs.secondary,
          ),
          const SizedBox(height: 12),
          _FeatureCard(
            icon: Icons.speed_outlined,
            title: 'Lightning Fast',
            description:
                'Built with Hive database and Material Design 3 — smooth on any device.',
            color: cs.tertiary,
          ),
          const SizedBox(height: 12),
          const _FeatureCard(
            icon: Icons.public_outlined,
            title: 'Grows With You',
            description:
                'Start in Nepal, expand globally. Multi-currency support built in.',
            color: AppColors.warning,
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _currentStep = 0),
                  child: const Text('Back'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () => setState(() => _currentStep = 2),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Set Up My Company',
                    style: AppTextStyles.button,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  // === Step 2: Registration Form ===
  Widget _buildRegistrationForm(BuildContext context, ColorScheme cs) {
    return SingleChildScrollView(
      key: const ValueKey('form'),
      padding: EdgeInsets.all(context.responsivePadding),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            // Progress indicator
            Row(
              children: [
                _ProgressDot(isActive: true, color: cs.primary),
                const SizedBox(width: 8),
                _ProgressDot(isActive: true, color: cs.primary),
                const SizedBox(width: 8),
                _ProgressDot(isActive: true, color: cs.primary),
              ],
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                'Company Profile',
                style: AppTextStyles.h3.copyWith(color: cs.onSurface),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Tell us about your company to personalize your experience.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: cs.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            // Company Name
            TextFormField(
              controller: _companyNameController,
              decoration: const InputDecoration(
                labelText: 'Company Name *',
                hintText: 'e.g., Himalaya Trading Pvt. Ltd.',
                prefixIcon: Icon(Icons.business_outlined),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                final result = Validators.required(value, 'Company name');
                if (result.isErr) {
                  return result.error?.message;
                }
                return Validators.minLength(
                  value,
                  'Company name',
                  2,
                ).error?.message;
              },
            ),
            const SizedBox(height: 16),
            // PAN Number
            TextFormField(
              controller: _panController,
              decoration: const InputDecoration(
                labelText: 'PAN Number *',
                hintText: 'e.g., 123456789',
                prefixIcon: Icon(Icons.credit_card_outlined),
                helperText: '9-digit Nepal PAN number',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                final result = nepalPan(value, 'PAN number');
                return result.error?.message;
              },
            ),
            const SizedBox(height: 16),
            // Registration Number
            TextFormField(
              controller: _regNumberController,
              decoration: const InputDecoration(
                labelText: 'Registration Number *',
                hintText: 'e.g., REG-2078/001',
                prefixIcon: Icon(Icons.description_outlined),
              ),
              validator: (value) {
                final result = Validators.required(
                  value,
                  'Registration number',
                );
                return result.error?.message;
              },
            ),
            const SizedBox(height: 16),
            // Registration Location
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Registration Location *',
                hintText: 'e.g., Kathmandu, Nepal',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                final result = Validators.required(
                  value,
                  'Registration location',
                );
                return result.error?.message;
              },
            ),
            const SizedBox(height: 32),
            // Navigation buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _currentStep = 1),
                    child: const Text('Back'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'Complete Setup',
                            style: AppTextStyles.button,
                          ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'NPR (₨) will be set as your default currency.\nYou can change this in Settings later.',
                style: AppTextStyles.caption.copyWith(
                  color: cs.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    final company = CompanyRegistration(
      companyName: _companyNameController.text.trim(),
      panNumber: _panController.text.trim().replaceAll(RegExp(r'[\s-]'), ''),
      registrationNumber: _regNumberController.text.trim(),
      registrationLocation: _locationController.text.trim(),
    );

    final result = await ref
        .read(companyRegistrationProvider.notifier)
        .save(company);

    setState(() => _isSubmitting = false);

    if (!mounted) {
      return;
    }

    switch (result) {
      case Ok<void, AppError>():
        ref
            .read(appSettingsProvider.notifier)
            .updateCompanyName(company.companyName);
        ref
            .read(appSettingsProvider.notifier)
            .updatePanNumber(company.panNumber);
        ref
            .read(appSettingsProvider.notifier)
            .updateRegistrationNumber(company.registrationNumber);
        ref
            .read(appSettingsProvider.notifier)
            .updateRegistrationLocation(company.registrationLocation);
        ref.read(appSettingsProvider.notifier).updateCurrency('NPR');
        ref.read(appSettingsProvider.notifier).markOnboardingComplete();
        context.go('/');
      case Err<void, AppError>(:final error):
        showPremiumToast(
          context,
          message: 'Error: ${error.message}',
          type: ToastType.error,
        );
    }
  }
}

// === Reusable sub-widgets ===

class _HeroLogo extends StatelessWidget {
  const _HeroLogo({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Text(
          'nV',
          style: AppTextStyles.h1.copyWith(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
      ),
    );
  }
}

class _ValueProposition extends StatelessWidget {
  const _ValueProposition({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 22, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    this.titleSuffix,
    required this.description,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String? titleSuffix;
  final String description;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 24, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (titleSuffix != null) ...[
                        const SizedBox(width: 6),
                        Text(titleSuffix!, style: AppTextStyles.body),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressDot extends StatelessWidget {
  const _ProgressDot({required this.isActive, required this.color});
  final bool isActive;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isActive ? 24 : 12,
      height: 6,
      decoration: BoxDecoration(
        color: isActive ? color : color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
