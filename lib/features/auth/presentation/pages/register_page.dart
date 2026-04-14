import 'package:flutter/material.dart';
import '../../../../core/design_tokens.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final email = _emailController.text.trim();
    final name = _nameController.text.trim();

    if (email.isEmpty || name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Using OTP-based sign up (Magic Link) as requested "no password" flow
      await Supabase.instance.client.auth.signInWithOtp(
        email: email,
        data: {'full_name': name},
        shouldCreateUser: true,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification link sent to your email!')),
        );
        Navigator.pushReplacementNamed(context, '/otp-verification', arguments: email);
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
          const SnackBar(content: Text('An unexpected error occurred'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          // 1. Hero Background Decoration
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.secondaryFixed.withValues(alpha:0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primaryFixedDim.withValues(alpha:0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // 2. Main Content
          SafeArea(
            child: Column(
              children: [
                _buildCustomAppBar(context),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 450),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            Text(
                              'Create Account',
                              style: AppTypography.headline.copyWith(
                                color: AppColors.primary,
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Begin your rhythmic journey into spiritual tranquility.',
                              style: AppTypography.body.copyWith(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 15,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 48),

                            // Form Card
                            Container(
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerLowest,
                                borderRadius: BorderRadius.circular(32),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha:0.08),
                                    blurRadius: 40,
                                    offset: const Offset(0, 20),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildInputLabel('FULL NAME'),
                                  const SizedBox(height: 8),
                                  _buildCustomTextField(
                                    controller: _nameController,
                                    hintText: 'Enter your full name',
                                    keyboardType: TextInputType.name,
                                  ),
                                  const SizedBox(height: 24),
                                  _buildInputLabel('EMAIL ADDRESS'),
                                  const SizedBox(height: 8),
                                  _buildCustomTextField(
                                    controller: _emailController,
                                    hintText: 'email@example.com',
                                    keyboardType: TextInputType.emailAddress,
                                  ),
                                  const SizedBox(height: 24),
                                  _buildInputLabel('PHONE NUMBER (OPTIONAL)'),
                                  const SizedBox(height: 8),
                                  _buildCustomTextField(
                                    controller: _phoneController,
                                    hintText: '+1 (555) 000-0000',
                                    keyboardType: TextInputType.phone,
                                  ),
                                  const SizedBox(height: 32),

                                  // Action Button
                                  GestureDetector(
                                    onTap: _isLoading ? null : _handleRegister,
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(vertical: 18),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        gradient: const LinearGradient(
                                          colors: [AppColors.primary, AppColors.primaryContainer],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.primary.withValues(alpha:0.2),
                                            blurRadius: 12,
                                            offset: const Offset(0, 6),
                                          ),
                                        ],
                                      ),
                                      child: _isLoading 
                                        ? const Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)))
                                        : Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Create Account',
                                              style: AppTypography.label.copyWith(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                                          ],
                                        ),
                                    ),
                                  ),

                                  const SizedBox(height: 32),
                                  // Divider & Social icons...
                                  _buildSocialSection(),
                                ],
                              ),
                            ),

                            const SizedBox(height: 40),
                            _buildLoginFooter(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primary),
          ),
          const SizedBox(width: 8),
          Text(
            'Sacred Rhythm',
            style: AppTypography.display.copyWith(
              color: AppColors.primary,
              fontSize: 20,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label,
        style: AppTypography.label.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: AppColors.primary,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildCustomTextField({required TextEditingController controller, required String hintText, required TextInputType keyboardType}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTypography.body.copyWith(color: AppColors.outline.withValues(alpha:0.5), fontSize: 14),
        fillColor: AppColors.surfaceContainerLow,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
    );
  }

  Widget _buildSocialSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: AppColors.outlineVariant.withValues(alpha:0.3))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'OR',
                style: AppTypography.label.copyWith(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.outline, letterSpacing: 2),
              ),
            ),
            Expanded(child: Divider(color: AppColors.outlineVariant.withValues(alpha:0.3))),
          ],
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(child: _buildSocialButton(imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAAafYMCW42R4Ir9O7BHi3JvBa0-b4i8ntvMeoDxd_CjdUqotP98wc98sfz9HOO_NWZwYwIEqXZhrlYlqtQqcC2mrX_g2DpRa4jMQ9wsGBkUcGbUcQKmkqEuE3cpTRFjh6jzzjxrj2EBswshtifQvSgcmkJVRTdPAAXmfSSW3-CFQcLYn7R02cA_H37uJyKUZyLDoGtE0ww739j3duwQ3g6YEiUh1EEgCRCMbuzkj_6roC6TAJTs56ZZQUhbFYXXnwvDfZ2Bvk3nh8')),
            const SizedBox(width: 16),
            Expanded(child: _buildSocialButton(icon: Icons.apple_rounded)),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton({String? imageUrl, IconData? icon}) {
    return Container(
      height: 60,
      decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(16)),
      child: Center(
        child: imageUrl != null ? Image.network(imageUrl, width: 24, height: 24) : Icon(icon, color: AppColors.onSurface, size: 28),
      ),
    );
  }

  Widget _buildLoginFooter() {
    return Center(
      child: Column(
        children: [
          Text('Already have an account?', style: AppTypography.body.copyWith(color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
            icon: const Icon(Icons.chevron_right, size: 18),
            label: const Text('Login to your sanctuary'),
            style: TextButton.styleFrom(foregroundColor: AppColors.primary, textStyle: AppTypography.label.copyWith(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          ),
        ],
      ),
    );
  }
}
