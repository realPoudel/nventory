import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/errors.dart';
import '../core/result.dart';
import '../core/validators.dart';
import '../design/typography.dart';
import '../persistence/hive_manager.dart';
import '../persistence/safe_hive.dart';
import '../providers.dart';
import '../responsive_breakpoints.dart';
import '../ui/app_components.dart';

/// Nepal PAN number validator.
Result<String, ValidationError> nepalPan(String? value, String fieldName) {
  if (value == null || value.trim().isEmpty) {
    return Err(RequiredFieldError(fieldName));
  }
  final cleaned = value.trim().replaceAll(RegExp(r'[\s-]'), '');
  if (!RegExp(r'^\d{9}$').hasMatch(cleaned)) {
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

/// Premium Minimal Company Registration Screen.
/// Clean, no date, no mock data — just the essentials.
class CompanyRegistrationScreen extends ConsumerStatefulWidget {
  const CompanyRegistrationScreen({super.key});

  @override
  ConsumerState<CompanyRegistrationScreen> createState() =>
      _CompanyRegistrationScreenState();
}

class _CompanyRegistrationScreenState
    extends ConsumerState<CompanyRegistrationScreen> {
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
    final isWide = context.isDesktop;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedContent(
            maxWidth: isWide ? 520 : 400,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: context.responsivePadding,
                vertical: 32,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo
                    _buildLogo(cs),
                    const SizedBox(height: 24),
                    // Title
                    Text(
                      'nVentory',
                      style: AppTextStyles.h2.copyWith(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Smart Inventory & Workforce Management',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: cs.onSurfaceVariant,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    // Form
                    if (isWide) _buildWideForm() else _buildNarrowForm(),
                    const SizedBox(height: 28),
                    // Submit
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Get Started', style: AppTextStyles.button),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Default currency: NPR (₨). Change in Settings.',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(ColorScheme cs) {
    return Center(
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: cs.primaryContainer,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Text(
            'nV',
            style: AppTextStyles.h3.copyWith(
              color: cs.onPrimaryContainer,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNarrowForm() {
    return Column(
      children: [
        _fieldCompanyName(),
        const SizedBox(height: 12),
        _fieldPan(),
        const SizedBox(height: 12),
        _fieldRegNumber(),
        const SizedBox(height: 12),
        _fieldLocation(),
      ],
    );
  }

  Widget _buildWideForm() {
    return Column(
      children: [
        _fieldCompanyName(),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _fieldPan()),
            const SizedBox(width: 12),
            Expanded(child: _fieldRegNumber()),
          ],
        ),
        const SizedBox(height: 14),
        _fieldLocation(),
      ],
    );
  }

  // === Reusable field widgets (DRY) ===

  Widget _fieldCompanyName() {
    return TextFormField(
      controller: _companyNameController,
      decoration: const InputDecoration(
        labelText: 'Company Name',
        prefixIcon: Icon(Icons.business_outlined, size: 20),
      ),
      textCapitalization: TextCapitalization.words,
      validator: (value) {
        final result = Validators.required(value, 'Company name');
        if (result.isErr) {
          return result.error?.message;
        }
        return Validators.minLength(value, 'Company name', 2).error?.message;
      },
    );
  }

  Widget _fieldPan() {
    return TextFormField(
      controller: _panController,
      decoration: const InputDecoration(
        labelText: 'PAN Number',
        prefixIcon: Icon(Icons.credit_card_outlined, size: 20),
        helperText: '9-digit Nepal PAN',
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        final result = nepalPan(value, 'PAN number');
        return result.error?.message;
      },
    );
  }

  Widget _fieldRegNumber() {
    return TextFormField(
      controller: _regNumberController,
      decoration: const InputDecoration(
        labelText: 'Registration Number',
        prefixIcon: Icon(Icons.description_outlined, size: 20),
      ),
      validator: (value) {
        final result = Validators.required(value, 'Registration number');
        return result.error?.message;
      },
    );
  }

  Widget _fieldLocation() {
    return TextFormField(
      controller: _locationController,
      decoration: const InputDecoration(
        labelText: 'Business Location',
        prefixIcon: Icon(Icons.location_on_outlined, size: 20),
      ),
      textCapitalization: TextCapitalization.words,
      validator: (value) {
        final result = Validators.required(value, 'Business location');
        return result.error?.message;
      },
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

    final result = await ref.read(companyRegistrationProvider.notifier).save(company);

    setState(() => _isSubmitting = false);
    if (!mounted) {
      return;
    }

    switch (result) {
      case Ok<void, AppError>():
        ref.read(appSettingsProvider.notifier).updateCompanyName(company.companyName);
        ref.read(appSettingsProvider.notifier).updatePanNumber(company.panNumber);
        ref.read(appSettingsProvider.notifier).updateRegistrationNumber(company.registrationNumber);
        ref.read(appSettingsProvider.notifier).updateRegistrationLocation(company.registrationLocation);
        ref.read(appSettingsProvider.notifier).updateCurrency('NPR');
        ref.read(appSettingsProvider.notifier).markOnboardingComplete();
        context.go('/');
      case Err<void, AppError>(:final error):
        showPremiumToast(context, message: error.message, type: ToastType.error);
    }
  }
}
