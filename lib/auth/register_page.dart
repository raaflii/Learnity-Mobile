import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final usernameCtrl = TextEditingController();
  final fullNameCtrl = TextEditingController();
  String role = 'siswa';
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> register() async {
    final email = emailCtrl.text.trim();
    final password = passCtrl.text.trim();
    final username = usernameCtrl.text.trim(); // wajib unik
    final fullName = fullNameCtrl.text.trim();

    if (email.isEmpty ||
        password.isEmpty ||
        username.isEmpty ||
        fullName.isEmpty) {
      _showError('Email, password, username, and full name must not be empty.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final existing =
          await Supabase.instance.client
              .from('profiles')
              .select('id')
              .eq('username', username)
              .maybeSingle();

      if (existing != null) {
        _showError('Username already taken. Please choose another one.');
        setState(() => _isLoading = false);
        return;
      }

      final res = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {'role': role},
      );

      final user = res.user;
      if (user == null) {
        _showError('User creation failed.');
        setState(() => _isLoading = false);
        return;
      }

      await Supabase.instance.client.from('profiles').insert({
        'id': user.id,
        'username': username,
        'full_name': fullName,
        'avatar_url':
            'https://images.pexels.com/photos/213780/pexels-photo-213780.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
      });

      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const RoleRedirectPage()),
        );
      }
    } catch (e) {
      _showError('Register failed: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Register Failed'),
            content: Text(message, style: GoogleFonts.poppins(fontSize: 14)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF7475d6).withOpacity(0.35),
                  const Color(0xFF7475d6).withOpacity(0.02),
                ],
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 50),

                          // Main heading
                          Text(
                            "Create Account",
                            style: GoogleFonts.poppins(
                              fontSize: 32,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF7475d6),
                              height: 1.2,
                            ),
                          ),

                          const SizedBox(height: 12),

                          Text(
                            'Welcome to our community',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Let's get you started!",
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey.shade600,
                            ),
                          ),

                          const SizedBox(height: 50),

                          // Username Field
                          Text(
                            'Username',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF7475d6),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                            child: TextField(
                              controller: usernameCtrl,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Enter Username',
                                hintStyle: GoogleFonts.poppins(
                                  color: Colors.grey.shade400,
                                  fontSize: 16,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 18,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Full Name Field
                          Text(
                            'Full Name',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF7475d6),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                            child: TextField(
                              controller: fullNameCtrl,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Enter Full Name',
                                hintStyle: GoogleFonts.poppins(
                                  color: Colors.grey.shade400,
                                  fontSize: 16,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 18,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Email Field
                          Text(
                            'Email',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF7475d6),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                            child: TextField(
                              controller: emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Enter Email',
                                hintStyle: GoogleFonts.poppins(
                                  color: Colors.grey.shade400,
                                  fontSize: 16,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 18,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Password Field
                          Text(
                            'Password',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF7475d6),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                            child: TextField(
                              controller: passCtrl,
                              obscureText: _obscurePassword,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Enter Password',
                                hintStyle: GoogleFonts.poppins(
                                  color: Colors.grey.shade400,
                                  fontSize: 16,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: Colors.grey.shade400,
                                  ),
                                  onPressed: () {
                                    setState(
                                      () =>
                                          _obscurePassword = !_obscurePassword,
                                    );
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 18,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Role Field
                          Text(
                            'Role',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF7475d6),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                            child: DropdownButtonFormField<String>(
                              value: role,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 18,
                                ),
                              ),
                              items:
                                  ['siswa', 'pengajar']
                                      .map(
                                        (r) => DropdownMenuItem(
                                          value: r,
                                          child: Text(
                                            r == 'siswa' ? 'Siswa' : 'Pengajar',
                                            style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (v) => setState(() => role = v!),
                            ),
                          ),

                          const SizedBox(height: 60),

                          Center(
                            child: RichText(
                              text: TextSpan(
                                text: "Already have an account? ",
                                style: GoogleFonts.poppins(
                                  color: Colors.grey.shade600,
                                  fontSize: 16,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Login',
                                    style: GoogleFonts.poppins(
                                      color: Color(0xFF7475d6),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    recognizer:
                                        TapGestureRecognizer()
                                          ..onTap = () {
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (_) => const LoginPage(),
                                              ),
                                            );
                                          },
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Register Button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : register,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF7475d6),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child:
                                  _isLoading
                                      ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                          strokeWidth: 2,
                                        ),
                                      )
                                      : Text(
                                        'Sign Up',
                                        style: GoogleFonts.poppins(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                            ),
                          ),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
