import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/design_tokens.dart';

class OtpVerificationPage extends StatefulWidget {
  const OtpVerificationPage({super.key});

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  // Support 8 digits as received in Supabase email
  final List<TextEditingController> _controllers = List.generate(8, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(8, (index) => FocusNode());
  
  int _secondsRemaining = 30;
  Timer? _timer;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        if (mounted) setState(() => _secondsRemaining--);
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _onOtpChanged(String value, int index) {
    if (value.length == 1 && index < 7) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    
    // Auto-submit if all fields are filled
    if (_controllers.every((c) => c.text.isNotEmpty)) {
      _handleVerify();
    }
  }

  Future<void> _handleVerify() async {
    final args = ModalRoute.of(context)!.settings.arguments;
    String? email;
    bool isRecovery = false;

    if (args is String) {
      email = args;
    } else if (args is Map<String, dynamic>) {
      email = args['email'];
      isRecovery = args['isRecovery'] ?? false;
    }

    final otp = _controllers.map((c) => c.text).join();

    if (email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: No email provided for verification')),
      );
      return;
    }

    if (otp.length < 8) return;

    setState(() => _isLoading = true);

    try {
      await Supabase.instance.client.auth.verifyOTP(
        type: isRecovery ? OtpType.recovery : OtpType.signup,
        email: email,
        token: otp,
      );

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/new-password');
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: AppColors.error),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid verification code'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleResend() async {
    final args = ModalRoute.of(context)!.settings.arguments;
    String? email;
    if (args is String) email = args;
    if (args is Map<String, dynamic>) email = args['email'];

    if (email == null) return;

    setState(() {
      _secondsRemaining = 60;
      _isLoading = true;
    });

    try {
      await Supabase.instance.client.auth.signInWithOtp(email: email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('A new code has been sent to your email')),
        );
        _startTimer();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to resend code'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments;
    String email = 'your email';
    if (args is String) email = args;
    if (args is Map<String, dynamic>) email = args['email'] ?? 'your email';

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          _buildBackgroundElements(),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 48),
                        _buildHeroIcon(),
                        const SizedBox(height: 24),
                        Text(
                          'Verify Your Account',
                          textAlign: TextAlign.center,
                          style: AppTypography.headline.copyWith(
                            color: AppColors.primary,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Enter the 8-digit code sent to\n$email',
                          textAlign: TextAlign.center,
                          style: AppTypography.body.copyWith(
                            color: AppColors.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 48),

                        // 8-Digit OTP Inputs
                        _buildOtpInputs(),

                        const SizedBox(height: 48),

                        _buildVerifyButton(),

                        const SizedBox(height: 32),
                        _buildResendSection(),
                        const SizedBox(height: 48),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          if (_isLoading)
            Container(
              color: Colors.black12,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildBackgroundElements() {
    return Stack(
      children: [
        Positioned(
          top: -50,
          right: -50,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.secondaryContainer.withValues(alpha:0.1)),
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).size.height * 0.25,
          left: -100,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primaryContainer.withValues(alpha:0.05)),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            style: IconButton.styleFrom(backgroundColor: AppColors.surfaceContainerHigh.withValues(alpha:0.5)),
          ),
          Text(
            'Sacred Rhythm',
            style: AppTypography.headline.copyWith(color: AppColors.primary, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildHeroIcon() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(color: AppColors.secondaryContainer.withValues(alpha:0.3), shape: BoxShape.circle),
      child: const Icon(Icons.mark_email_read_rounded, size: 40, color: AppColors.secondary),
    );
  }

  Widget _buildOtpInputs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(8, (index) {
        return SizedBox(
          width: 35, // Slightly smaller to fit 8 fields on screen
          height: 55,
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            style: AppTypography.headline.copyWith(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
            decoration: InputDecoration(
              counterText: '',
              hintText: '•',
              hintStyle: TextStyle(color: AppColors.outline.withValues(alpha:0.3)),
              fillColor: AppColors.surfaceContainerLowest,
              filled: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: (value) => _onOtpChanged(value, index),
          ),
        );
      }),
    );
  }

  Widget _buildVerifyButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleVerify,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 8,
      ),
      child: Text(
        'Verify Identity',
        style: AppTypography.label.copyWith(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildResendSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: AppColors.surfaceContainer.withValues(alpha:0.5), borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Text(
            'Didn’t receive the code?',
            textAlign: TextAlign.center,
            style: AppTypography.body.copyWith(color: AppColors.onSurfaceVariant, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: _secondsRemaining == 0 ? _handleResend : null,
                child: Text(
                  'Resend Code',
                  style: AppTypography.label.copyWith(
                    color: _secondsRemaining == 0 ? AppColors.primary : AppColors.outline,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (_secondsRemaining > 0) ...[
                const SizedBox(width: 8),
                Text(
                  '(${_secondsRemaining}s)',
                  style: AppTypography.label.copyWith(color: AppColors.secondary, fontWeight: FontWeight.bold),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
