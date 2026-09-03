import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../eapp/pickers.dart';
import '../providers/auth_provider.dart';
import '../const.dart';
import '../widgets/otp_bottom_sheet.dart';
import 'widget.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _nrcController = TextEditingController();
  final _mobileController = TextEditingController();
  final _licenseController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isSubmitting = false;
  bool _isAlreadyExist = true; // Flag to toggle exist check state

  @override
  void dispose() {
    _nameController.dispose();
    _nrcController.dispose();
    _mobileController.dispose();
    _licenseController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final navigator = Navigator.of(context);
    final phoneNumber = _mobileController.text.trim();

    try {
      await Future.delayed(const Duration(seconds: 1));
      final bool isPhoneExist = _isAlreadyExist;

      if (!mounted) return;
      setState(() => _isSubmitting = false);

      if (isPhoneExist) {
        // Phone number already exists -> Route directly to Admin Review Progress
        navigator.pushReplacement(
          MaterialPageRoute(
            builder: (context) => const AdminReviewProgressScreen(),
          ),
        );
      } else {
        // Phone number does NOT exist -> Show OTP Bottom Sheet
        OtpBottomSheet.show(
          // ignore: use_build_context_synchronously
          context: context,
          phoneNumber: phoneNumber,
          title: 'Verify Phone Number',
          description: 'Enter the OTP code sent to your mobile number.',
          onVerified: () async {
            if (mounted && context.mounted) {
              Navigator.of(context).pop();
              await Future.delayed(const Duration(milliseconds: 100));
              if (mounted && context.mounted) {
                ref.read(authProvider.notifier).login();
                Navigator.of(context).pop();
              }
            }
          },
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration check failed: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
        title: const Text(
          'Register Account',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.accentNavy,
          ),
        ),
        scrolledUnderElevation: 0,
        automaticallyImplyActions: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: .start,
              children: [
                buildInputField(
                  controller: _nameController,
                  label: 'Name *',
                  hint: 'Enter your full name',
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Please enter name' : null,
                ),
                const SizedBox(height: 16),

                // Identification *
                AppTextField(
                  controller: _nrcController,
                  label: 'Identification *',
                  hint: '12/KaMaNa(N)127487',
                  readOnly: true,
                  suffixIcon: const Icon(Icons.chevron_right),
                  onTap: () async {
                    final result = await showIdentificationPickerSheet(
                      context,
                      initial: _nrcController.text,
                    );
                    if (result != null) {
                      _nrcController.text = result.$1;
                    }
                  },
                  validator: (val) => val == null || val.isEmpty
                      ? 'Please enter identification'
                      : null,
                ),
                const SizedBox(height: 16),

                // Mobile Number * (with Flag UI)
                buildInputField(
                  controller: _mobileController,
                  label: 'Mobile Number *',
                  hint: '09 750337968',
                  keyboardType: TextInputType.phone,
                  showFlag: true,
                  validator: (val) => val == null || val.isEmpty
                      ? 'Please enter mobile number'
                      : null,
                ),
                const SizedBox(height: 16),

                // License No.
                buildInputField(
                  controller: _licenseController,
                  label: 'License No.',
                  hint: 'LA-IO-09834',
                ),
                const SizedBox(height: 16),

                // Email
                buildInputField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'maychan@gmail.com',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 32),

                // REGISTER Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _isSubmitting
                        ? null
                        : () => _handleRegister(context),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'REGISTER',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.1,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // Test Toggle Switch
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'isAlreadyExist (Test Toggle)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.accentNavy,
                      ),
                    ),
                    Switch(
                      value: _isAlreadyExist,
                      activeThumbColor: AppColors.primaryColor,
                      onChanged: (val) {
                        setState(() {
                          _isAlreadyExist = val;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Login Redirect
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(fontSize: 13, color: AppColors.muted),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.maybePop(context),
                      child: const Text(
                        'Login Now',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Target screen placeholder for existing user review state
class AdminReviewProgressScreen extends StatelessWidget {
  const AdminReviewProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Review Progress')),
      body: const Center(
        child: Text('Your account is currently under admin review.'),
      ),
    );
  }
}
