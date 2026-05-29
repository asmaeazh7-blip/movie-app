import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────
//  COLORS
// ─────────────────────────────────────────────
class CineColors {
  static const bg     = Color(0xFF190019);
  static const deep   = Color(0xFF2B124C);
  static const mid    = Color(0xFF522B5B);
  static const muted  = Color(0xFF854F6C);
  static const blush  = Color(0xFFDFB6B2);
  static const cream  = Color(0xFFFBE4D8);
  static const gold   = Color(0xFFC9A76C);
  static const rose   = Color(0xFFAF445A);
  static const wine   = Color(0xFF662549);
}

// ─────────────────────────────────────────────
//  AUTH WRAPPER  (switches Login ↔ Register)
// ─────────────────────────────────────────────
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, this.onDone});
  final VoidCallback? onDone;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  bool _showLogin = true;

  late final AnimationController _switchCtrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _switchCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fade  = CurvedAnimation(parent: _switchCtrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0.08, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _switchCtrl, curve: Curves.easeOut));
    _switchCtrl.forward();
  }

  @override
  void dispose() {
    _switchCtrl.dispose();
    super.dispose();
  }

  void _toggle() {
    _switchCtrl.reverse().then((_) {
      setState(() => _showLogin = !_showLogin);
      _switchCtrl.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CineColors.bg,
      body: Stack(
        children: [
          // background gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF2B124C), Color(0xFF190019), Color(0xFF3C0A2B)],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // decorative blobs
          const _BgBlobs(),

          // content
          SafeArea(
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: _showLogin
                    ? _LoginForm(onSwitch: _toggle, onDone: widget.onDone)
                    : _RegisterForm(onSwitch: _toggle, onDone: widget.onDone),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  LOGIN FORM
// ─────────────────────────────────────────────
class _LoginForm extends StatefulWidget {
  const _LoginForm({this.onSwitch, this.onDone});
  final VoidCallback? onSwitch;
  final VoidCallback? onDone;

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _emailCtrl    = TextEditingController();
  final _passCtrl     = TextEditingController();
  bool _obscure       = true;
  bool _remember      = false;
  bool _loading       = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _submit() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _loading = false);
      widget.onDone?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),

          // logo + title
          Center(child: _CineJoyLogo()),
          const SizedBox(height: 36),

          Text(
            'Log In',
            style: GoogleFonts.caveat(
              fontSize: 42,
              fontWeight: FontWeight.w700,
              color: CineColors.cream,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Welcome back to CineJoy',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: CineColors.blush.withOpacity(0.7),
            ),
          ),

          const SizedBox(height: 32),

          // email field
          _CineField(
            controller: _emailCtrl,
            hint: 'Email',
            icon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
          ),

          const SizedBox(height: 14),

          // password field
          _CineField(
            controller: _passCtrl,
            hint: 'Password',
            icon: Icons.lock_outline_rounded,
            obscure: _obscure,
            suffixIcon: IconButton(
              icon: Icon(
                _obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                color: CineColors.muted,
                size: 20,
              ),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),

          const SizedBox(height: 14),

          // remember + forgot
          Row(
            children: [
              _CineCheckbox(
                value: _remember,
                onChanged: (v) => setState(() => _remember = v ?? false),
                label: 'Remember Me',
              ),
              const Spacer(),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Forgotten Password?',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: CineColors.gold,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // login button
          _CineButton(
            label: 'Log In',
            loading: _loading,
            onTap: _submit,
          ),

          const SizedBox(height: 24),

          // divider
          _OrDivider(label: 'Or Log in with'),

          const SizedBox(height: 20),

          // social buttons
          _SocialButton(
            icon: _googleIcon(),
            label: 'Log In with Google',
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _SocialButton(
            icon: _facebookIcon(),
            label: 'Log In with Facebook',
            onTap: () {},
          ),

          const SizedBox(height: 28),

          // switch to register
          Center(
            child: GestureDetector(
              onTap: widget.onSwitch,
              child: RichText(
                text: TextSpan(
                  style: GoogleFonts.dmSans(
                      fontSize: 14, color: CineColors.blush.withOpacity(0.6)),
                  children: [
                    const TextSpan(text: "Don't have an account? "),
                    TextSpan(
                      text: 'Create Account',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: CineColors.gold,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  REGISTER FORM
// ─────────────────────────────────────────────
class _RegisterForm extends StatefulWidget {
  const _RegisterForm({this.onSwitch, this.onDone});
  final VoidCallback? onSwitch;
  final VoidCallback? onDone;

  @override
  State<_RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<_RegisterForm> {
  final _emailCtrl   = TextEditingController();
  final _passCtrl    = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure1     = true;
  bool _obscure2     = true;
  bool _agreed       = false;
  bool _loading      = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _submit() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _loading = false);
      widget.onDone?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),

          Center(child: _CineJoyLogo()),
          const SizedBox(height: 36),

          Text(
            'Create Account',
            style: GoogleFonts.caveat(
              fontSize: 42,
              fontWeight: FontWeight.w700,
              color: CineColors.cream,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Join CineJoy and start watching',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: CineColors.blush.withOpacity(0.7),
            ),
          ),

          const SizedBox(height: 32),

          _CineField(
            controller: _emailCtrl,
            hint: 'Email',
            icon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 14),

          _CineField(
            controller: _passCtrl,
            hint: 'Password',
            icon: Icons.lock_outline_rounded,
            obscure: _obscure1,
            suffixIcon: IconButton(
              icon: Icon(
                _obscure1 ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                color: CineColors.muted, size: 20,
              ),
              onPressed: () => setState(() => _obscure1 = !_obscure1),
            ),
          ),
          const SizedBox(height: 14),

          _CineField(
            controller: _confirmCtrl,
            hint: 'Confirm Password',
            icon: Icons.lock_outline_rounded,
            obscure: _obscure2,
            suffixIcon: IconButton(
              icon: Icon(
                _obscure2 ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                color: CineColors.muted, size: 20,
              ),
              onPressed: () => setState(() => _obscure2 = !_obscure2),
            ),
          ),

          const SizedBox(height: 16),

          // terms checkbox
          _CineCheckbox(
            value: _agreed,
            onChanged: (v) => setState(() => _agreed = v ?? false),
            label: 'I agree to the ',
            labelSuffix: 'Terms of Service',
            onSuffixTap: () {},
          ),

          const SizedBox(height: 24),

          _CineButton(
            label: 'Create Account',
            loading: _loading,
            onTap: _agreed ? _submit : null,
          ),

          const SizedBox(height: 24),

          _OrDivider(label: 'Or Create with'),

          const SizedBox(height: 20),

          _SocialButton(
            icon: _googleIcon(),
            label: 'Log In with Google',
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _SocialButton(
            icon: _facebookIcon(),
            label: 'Log In with Facebook',
            onTap: () {},
          ),

          const SizedBox(height: 28),

          Center(
            child: GestureDetector(
              onTap: widget.onSwitch,
              child: RichText(
                text: TextSpan(
                  style: GoogleFonts.dmSans(
                      fontSize: 14, color: CineColors.blush.withOpacity(0.6)),
                  children: [
                    const TextSpan(text: 'Do you have an account? '),
                    TextSpan(
                      text: 'Log In',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: CineColors.gold,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  SHARED WIDGETS
// ─────────────────────────────────────────────

class _CineJoyLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 42, height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [CineColors.gold, CineColors.rose],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: CineColors.gold.withOpacity(0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(Icons.movie_filter_rounded,
              color: Colors.white, size: 22),
        ),
        const SizedBox(width: 10),
        Text(
          'CineJoy',
          style: GoogleFonts.caveat(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            color: CineColors.cream,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}

class _CineField extends StatelessWidget {
  const _CineField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.keyboardType,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CineColors.deep.withOpacity(0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: CineColors.mid.withOpacity(0.5),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        style: GoogleFonts.dmSans(
          color: CineColors.cream,
          fontSize: 14.5,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.dmSans(
            color: CineColors.muted.withOpacity(0.6),
            fontSize: 14,
          ),
          prefixIcon: Icon(icon, color: CineColors.muted, size: 20),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}

class _CineButton extends StatelessWidget {
  const _CineButton({
    required this.label,
    required this.onTap,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null && !loading;
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedOpacity(
        opacity: enabled ? 1.0 : 0.5,
        duration: const Duration(milliseconds: 300),
        child: Container(
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [CineColors.rose, CineColors.wine],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(27),
            boxShadow: [
              BoxShadow(
                color: CineColors.rose.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    label,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: CineColors.cream,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: CineColors.mid.withOpacity(0.4),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: CineColors.muted.withOpacity(0.7),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: CineColors.mid.withOpacity(0.4),
          ),
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final Widget icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: CineColors.deep.withOpacity(0.5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: CineColors.mid.withOpacity(0.4),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: CineColors.blush.withOpacity(0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CineCheckbox extends StatelessWidget {
  const _CineCheckbox({
    required this.value,
    required this.onChanged,
    required this.label,
    this.labelSuffix,
    this.onSuffixTap,
  });
  final bool value;
  final ValueChanged<bool?> onChanged;
  final String label;
  final String? labelSuffix;
  final VoidCallback? onSuffixTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: value ? CineColors.rose : Colors.transparent,
              border: Border.all(
                color: value ? CineColors.rose : CineColors.muted.withOpacity(0.5),
                width: 1.5,
              ),
            ),
            child: value
                ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 8),
          RichText(
            text: TextSpan(
              style: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: CineColors.blush.withOpacity(0.7)),
              children: [
                TextSpan(text: label),
                if (labelSuffix != null)
                  TextSpan(
                    text: labelSuffix,
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: CineColors.gold,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  BACKGROUND BLOBS
// ─────────────────────────────────────────────
class _BgBlobs extends StatelessWidget {
  const _BgBlobs();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -100, right: -80,
          child: Container(
            width: 300, height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  CineColors.mid.withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -80, left: -60,
          child: Container(
            width: 260, height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  CineColors.rose.withOpacity(0.2),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 200, left: -40,
          child: Container(
            width: 160, height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  CineColors.gold.withOpacity(0.07),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  SOCIAL ICONS (inline SVG-style)
// ─────────────────────────────────────────────
Widget _googleIcon() => Container(
      width: 22, height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4),
        ],
      ),
      child: Center(
        child: Text(
          'G',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF4285F4),
            fontFamily: 'Arial',
          ),
        ),
      ),
    );

Widget _facebookIcon() => Container(
      width: 22, height: 22,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF1877F2),
      ),
      child: const Center(
        child: Text(
          'f',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            fontFamily: 'Arial',
          ),
        ),
      ),
    );