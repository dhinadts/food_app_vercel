import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool isLogin = true;
  bool loading = false;

  void toggle() => setState(() => isLogin = !isLogin);

  Future<void> submit() async {
    setState(() => loading = true);
    try {
      if (isLogin) {
        await AuthService().signIn(emailCtrl.text.trim(), passCtrl.text);
      } else {
        await AuthService().signUp(emailCtrl.text.trim(), passCtrl.text);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> googleSignIn() async {
    setState(() => loading = true);
    try {
      await AuthService().signInWithGoogle();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Food — Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
          TextField(controller: passCtrl, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: submit, child: loading ? const CircularProgressIndicator(color: Colors.white) : Text(isLogin ? 'Sign in' : 'Sign up')),
          TextButton(onPressed: toggle, child: Text(isLogin ? 'Create account' : 'Have an account? Sign in')),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: googleSignIn, child: const Text('Sign in with Google')),
        ]),
      ),
    );
  }
}
