import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sanpo/providers.dart';
import '../../services/auth_service.dart';

class SignUpPage extends HookConsumerWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.watch(authServiceProvider);
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final errorMessage = useState<String?>(null);
    final nameController = useTextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (errorMessage.value != null)
              Text(
                errorMessage.value!,
                style: const TextStyle(color: Colors.red),
              ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text;
                final email = emailController.text;
                final password = passwordController.text;
                try {
                  await authService.signUpWithEmailAndPassword(
                      email, password, name);
                  errorMessage.value = null;
                  Navigator.pop(context); // サインアップ成功時にログインページに戻る
                } catch (e) {
                  errorMessage.value = e.toString();
                }
              },
              child: const Text('Sign Up'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Go to Login'),
            ),
          ],
        ),
      ),
    );
  }
}
