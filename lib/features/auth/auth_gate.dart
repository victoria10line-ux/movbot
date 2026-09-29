import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../dashboard/dashboard_page.dart';
import '../../core/widgets/app_shell.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  @override
  Widget build(BuildContext context) {
    final client = Supabase.instance.client;
    return StreamBuilder<AuthState>(
      stream: client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (client.auth.currentSession != null) return const AppShell();
        return const LoginPage();
      },
    );
  }
}

class LoginPage extends StatefulWidget { const LoginPage({super.key}); @override State<LoginPage> createState() => _LoginPageState(); }
class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool busy = false;
  String? error;
  Future<void> signIn() async {
    setState(() { busy = true; error = null; });
    try { await Supabase.instance.client.auth.signInWithPassword(email: email.text.trim(), password: password.text); }
    on AuthException catch (e) { setState(() => error = e.message); }
    catch (_) { setState(() => error = 'تعذر تسجيل الدخول. تحقق من الاتصال والبيانات.'); }
    finally { if (mounted) setState(() => busy = false); }
  }
  @override Widget build(BuildContext context) => Scaffold(body: SafeArea(child: Center(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 430), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Container(width: 62, height: 62, decoration: BoxDecoration(color: AppColors.orange.withValues(alpha: .14), borderRadius: BorderRadius.circular(20)), child: const Icon(Icons.local_shipping_rounded, color: AppColors.orange, size: 30)),
    const SizedBox(height: 28), const Text('Movbot', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900)), const SizedBox(height: 6), const Text('إدارة النقل والأسطول في مكان واحد', style: TextStyle(color: AppColors.muted)), const SizedBox(height: 32),
    TextField(controller: email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'البريد الإلكتروني', prefixIcon: Icon(Icons.email_outlined))), const SizedBox(height: 14),
    TextField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: 'كلمة المرور', prefixIcon: Icon(Icons.lock_outline))), const SizedBox(height: 18),
    if (error != null) Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(error!, style: const TextStyle(color: AppColors.red))),
    SizedBox(width: double.infinity, height: 52, child: FilledButton(onPressed: busy ? null : signIn, child: busy ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('تسجيل الدخول'))),
  ]))))));
  @override void dispose() { email.dispose(); password.dispose(); super.dispose(); }
}
