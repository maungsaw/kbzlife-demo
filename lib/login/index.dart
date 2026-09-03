import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../const.dart';
import '../providers/auth_provider.dart';
import '../providers/router_provider.dart';
import '../widgets/otp_bottom_sheet.dart';
import 'widget.dart';

class MobileLoginScreen extends ConsumerStatefulWidget {
  final VoidCallback? onLoginSuccess;

  const MobileLoginScreen({super.key, this.onLoginSuccess});

  @override
  ConsumerState<MobileLoginScreen> createState() => _MobileLoginScreenState();
}

class _MobileLoginScreenState extends ConsumerState<MobileLoginScreen> {
  final _phoneController = TextEditingController(text: '09790123456');
  final _passwordController = TextEditingController(text: 'Password@123');
  bool _obscurePassword = true;
  bool _isLoading = false;
  final int _failedAttempts = 0;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin(BuildContext context) async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);

    if (!mounted) return;

    // Demonstration of Failed Attempt Lockout Rule (FR-4.2)
    if (_failedAttempts >= 4) {
      _showAccountLockedDialog();
      return;
    }

    // Mock UI check: Simulate same-platform concurrency block (FR-3.2)
    if (_phoneController.text == '09000000000') {
      _showErrorSnackBar(
        'You are already logged in on another mobile device. Please log out from that device first.',
      );
      return;
    }

    // Simulate New Device OTP requirement vs Direct Login (FR-3.4 / 3.5)
    OtpBottomSheet.show(
      // ignore: use_build_context_synchronously
      context: context,
      phoneNumber: _phoneController.text,
      title: 'New Device Verification',
      description:
          'First-time login detected. Enter the OTP sent to your phone.',
      onVerified: () async {
        if (mounted && context.mounted) {
          Navigator.pop(context); // Close OTP Modal
          await Future.delayed(const Duration(milliseconds: 100));
          if (mounted && context.mounted) {
            ref.read(authProvider.notifier).login();
            context.go('/');
          }
        }
      },
    );
  }

  void _showAccountLockedDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Row(
          children: [
            Icon(Icons.lock_clock_outlined, color: AppColors.danger),
            SizedBox(width: 8),
            Text(
              'Account Locked',
              style: TextStyle(fontSize: 16, color: AppColors.accentNavy),
            ),
          ],
        ),
        content: const Text(
          'You have exceeded the maximum of 5 consecutive failed attempts. Your account has been locked. Please contact a System Administrator to unlock your account.',
          style: TextStyle(fontSize: 12, color: AppColors.muted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(color: AppColors.primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontSize: 12)),
        backgroundColor: AppColors.accentNavy,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBg,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Center(
                    child: Image.asset(
                      'assets/brand-mark.png',
                      width: 80,
                      height: 80,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Center(
                    child: Text(
                      'KBZ LIFE Sales Digital Platfrom',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.accentNavy,
                      ),
                    ),
                  ),
                  const Center(
                    child: Text(
                      'Sign in with your registered phone number',
                      style: TextStyle(fontSize: 12, color: AppColors.muted),
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Phone Field
                  buildInputField(
                    controller: _phoneController,
                    label: 'Phone Number',
                    hint: 'Enter registered phone number',
                    keyboardType: TextInputType.phone,
                    showFlag: true,
                  ),
                  const SizedBox(height: 16),

                  // Password Field
                  buildInputField(
                    controller: _passwordController,
                    label: 'Password',
                    hint: 'Enter account password',
                    isPassword: true,
                    obscureText: _obscurePassword,
                    onToggleVisibility: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),

                  // Forgot Password Link (FR-7.0)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        context.push(RoutePaths.forgotPassword);
                      },
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Primary Login Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      onPressed: _isLoading
                          ? null
                          : () => _handleLogin(context),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Sign In',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Biometric Authentication (FR-5.0)
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      _showErrorSnackBar('Biometric login successful!');
                      ref.read(authProvider.notifier).login();
                      context.go('/');
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.fingerprint_rounded,
                          color: AppColors.accentNavy,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Login with Biometrics',
                          style: TextStyle(
                            color: AppColors.accentNavy,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Registration Path Navigation Trigger (FR-2.0)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an agent account? ",
                        style: TextStyle(fontSize: 12, color: AppColors.muted),
                      ),
                      GestureDetector(
                        onTap: () {
                          context.push(RoutePaths.register);
                        },
                        child: const Text(
                          'Register Here',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: AppColors.accentNavy),
                onPressed: () {
                  context.pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
