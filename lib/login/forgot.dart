import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../const.dart';
import '../widgets/otp_bottom_sheet.dart';
import 'widget.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final _phoneController = TextEditingController();
  final _remarkController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isOtpVerified = false;
  bool _isSubmitting = false;

  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _remarkController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _triggerOtpStep() {
    if (_phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid phone number.')),
      );
      return;
    }
    OtpBottomSheet.show(
      context: context,
      phoneNumber: _phoneController.text.trim(),
      title: 'Reset Password OTP',
      description: 'Enter the 6-digit OTP code sent to verify your identity.',
      onVerified: () async {
        if (mounted && context.mounted) {
          Navigator.pop(context);
          await Future.delayed(const Duration(milliseconds: 100));
          if (mounted) {
            setState(() => _isOtpVerified = true);
          }
        }
      },
    );
  }

  void _submitReset() async {
    if (!_isOtpVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please verify your OTP first.')),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (mounted && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset successfully!'),
          backgroundColor: AppColors.accentNavy,
        ),
      );
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted && context.mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: const Text(
          'Forgot Password',
          style: TextStyle(fontSize: 15, color: AppColors.accentNavy),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.accentNavy,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!_isOtpVerified) ...[
                  const Text(
                    'Enter your registered agent mobile number to receive a security OTP.',
                    style: TextStyle(fontSize: 12, color: AppColors.muted),
                  ),
                  const SizedBox(height: 16),
                  buildInputField(
                    controller: _phoneController,
                    label: 'Mobile Number',
                    hint: '9xxxxxxxxx',
                    keyboardType: TextInputType.phone,
                    showFlag: true,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        elevation: 0,
                      ),
                      onPressed: _triggerOtpStep,
                      child: const Text(
                        'Request OTP',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  buildInputField(
                    controller: _remarkController,
                    label: 'Reset Reason / Remark (*)',
                    hint:
                        'State reason (e.g., Device lost, Password forgotten)',
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Reason/Remark is mandatory.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  buildInputField(
                    controller: _newPasswordController,
                    label: 'New Password',
                    hint: 'Enter new password',
                    isPassword: true,
                    obscureText: _obscureNewPassword,
                    onToggleVisibility: () {
                      setState(() {
                        _obscureNewPassword = !_obscureNewPassword;
                      });
                    },
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Password cannot be empty.';
                      }
                      if (val.length < 6) {
                        return 'Password must be at least 6 characters.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  buildInputField(
                    controller: _confirmPasswordController,
                    label: 'Confirm New Password',
                    hint: 'Confirm new password',
                    isPassword: true,
                    obscureText: _obscureConfirmPassword,
                    onToggleVisibility: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                    validator: (val) {
                      if (val != _newPasswordController.text) {
                        return 'Passwords do not match.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        elevation: 0,
                      ),
                      onPressed: _isSubmitting ? null : _submitReset,
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
                              'Update Password',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
