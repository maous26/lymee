import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lym_nutrition/presentation/themes/fresh_theme.dart';

import 'package:lym_nutrition/presentation/screens/auth/login_screen.dart';
import 'package:lym_nutrition/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:lym_nutrition/presentation/bloc/auth/auth_bloc.dart';
import 'package:lym_nutrition/presentation/bloc/auth/auth_event.dart';
import 'package:lym_nutrition/presentation/bloc/auth/auth_state.dart';
import 'package:lym_nutrition/injection_container.dart' as di;

class SignupScreen extends StatelessWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<AuthBloc>(),
      child: const _SignupScreenContent(),
    );
  }
}

class _SignupScreenContent extends StatefulWidget {
  const _SignupScreenContent({Key? key}) : super(key: key);

  @override
  State<_SignupScreenContent> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<_SignupScreenContent>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;
  bool _isLoading = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (_formKey.currentState!.validate() && _acceptTerms) {
      context.read<AuthBloc>().add(
            SignUpRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text,
              displayName: _nameController.text.trim(),
            ),
          );
    } else if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              const Text('Veuillez accepter les conditions d\'utilisation'),
          backgroundColor: FreshTheme.accentCoral,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSignUpLoading) {
          setState(() {
            _isLoading = true;
          });
        } else if (state is AuthSignUpSuccess || state is AuthAuthenticated) {
          setState(() {
            _isLoading = false;
          });
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const OnboardingScreen()),
          );
        } else if (state is AuthSignUpFailure) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: FreshTheme.accentCoral,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: FreshTheme.cloudWhite,
        body: Container(
          height: size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                FreshTheme.primaryMint.withValues(alpha: 0.05),
                FreshTheme.serenityBlue.withValues(alpha: 0.05),
              ],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        // Back button
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back_rounded,
                            color: FreshTheme.midnightGray,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(height: 40),
                        // Logo and Title
                        Center(
                          child: Column(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      FreshTheme.primaryMint,
                                      FreshTheme.serenityBlue
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: FreshTheme.primaryMint
                                          .withValues(alpha: 0.3),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.restaurant_rounded,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Créer un compte',
                                style: Theme.of(context)
                                    .textTheme
                                    .displayLarge
                                    ?.copyWith(
                                      fontSize: 28,
                                      color: FreshTheme.midnightGray,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Commencez votre voyage vers une meilleure santé',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      color: FreshTheme.stormGray,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 48),
                        // Signup Form
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    FreshTheme.stormGray.withValues(alpha: 0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Name field
                                Text(
                                  'Nom complet',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        fontSize: 14,
                                        color: FreshTheme.midnightGray,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _nameController,
                                  keyboardType: TextInputType.name,
                                  decoration: InputDecoration(
                                    hintText: 'Jean Dupont',
                                    prefixIcon: Icon(
                                      Icons.person_outline,
                                      color: FreshTheme.stormGray,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Veuillez entrer votre nom';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),
                                // Email field
                                Text(
                                  'Email',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        fontSize: 14,
                                        color: FreshTheme.midnightGray,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    hintText: 'votre@email.com',
                                    prefixIcon: Icon(
                                      Icons.email_outlined,
                                      color: FreshTheme.stormGray,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Veuillez entrer votre email';
                                    }
                                    if (!RegExp(
                                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                        .hasMatch(value)) {
                                      return 'Veuillez entrer un email valide';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),
                                // Password field
                                Text(
                                  'Mot de passe',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        fontSize: 14,
                                        color: FreshTheme.midnightGray,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  decoration: InputDecoration(
                                    hintText: '••••••••',
                                    prefixIcon: Icon(
                                      Icons.lock_outline,
                                      color: FreshTheme.stormGray,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        color: FreshTheme.stormGray,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Veuillez entrer un mot de passe';
                                    }
                                    if (value.length < 8) {
                                      return 'Le mot de passe doit contenir au moins 8 caractères';
                                    }
                                    if (!RegExp(
                                            r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)')
                                        .hasMatch(value)) {
                                      return 'Le mot de passe doit contenir majuscules, minuscules et chiffres';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Minimum 8 caractères avec majuscules, minuscules et chiffres',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        color: FreshTheme.stormGray,
                                        fontSize: 12,
                                      ),
                                ),
                                const SizedBox(height: 20),
                                // Confirm Password field
                                Text(
                                  'Confirmer le mot de passe',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        fontSize: 14,
                                        color: FreshTheme.midnightGray,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _confirmPasswordController,
                                  obscureText: _obscureConfirmPassword,
                                  decoration: InputDecoration(
                                    hintText: '••••••••',
                                    prefixIcon: Icon(
                                      Icons.lock_outline,
                                      color: FreshTheme.stormGray,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureConfirmPassword
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        color: FreshTheme.stormGray,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscureConfirmPassword =
                                              !_obscureConfirmPassword;
                                        });
                                      },
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Veuillez confirmer votre mot de passe';
                                    }
                                    if (value != _passwordController.text) {
                                      return 'Les mots de passe ne correspondent pas';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 24),
                                // Terms checkbox
                                Row(
                                  children: [
                                    SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: Checkbox(
                                        value: _acceptTerms,
                                        onChanged: (value) {
                                          setState(() {
                                            _acceptTerms = value ?? false;
                                          });
                                        },
                                        activeColor: FreshTheme.primaryMint,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: RichText(
                                        text: TextSpan(
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.copyWith(
                                                color: FreshTheme.stormGray,
                                                fontSize: 12,
                                              ),
                                          children: [
                                            const TextSpan(
                                                text: 'J\'accepte les '),
                                            TextSpan(
                                              text: 'conditions d\'utilisation',
                                              style: TextStyle(
                                                color: FreshTheme.primaryMint,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const TextSpan(text: ' et la '),
                                            TextSpan(
                                              text:
                                                  'politique de confidentialité',
                                              style: TextStyle(
                                                color: FreshTheme.primaryMint,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 32),
                                // Signup button
                                SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed:
                                        _isLoading ? null : _handleSignup,
                                    child: _isLoading
                                        ? const SizedBox(
                                            height: 24,
                                            width: 24,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2.5,
                                            ),
                                          )
                                        : const Text('Créer mon compte'),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                // Or divider
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        height: 1,
                                        color: FreshTheme.mistGray,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      child: Text(
                                        'OU',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                              color: FreshTheme.stormGray,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                            ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        height: 1,
                                        color: FreshTheme.mistGray,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                // Social signup buttons
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildSocialButton(
                                        icon: Icons.g_mobiledata_rounded,
                                        label: 'Google',
                                        onPressed: () {
                                          // TODO: Implement Google signup
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildSocialButton(
                                        icon: Icons.apple_rounded,
                                        label: 'Apple',
                                        onPressed: () {
                                          // TODO: Implement Apple signup
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Login link
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Déjà un compte ? ',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      color: FreshTheme.stormGray,
                                    ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const LoginScreen(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Se connecter',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        color: FreshTheme.primaryMint,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        side: BorderSide(
          color: FreshTheme.mistGray,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: FreshTheme.midnightGray,
            size: 24,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: FreshTheme.midnightGray,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
