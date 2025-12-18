import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuthException;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../main.dart';
import '../services/firebase_service.dart';
import '../services/user_profile_service.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _isLogin = true;
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  String? _error;
  final _profileService = UserProfileService();

  // Radius used everywhere
  static const double _radius = 18;

  OutlineInputBorder _roundedBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(_radius),
      borderSide: BorderSide(color: color, width: 1.2),
    );
  }

  InputDecoration _inputDecoration(BuildContext context, String label) {
    final cs = Theme.of(context).colorScheme;
    return InputDecoration(
      labelText: label,
      border: _roundedBorder(cs.outline),
      enabledBorder: _roundedBorder(cs.outline),
      focusedBorder: _roundedBorder(cs.primary),
      errorBorder: _roundedBorder(Colors.red),
      focusedErrorBorder: _roundedBorder(Colors.red),
      disabledBorder: _roundedBorder(cs.outlineVariant),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }

  // ✅ Animated sliding toggle (Login/Signup)
  Widget _authSegment(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      height: 46,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_radius),
        border: Border.all(color: cs.outlineVariant),
        color: cs.surface,
      ),
      child: LayoutBuilder(
        builder: (context, c) {
          final half = c.maxWidth / 2;

          return Stack(
            children: [
              AnimatedAlign(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                alignment: _isLogin
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: Container(
                  width: half,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(_radius),
                    color: cs.primary.withValues(alpha: 0.15), // ✅ fixed
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(_radius),
                      onTap: () => setState(() => _isLogin = true),
                      child: Center(
                        child: Text(
                          "Login",
                          style: TextStyle(
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.w600,
                            color: _isLogin ? cs.primary : cs.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(_radius),
                      onTap: () => setState(() => _isLogin = false),
                      child: Center(
                        child: Text(
                          "Signup",
                          style: TextStyle(
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.w600,
                            color: !_isLogin ? cs.primary : cs.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      if (_isLogin) {
        await firebase.auth.signInWithEmailAndPassword(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text.trim(),
        );
        await _profileService.createUserDocIfMissing();
        if (!mounted) return;

        setState(() => _loading = false);

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
        return;
      } else {
        await firebase.auth.createUserWithEmailAndPassword(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text.trim(),
        );
        await _profileService.createUserDocIfMissing();
        if (!mounted) return;

        _emailCtrl.clear();
        _passCtrl.clear();

        setState(() {
          _loading = false;
          _isLogin = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created successfully')),
        );
        return;
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('🔥 FirebaseAuthException: ${e.code} - ${e.message}');
      if (!mounted) return;
      setState(() {
        _error = '${e.code}: ${e.message}';
        _loading = false;
      });
    } catch (e, stackTrace) {
      debugPrint('🔥 Auth Error: $e');
      debugPrint('Stack trace: $stackTrace');
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'images/cafe_logo.svg',
                    width: 72,
                    height: 72,
                    colorFilter: ColorFilter.mode(
                      cs.onSurface,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 20),
                  const Text(
                    'CaffiAI',
                    style: TextStyle(
                      fontFamily: 'MochiyPopPOne',
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 56),

              // Optional: rounded form container
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(_radius),
                  border: Border.all(color: cs.outlineVariant),
                ),
                child: Column(
                  children: [
                    // ✅ Animated toggle here
                    Align(
                      alignment: Alignment.center,
                      child: FractionallySizedBox(
                        widthFactor: 0.5, // half of the available width
                        child: _authSegment(context),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      controller: _emailCtrl,
                      decoration: _inputDecoration(context, 'Email'),
                      style: const TextStyle(fontFamily: 'Inter'),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: _passCtrl,
                      decoration: _inputDecoration(context, 'Password'),
                      style: const TextStyle(fontFamily: 'Inter'),
                      obscureText: true,
                    ),
                    const SizedBox(height: 12),

                    if (_error != null) ...[
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 8),
                    ],

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(_radius),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _loading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                _isLogin ? 'Login' : 'Create account',
                                style: const TextStyle(fontFamily: 'Poppins'),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
