import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';


import 'pages/home_page.dart';
import 'pages/profile_page.dart';
import 'pages/auth_page.dart';
import 'widgets/bottom_nav.dart';
import 'theme/brand_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CaffiAI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: BrandColors.caramel,
          onPrimary: Colors.white,
          secondary: BrandColors.mocha,
          onSecondary: Colors.white,
          error: BrandColors.warmRed,
          onError: Colors.white,
          background: BrandColors.cream,
          onBackground: BrandColors.deepEspresso,
          surface: BrandColors.latteFoam,
          onSurface: BrandColors.espressoBrown,
        ),
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: BrandColors.cream,
        appBarTheme: const AppBarTheme(
          backgroundColor: BrandColors.cream,
          surfaceTintColor: Colors.transparent,
          foregroundColor: BrandColors.deepEspresso,
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: BrandColors.caramel,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: BrandColors.latteFoam,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: BrandColors.steamedMilk),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: BrandColors.caramel,
              width: 1.4,
            ),
          ),
          labelStyle: const TextStyle(color: BrandColors.mediumRoast),
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final body = switch (_selectedIndex) {
      0 => const HomePage(),
      1 => const ProfilePage(),
      2 => const AuthPage(),
      _ => const HomePage(),
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: SafeArea(child: body),
      bottomNavigationBar: BottomNav(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
      ),
    );
  }
}
