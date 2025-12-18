import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'pages/home_page.dart';
import 'pages/map_page.dart';
import 'pages/community_page.dart';
import 'pages/profile_page.dart';
import 'pages/chat_page.dart';
import 'widgets/bottom_nav.dart';
import 'widgets/brand_logo_title.dart';
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
  const MainScreen({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _selectedIndex;
  bool _showChat = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialIndex;
    // Clamp to available tabs to avoid out-of-range values.
    _selectedIndex = initial < 0
        ? 0
        : initial > 3
        ? 3
        : initial;
  }

  void _openChatbot() {
    setState(() {
      _showChat = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Widget body;
    if (_showChat) {
      body = const ChatPage();
    } else {
      body = switch (_selectedIndex) {
        0 => const HomePage(),
        1 => const MapPage(),
        2 => const CommunityPage(),
        3 => const ProfilePage(),
        _ => const HomePage(),
      };
    }

    return Scaffold(
      appBar: AppBar(
        title: const BrandLogoTitle(),
        elevation: 0,
        backgroundColor: BrandColors.latteFoam,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2.5),
          child: Container(
            width: double.infinity,
            height: 1,
            color: BrandColors.caramel.withValues(alpha: 90),
          ),
        ),
      ),
      body: SafeArea(child: body),
      bottomNavigationBar: SafeArea(
        child: BottomNav(
          currentIndex: _showChat ? -1 : _selectedIndex,
          onTap: (i) => setState(() {
            _selectedIndex = i;
            _showChat = false;
          }),
          onChatbotTap: _openChatbot,
        ),
      ),
    );
  }
}
