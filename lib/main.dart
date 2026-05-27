import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show PlatformDispatcher;
import 'package:flutter_localizations/flutter_localizations.dart';
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

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('=== FlutterError ===\n${details.exception}\n${details.stack}');
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('=== PlatformDispatcher Error ===\n$error\n$stack');
    return true;
  };

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e, stack) {
    debugPrint('Firebase init error: $e\n$stack');
    runApp(const FirebaseInitErrorApp());
    return;
  }

  runApp(const BlockchainExperiencesApp());
}

class FirebaseInitErrorApp extends StatelessWidget {
  const FirebaseInitErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Error de conexión con Firebase',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Verifica tu conexión a internet e intenta de nuevo.'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => main(),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BlockchainExperiencesApp extends StatelessWidget {
  const BlockchainExperiencesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ExperienceProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          final data = MediaQuery.of(context);
          return MediaQuery(
            data: data.copyWith(
              viewInsets: EdgeInsets.fromLTRB(
                data.viewInsets.left.clamp(0, double.infinity),
                data.viewInsets.top.clamp(0, double.infinity),
                data.viewInsets.right.clamp(0, double.infinity),
                data.viewInsets.bottom.clamp(0, double.infinity),
              ),
            ),
            child: FocusTraversalGroup(
              policy: OrderedTraversalPolicy(),
              child: MaterialApp(
            title: 'Blockchain en la Empresa',
            debugShowCheckedModeBanner: false,
            locale: const Locale('es'),
            supportedLocales: const [
              Locale('es'),
              Locale('en'),
            ],
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            themeMode: themeProvider.themeMode,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            home: const AuthWrapper(),
          ),
          ),
          );
        },
      ),
    );
  }
}
