import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_edu/screens/splash/splash_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/siswa/home_siswa.dart';
import 'screens/pengajar/home_pengajar.dart';
import 'screens/admin/home_admin.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
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
