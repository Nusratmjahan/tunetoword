import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/memory_screen.dart';
import 'services/firebase_service.dart';
import 'globals.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const CassetteNoteApp());
}

class CassetteNoteApp extends StatelessWidget {
  const CassetteNoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => FirebaseService())],
      child: MaterialApp(
        title: 'CassetteNote',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: AppColors.brownDark,
          scaffoldBackgroundColor: AppColors.cream,
          textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brownDark,
              foregroundColor: AppColors.cream,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        initialRoute: '/',
        onGenerateRoute: (settings) {
          // Handle /memory/CODE routes for web sharing
          if (settings.name != null && settings.name!.startsWith('/memory/')) {
            final code = settings.name!.replaceFirst('/memory/', '');
            return MaterialPageRoute(
              builder: (_) => MemoryScreen(code: code),
            );
          }

          // Default route
          return MaterialPageRoute(
            builder: (_) => const AuthWrapper(),
          );
        },
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseService = Provider.of<FirebaseService>(context);

    return firebaseService.currentUser != null
        ? const HomeScreen()
        : const LoginScreen();
  }
}
