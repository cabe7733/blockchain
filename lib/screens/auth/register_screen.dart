import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/validators.dart';
import '../../widgets/gradient_button.dart';

/// Pantalla de registro de nuevo usuario.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl     = TextEditingController();
  final _companyCtrl  = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _passCtrl     = TextEditingController();
  final _confirmCtrl  = TextEditingController();

  bool _obscurePass    = true;
  bool _obscureConfirm = true;
  bool _isLoading      = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _companyCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _errorMessage = null; });

    try {
      await context.read<AuthProvider>().register(
        name: _nameCtrl.text,
        company: _companyCtrl.text,
        email: _emailCtrl.text,
        password: _passCtrl.text,
      );
      // AuthWrapper redirige automáticamente al Home
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: _buildCard(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard() {
    return Container(
      padding: const EdgeInsets.all(36),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // ── Ícono ────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppTheme.buttonGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_add_outlined,
                  color: AppTheme.white, size: 32),
            ),
            const SizedBox(height: 16),
            const Text(
              'Crear Cuenta',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Completa los datos para registrarte',
              style: TextStyle(fontSize: 13, color: AppTheme.textGray),
            ),
            const SizedBox(height: 24),

            // ── Nombre ───────────────────────────────────
            TextFormField(
              controller: _nameCtrl,
              validator: Validators.name,
              decoration: const InputDecoration(
                labelText: 'Nombre completo',
                prefixIcon: Icon(Icons.badge_outlined,
                    color: AppTheme.primaryBlue),
              ),
            ),
            const SizedBox(height: 14),

            // ── Empresa ──────────────────────────────────
            TextFormField(
              controller: _companyCtrl,
              validator: (v) => Validators.required(v, 'La empresa'),
              decoration: const InputDecoration(
                labelText: 'Empresa / Organización',
                prefixIcon: Icon(Icons.business_outlined,
                    color: AppTheme.primaryBlue),
              ),
            ),
            const SizedBox(height: 14),

            // ── Email ────────────────────────────────────
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              validator: Validators.email,
              decoration: const InputDecoration(
                labelText: 'Correo electrónico',
                prefixIcon: Icon(Icons.email_outlined,
                    color: AppTheme.primaryBlue),
              ),
            ),
            const SizedBox(height: 14),

            // ── Contraseña ───────────────────────────────
            TextFormField(
              controller: _passCtrl,
              obscureText: _obscurePass,
              validator: Validators.password,
              decoration: InputDecoration(
                labelText: 'Contraseña (mín. 6 caracteres)',
                prefixIcon: const Icon(Icons.lock_outlined,
                    color: AppTheme.primaryBlue),
                suffixIcon: IconButton(
                  onPressed: () =>
                      setState(() => _obscurePass = !_obscurePass),
                  icon: Icon(
                    _obscurePass
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppTheme.textGray,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // ── Confirmar contraseña ─────────────────────
            TextFormField(
              controller: _confirmCtrl,
              obscureText: _obscureConfirm,
              validator: (v) =>
                  Validators.confirmPassword(v, _passCtrl.text),
              decoration: InputDecoration(
                labelText: 'Confirmar contraseña',
                prefixIcon: const Icon(Icons.lock_reset_outlined,
                    color: AppTheme.primaryBlue),
                suffixIcon: IconButton(
                  onPressed: () => setState(
                      () => _obscureConfirm = !_obscureConfirm),
                  icon: Icon(
                    _obscureConfirm
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppTheme.textGray,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Error ─────────────────────────────────────
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.errorRed.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: AppTheme.errorRed.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline,
                        color: AppTheme.errorRed, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_errorMessage!,
                          style: const TextStyle(
                              color: AppTheme.errorRed, fontSize: 13)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],

            // ── Botón registrarse ─────────────────────────
            GradientButton(
              label: 'Crear Cuenta',
              icon: Icons.check_circle_outline,
              onPressed: _register,
              isLoading: _isLoading,
              width: double.infinity,
            ),
            const SizedBox(height: 18),

            // ── Link a login ─────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('¿Ya tienes cuenta? ',
                    style:
                        TextStyle(fontSize: 13, color: AppTheme.textGray)),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Text(
                    'Inicia sesión',
                    style: TextStyle(
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
