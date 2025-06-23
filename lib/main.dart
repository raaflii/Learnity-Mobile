import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_edu/screens/splash/splash_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/siswa/home_siswa.dart';
import 'screens/pengajar/home_pengajar.dart';
import 'screens/admin/home_admin.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://ksoxroijcvsslxlyygmv.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imtzb3hyb2lqY3Zzc2x4bHl5Z212Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTAxNzIyOTIsImV4cCI6MjA2NTc0ODI5Mn0.Pr2PVLVH-CGQtHybCsHoYtSKAXr60NDu7f8neC_eoq0',
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mobile Edu',
      theme: ThemeData(
        primaryColor: const Color(0xFF1f2967),
        scaffoldBackgroundColor: const Color(0xFFF5F7FB),
        textTheme: GoogleFonts.poppinsTextTheme(),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1f2967),
          foregroundColor: Colors.white,
          elevation: 1,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1f2967),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        tabBarTheme: const TabBarThemeData(
          labelColor: Colors.white,
          unselectedLabelColor: Color(0xFFB3C0D6),
          indicatorColor: Colors.white,
        ),
      ),
      home: user == null ? const SplashScreen() : const RoleRedirectPage(),
    );
  }
}

class RoleRedirectPage extends StatelessWidget {
  const RoleRedirectPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final email = user?.email;
    final role = user?.userMetadata?['role'] ?? 'siswa';

    if (email == 'admin@gmail.com' && role == 'admin') {
      return const HomeAdmin();
    }

    if (role == 'pengajar') {
      return const HomePengajar();
    }

    return const HomeSiswa(initialIndex: 0);
  }
}
