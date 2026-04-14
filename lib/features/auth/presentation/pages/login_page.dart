import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/design_tokens.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both email and password')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/main');
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
          // 1. Asymmetric Background Decorations
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha:0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary.withValues(alpha:0.05),
              ),
            ),
          ),
          
          // 2. Main content...
          SafeArea(
            child: Column(
              children: [
                _buildStickyHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          _buildBrandingSection(),
                          const SizedBox(height: 40),
                          _buildLoginCard(context),
                          const SizedBox(height: 32),
                          _buildRegisterFooter(),
                        ],
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

  Widget _buildStickyHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.surface,
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.onSurface, size: 24),
          ),
          const SizedBox(width: 12),
          Text(
            'Welcome Back',
            style: AppTypography.display.copyWith(
              color: AppColors.primaryContainer,
              fontSize: 24,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandingSection() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(16)),
          child: const Icon(Icons.mosque, size: 40, color: AppColors.primary),
        ),
        const SizedBox(height: 16),
        Text('Bayt Al-Noor', style: AppTypography.headline.copyWith(color: AppColors.primary, fontSize: 32, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('Return to your digital sanctuary.', style: AppTypography.body.copyWith(color: AppColors.onSurfaceVariant, fontSize: 15)),
      ],
    );
  }

  Widget _buildLoginCard(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha:0.7),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha:0.2)),
            boxShadow: [
              BoxShadow(color: AppColors.primary.withValues(alpha:0.05), blurRadius: 40, offset: const Offset(0, 20)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInputLabel('Email'),
              const SizedBox(height: 8),
              _buildCustomTextField(
                controller: _emailController,
                hintText: 'Enter your email',
                icon: Icons.alternate_email,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInputLabel('Password'),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/forgot-password'),
                    child: Text('Forgot Password?', style: AppTypography.label.copyWith(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildCustomTextField(
                controller: _passwordController,
                hintText: '••••••••',
                icon: Icons.lock_outline,
                isPassword: true,
                obscureText: !_isPasswordVisible,
                onToggleVisibility: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
              ),
              const SizedBox(height: 32),
              GestureDetector(
                onTap: _isLoading ? null : _handleLogin,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryContainer]),
                  ),
                  child: _isLoading 
                    ? const Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)))
                    : Center(child: Text('Login', style: AppTypography.label.copyWith(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
                ),
              ),
              const SizedBox(height: 32),
              _buildSocialSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Text(label, style: AppTypography.label.copyWith(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant));
  }

  Widget _buildCustomTextField({required TextEditingController controller, required String hintText, required IconData icon, bool isPassword = false, bool obscureText = false, VoidCallback? onToggleVisibility}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTypography.body.copyWith(color: AppColors.outline.withValues(alpha:0.5), fontSize: 14),
        fillColor: AppColors.surfaceContainerHighest,
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        prefixIcon: Icon(icon, color: AppColors.outline, size: 20),
        suffixIcon: isPassword ? IconButton(icon: Icon(obscureText ? Icons.visibility : Icons.visibility_off, color: AppColors.outline, size: 20), onPressed: onToggleVisibility) : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
    );
  }

  Widget _buildSocialSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: AppColors.outlineVariant.withValues(alpha:0.2))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('OR', style: AppTypography.label.copyWith(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.outline, letterSpacing: 2)),
            ),
            Expanded(child: Divider(color: AppColors.outlineVariant.withValues(alpha:0.2))),
          ],
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(child: _buildSocialButton(imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBG6Ik9fQu7tEzQMuO1Kr98je4eDCl-Oa4LhbWe-bt8Cipc6bo17sK_ZHRw5eBBBOa6bKSlKF0mwwtD5ehY5jG1UnNeGOghiF8ZN6jgFr7zY-RCrr21-QJ_xiRy3rhRICqv_1osTAoEAWHaFXIItr9twaInb1eHHl4o8aUsnh5zYu_MV8WRbCzaMeiSKbdu0XpJYJEjr5jzpvXIaf2egxjx7t5TZDow7lQLc38c5fwYzfF4pTcisLSYlXlTRe1UtYuNpD5YOkmlDx0')),
            const SizedBox(width: 12),
            Expanded(child: _buildSocialButton(imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAU8JGLBT797vSApi-zOpxpK88tP3EMccvFpMnboYMAwVB9l_HpUbczAgBIh35jurEz0CJOT2JmPA4uqowNSvIuYLDkooqfaVrCfNHyqdq04N6LdSw5-aydvHzRsGQH2Liefo3aAD0WhlfaXRwhdFo84Vj7ik_Yc6JfpyhudbBRlI419z-xTdzIUKt0NyRV_puRDHUaGlL3Aw4TCjbxLBqq7llhDEuWNnXc_cbBv3r5f31EJaiYRczPZlbjsMtKy9pzF8gMM4fUGq0')),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton({required String imageUrl}) {
    return Container(
      height: 56,
      decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(12)),
      child: Center(child: Image.network(imageUrl, width: 24, height: 24)),
    );
  }

  Widget _buildRegisterFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Don't have an account? ", style: AppTypography.body.copyWith(color: AppColors.onSurfaceVariant, fontSize: 14)),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/register'),
          child: Text('Register', style: AppTypography.body.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14)),
        ),
      ],
    );
  }
}
