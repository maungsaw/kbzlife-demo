import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../const.dart';

class OtpBottomSheet extends ConsumerStatefulWidget {
  final String phoneNumber;
  final String title;
  final String description;
  final VoidCallback onVerified;
  final int maxLength;
  final int resendLimit;
  final Duration verificationDuration;
  final bool autoVerify;

  const OtpBottomSheet({
    super.key,
    required this.phoneNumber,
    required this.title,
    required this.description,
    required this.onVerified,
    this.maxLength = 6,
    this.resendLimit = 3,
    this.verificationDuration = const Duration(seconds: 1),
    this.autoVerify = false,
  });

  static Future<void> show({
    required BuildContext context,
    required String phoneNumber,
    required String title,
    required String description,
    required VoidCallback onVerified,
    int maxLength = 6,
    int resendLimit = 3,
    Duration verificationDuration = const Duration(seconds: 1),
    bool autoVerify = false,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => OtpBottomSheet(
        phoneNumber: phoneNumber,
        title: title,
        description: description,
        onVerified: onVerified,
        maxLength: maxLength,
        resendLimit: resendLimit,
        verificationDuration: verificationDuration,
        autoVerify: autoVerify,
      ),
    );
  }

  @override
  ConsumerState<OtpBottomSheet> createState() => _OtpBottomSheetState();
}

class _OtpBottomSheetState extends ConsumerState<OtpBottomSheet> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  Timer? _timer;
  int _startSeconds = 60;
  int _otpRequestCount = 1;
  bool _canResend = false;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.maxLength,
      (_) => TextEditingController(),
    );
    _focusNodes = List.generate(widget.maxLength, (_) => FocusNode());
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _startSeconds = 60;
      _canResend = false;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_startSeconds == 0) {
        setState(() {
          _timer?.cancel();
          _canResend = true;
        });
      } else {
        setState(() => _startSeconds--);
      }
    });
  }

  void _resendOtp() {
    if (!_canResend || _otpRequestCount >= widget.resendLimit) {
      if (_otpRequestCount >= widget.resendLimit) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Maximum allowable SMS OTP requests (${widget.resendLimit}/${widget.resendLimit}) exceeded for this session.',
            ),
            backgroundColor: context.colors.danger,
          ),
        );
      }
      return;
    }

    setState(() => _otpRequestCount++);
    _startTimer();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'New OTP sent. Request ($_otpRequestCount/${widget.resendLimit})',
        ),
      ),
    );
  }

  void _onDigitEntered(int index, String value) {
    if (value.isNotEmpty) {
      if (index < widget.maxLength - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        if (widget.autoVerify) {
          _verifyOtpCode();
        }
      }
    }
  }

  void _onDigitDeleted(int index) {
    if (_controllers[index].text.isEmpty && index > 0) {
      _controllers[index - 1].clear();
      _focusNodes[index - 1].requestFocus();
    }
  }

  String get _fullOtpCode =>
      _controllers.map((controller) => controller.text).join();

  Future<void> _verifyOtpCode() async {
    if (_fullOtpCode.length < widget.maxLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter all ${widget.maxLength} OTP digits.'),
        ),
      );
      return;
    }

    setState(() => _isVerifying = true);
    await Future.delayed(widget.verificationDuration);

    if (mounted && context.mounted) {
      setState(() => _isVerifying = false);
      widget.onVerified();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 20,
        left: 20,
        right: 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.colors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: context.colors.accentNavy,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${widget.description} Sent to ${widget.phoneNumber}',
              style: TextStyle(fontSize: 12, color: context.colors.muted),
            ),
            const SizedBox(height: 24),

            // OTP Fields
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(widget.maxLength, (index) {
                return SizedBox(
                  width: 44,
                  height: 52,
                  child: KeyboardListener(
                    focusNode: FocusNode(),
                    onKeyEvent: (event) {
                      if (event is KeyDownEvent &&
                          event.logicalKey == LogicalKeyboardKey.backspace &&
                          _controllers[index].text.isEmpty &&
                          index > 0) {
                        _controllers[index - 1].clear();
                        _focusNodes[index - 1].requestFocus();
                      }
                    },
                    child: TextFormField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      autofocus: index == 0,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: context.colors.accentNavy,
                      ),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        counterText: '',
                        contentPadding: EdgeInsets.zero,
                        filled: true,
                        fillColor: context.colors.surfaceBg,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: context.colors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: context.colors.primaryColor,
                            width: 2,
                          ),
                        ),
                      ),
                      onChanged: (val) {
                        if (val.isNotEmpty) {
                          _onDigitEntered(index, val);
                        } else {
                          _onDigitDeleted(index);
                        }
                      },
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),

            // Timer & Resend
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _canResend
                      ? "Didn't receive the code?"
                      : 'Resend code in ${_startSeconds.toString().padLeft(2, '0')}s',
                  style: TextStyle(fontSize: 12, color: context.colors.muted),
                ),
                GestureDetector(
                  onTap: _canResend ? _resendOtp : null,
                  child: Text(
                    'Resend OTP (${widget.resendLimit - _otpRequestCount} left)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _canResend
                          ? context.colors.primaryColor
                          : context.colors.muted,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Verify Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primaryColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _isVerifying ? null : _verifyOtpCode,
                child: _isVerifying
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Verify Code',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
