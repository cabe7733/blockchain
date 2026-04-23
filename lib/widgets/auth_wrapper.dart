import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/home_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  String? _loadedUid;

  // Dispara loadUserData una sola vez por UID, fuera del frame actual
  void _loadIfNeeded(String uid) {
    if (_loadedUid == uid) return;
    _loadedUid = uid;
    Future.microtask(() {
      if (mounted) context.read<AuthProvider>().loadUserData(uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: context.read<AuthProvider>().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _Splash(message: 'Iniciando...');
        }

        final user = snapshot.data;

        if (user != null) {
          _loadIfNeeded(user.uid); // seguro: no llama notifyListeners aquí

          final auth = context.watch<AuthProvider>();
          if (auth.isLoadingUser || auth.userModel == null) {
            return const _Splash(message: 'Cargando perfil...');
          }
          return const HomeScreen();
        }

        _loadedUid = null;
        return const LoginScreen();
      },
    );
  }
}

class _Splash extends StatelessWidget {
  final String message;
  const _Splash({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2563EB), Color(0xFF1D4ED8), Color(0xFF7C3AED)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Colors.white),
              const SizedBox(height: 20),
              Text(message,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}