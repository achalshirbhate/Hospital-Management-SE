import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey  = GlobalKey<FormState>();
  final _name     = TextEditingController();
  final _email    = TextEditingController();
  final _password = TextEditingController();

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.register(_name.text.trim(), _email.text.trim(), _password.text.trim());
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registered! Please login.'), backgroundColor: Colors.green));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(children: [
            const SizedBox(height: 16),
            AppTextField(label: 'Full Name', controller: _name, prefixIcon: Icons.person_outline,
              validator: (v) => v!.isEmpty ? 'Enter name' : null),
            const SizedBox(height: 14),
            AppTextField(label: 'Email', controller: _email, keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email_outlined, validator: (v) => v!.isEmpty ? 'Enter email' : null),
            const SizedBox(height: 14),
            AppTextField(label: 'Password', controller: _password, obscure: true,
              prefixIcon: Icons.lock_outline, validator: (v) => v!.length < 4 ? 'Min 4 chars' : null),
            const SizedBox(height: 24),
            Consumer<AuthProvider>(builder: (_, auth, __) {
              if (auth.error != null) return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(auth.error!, style: const TextStyle(color: Colors.red, fontSize: 13)));
              return const SizedBox.shrink();
            }),
            Consumer<AuthProvider>(builder: (_, auth, __) =>
              AppButton(label: 'Register', loading: auth.loading, onPressed: _register)),
          ]),
        ),
      ),
    );
  }
}
