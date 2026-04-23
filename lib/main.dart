import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/experience_provider.dart';
import 'providers/theme_provider.dart';
import 'theme/app_theme.dart';
import 'widgets/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase con las opciones configuradas
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const BlockchainExperiencesApp());
}

class BlockchainExperiencesApp extends StatelessWidget {
  const BlockchainExperiencesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provider del tema oscuro/claro
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        // Provider de autenticación
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // Provider de experiencias con filtros y paginación
        ChangeNotifierProvider(create: (_) => ExperienceProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Blockchain en la Empresa',
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            // AuthWrapper decide si mostrar Login o Home
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}
