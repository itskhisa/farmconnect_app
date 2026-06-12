import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/theme.dart';
import '../utils/storage.dart';

class AuthService {
  static Future<String?> changePassword(String phone, String oldPass, String newPass) =>
      StorageService.instance.changeUserPassword(oldPass, newPass);
}

class AuthScreen extends StatefulWidget {
  final VoidCallback onAuth;
  const AuthScreen({super.key, required this.onAuth});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  bool _obscureLogin = true;
  bool _obscureReg   = true;
  bool _obscureReg2  = true;
  bool _rememberMe   = false;
  bool _loading      = false;
  String? _error;

  final _loginPhoneCtrl = TextEditingController();
  final _loginPassCtrl  = TextEditingController();
  final _regNameCtrl    = TextEditingController();
  final _regPhoneCtrl   = TextEditingController();
  final _regPassCtrl    = TextEditingController();
  final _regPass2Ctrl   = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    StorageService.instance.runGracePeriodCleanup();
    final savedPhone = StorageService.instance.getSavedPhone();
    if (savedPhone != null) {
      _loginPhoneCtrl.text = savedPhone;
      _rememberMe = true;
    }
  }

  Future<void> _login() async {
    if (_loading) return;
    final phone = _loginPhoneCtrl.text.trim();
    final pass  = _loginPassCtrl.text;
    if (phone.isEmpty || pass.isEmpty) {
      setState(() => _error = 'Enter your phone number and password.');
      return;
    }
    setState(() { _loading = true; _error = null; });
    final err = await StorageService.instance.loginUser(phone, pass);
    if (!mounted) return;
    if (err != null) {
      setState(() { _error = err; _loading = false; });
      return;
    }
    if (_rememberMe) {
      await StorageService.instance.savePassword(phone, pass);
    } else {
      await StorageService.instance.clearSavedPassword();
    }
    widget.onAuth();
  }

  Future<void> _register() async {
    if (_loading) return;
    final name  = _regNameCtrl.text.trim();
    final phone = _regPhoneCtrl.text.trim();
    final pass  = _regPassCtrl.text;
    final pass2 = _regPass2Ctrl.text;
    if (name.isEmpty || phone.isEmpty || pass.isEmpty) {
      setState(() => _error = 'Fill in all fields.');
      return;
    }
    if (pass != pass2) {
      setState(() => _error = 'Passwords do not match.');
      return;
    }
    if (pass.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters.');
      return;
    }
    setState(() { _loading = true; _error = null; });
    final err = await StorageService.instance.registerUser(phone, name, pass);
    if (!mounted) return;
    if (err != null) {
      setState(() { _error = err; _loading = false; });
      return;
    }
    await StorageService.instance.loginUser(phone, pass);
    widget.onAuth();
  }

  @override
  void dispose() {
    _tabs.dispose();
    for (final c in [_loginPhoneCtrl, _loginPassCtrl,
        _regNameCtrl, _regPhoneCtrl, _regPassCtrl, _regPass2Ctrl]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark     = Theme.of(context).brightness == Brightness.dark;
    final cardColor  = Theme.of(context).cardColor;
    final border     = Theme.of(context).dividerColor;
    final textColor  = Theme.of(context).textTheme.bodyLarge?.color ?? kText;
    final mutedColor = isDark ? const Color(0xFF7A9A7C) : const Color(0xFF6B7280);
    final inputFill  = isDark ? const Color(0xFF152017) : Colors.white;
    final errorBg    = isDark ? const Color(0xFF3A1010) : const Color(0xFFFEF2F2);
    final errorBorder= isDark ? const Color(0xFF8B2020) : const Color(0xFFFCA5A5);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
          child: Column(children: [
            Container(
              width: 90, height: 90,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [kGreenDark, kGreen],
                  begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(
                  color: kGreen.withOpacity(0.4),
                  blurRadius: 20, offset: const Offset(0, 8))],
              ),
              child: const Center(child: Text('🌱', style: TextStyle(fontSize: 44))),
            ),
            const SizedBox(height: 18),
            Text('FarmConnect',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 30, fontWeight: FontWeight.w900, color: kGreen)),
            Text('Smart farming for Kenyan farmers',
                style: GoogleFonts.plusJakartaSans(fontSize: 13, color: mutedColor)),
            const SizedBox(height: 32),

            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: border),
                boxShadow: isDark ? null : [BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: TabBar(
                controller: _tabs,
                indicator: BoxDecoration(color: kGreen, borderRadius: BorderRadius.circular(12)),
                labelColor: Colors.white,
                unselectedLabelColor: mutedColor,
                labelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14),
                unselectedLabelStyle: GoogleFonts.plusJakartaSans(fontSize: 14),
                dividerHeight: 0,
                tabs: const [Tab(text: 'Sign In'), Tab(text: 'Create Account')],
                onTap: (_) => setState(() => _error = null),
              ),
            ),
            const SizedBox(height: 20),

            if (_error != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: errorBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: errorBorder),
                ),
                child: Row(children: [
                  const Icon(Icons.error_outline, color: kRed, size: 16),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_error!,
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, color: kRed))),
                ]),
              ),

            SizedBox(
              height: 360,
              child: TabBarView(
                controller: _tabs,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  // LOGIN
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _field(context, 'Phone Number', _loginPhoneCtrl,
                        hint: 'e.g. 0712345678', icon: Icons.phone_outlined,
                        keyboard: TextInputType.phone,
                        inputFill: inputFill, mutedColor: mutedColor),
                    const SizedBox(height: 12),
                    _field(context, 'Password', _loginPassCtrl,
                        hint: 'Enter your password', icon: Icons.lock_outline,
                        obscure: _obscureLogin,
                        toggleObscure: () => setState(() => _obscureLogin = !_obscureLogin),
                        inputFill: inputFill, mutedColor: mutedColor),
                    const SizedBox(height: 10),
                    Row(children: [
                      SizedBox(
                        width: 24, height: 24,
                        child: Checkbox(
                          value: _rememberMe,
                          onChanged: (v) => setState(() => _rememberMe = v!),
                          activeColor: kGreen,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: GestureDetector(
                        onTap: () => setState(() => _rememberMe = !_rememberMe),
                        child: Text('Remember my password on this device',
                            style: GoogleFonts.plusJakartaSans(fontSize: 12, color: textColor)),
                      )),
                    ]),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity, height: 52,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kGreen,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 2,
                        ),
                        child: _loading
                            ? const SizedBox(width: 22, height: 22,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text('Sign In',
                                style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                      ),
                    ),
                  ]),

                  // REGISTER
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _field(context, 'Full Name', _regNameCtrl,
                        hint: 'e.g. John Kamau', icon: Icons.person_outline,
                        inputFill: inputFill, mutedColor: mutedColor),
                    const SizedBox(height: 10),
                    _field(context, 'Phone Number', _regPhoneCtrl,
                        hint: 'e.g. 0712345678', icon: Icons.phone_outlined,
                        keyboard: TextInputType.phone,
                        inputFill: inputFill, mutedColor: mutedColor),
                    const SizedBox(height: 10),
                    _field(context, 'Password', _regPassCtrl,
                        hint: 'At least 6 characters', icon: Icons.lock_outline,
                        obscure: _obscureReg,
                        toggleObscure: () => setState(() => _obscureReg = !_obscureReg),
                        inputFill: inputFill, mutedColor: mutedColor),
                    const SizedBox(height: 10),
                    _field(context, 'Confirm Password', _regPass2Ctrl,
                        hint: 'Repeat your password', icon: Icons.lock_outline,
                        obscure: _obscureReg2,
                        toggleObscure: () => setState(() => _obscureReg2 = !_obscureReg2),
                        inputFill: inputFill, mutedColor: mutedColor),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity, height: 52,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kGreen,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 2,
                        ),
                        child: _loading
                            ? const SizedBox(width: 22, height: 22,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text('Create Account',
                                style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _field(BuildContext context, String label, TextEditingController ctrl, {
    String? hint, IconData? icon, bool obscure = false,
    VoidCallback? toggleObscure, TextInputType? keyboard,
    required Color inputFill, required Color mutedColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? const Color(0xFF2A4A2D) : const Color(0xFFE5E7EB);
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      keyboardType: keyboard,
      style: GoogleFonts.plusJakartaSans(fontSize: 14),
      onSubmitted: (_) { if (_tabs.index == 0) _login(); else _register(); },
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon, size: 18, color: mutedColor) : null,
        suffixIcon: toggleObscure != null
            ? IconButton(
                icon: Icon(
                  obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  size: 18, color: mutedColor),
                onPressed: toggleObscure)
            : null,
        filled: true,
        fillColor: inputFill,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: borderColor)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: borderColor)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kGreen, width: 2)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: mutedColor),
      ),
    );
  }
}
