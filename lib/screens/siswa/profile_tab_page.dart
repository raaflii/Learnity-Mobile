import 'package:flutter/material.dart';
import 'package:mobile_edu/auth/login_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  String? _username;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _fetchUsername();
  }

  Future<void> _fetchUsername() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final res =
        await Supabase.instance.client
            .from('profiles')
            .select('username, avatar_url')
            .eq('id', user.id)
            .single();

    setState(() {
      _username = res['username'] ?? 'Siswa';
      _avatarUrl = res['avatar_url'];
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF7475d6), Color.fromARGB(255, 161, 161, 212)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 56,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 52,
                          backgroundImage:
                              (_avatarUrl?.isNotEmpty ?? false)
                                  ? NetworkImage(_avatarUrl!)
                                  : null,

                          // 👇 Tambahkan hanya jika ada gambar
                          onBackgroundImageError:
                              (_avatarUrl?.isNotEmpty ?? false)
                                  ? (_, __) {}
                                  : null,

                          child:
                              (_avatarUrl?.isEmpty ?? true)
                                  ? Text(
                                    (_username?.isNotEmpty ?? false)
                                        ? _username![0].toUpperCase()
                                        : 'U',
                                    style: const TextStyle(
                                      fontSize: 40,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                  : null,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    Text(
                      _username ?? 'Siswa',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Email
                    Text(
                      user?.email ?? 'example@example.com',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        // Profile Menu Item
                        _buildMenuItem(
                          icon: Icons.person_outline,
                          title: 'My Profile',
                          onTap: () {},
                        ),

                        const SizedBox(height: 16),

                        // Messages Menu Item
                        _buildMenuItem(
                          icon: Icons.message_outlined,
                          title: 'Messages',
                          hasNotification: true,
                          onTap: () {},
                        ),

                        const SizedBox(height: 16),

                        // Favorites Menu Item
                        _buildMenuItem(
                          icon: Icons.favorite_outline,
                          title: 'Favorites',
                          onTap: () {},
                        ),

                        const SizedBox(height: 16),

                        // Location Menu Item
                        _buildMenuItem(
                          icon: Icons.location_on_outlined,
                          title: 'Location',
                          onTap: () {},
                        ),

                        const SizedBox(height: 16),

                        _buildMenuItem(
                          icon: Icons.settings_outlined,
                          title: 'Settings',
                          onTap: () {},
                        ),

                        const Spacer(),

                        SizedBox(
                          width: double.infinity,
                          child: TextButton.icon(
                            onPressed: () async {
                              await Supabase.instance.client.auth.signOut();
                              if (context.mounted) {
                                await Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => LoginPage(),
                                  ),
                                );
                              }
                            },
                            icon: const Icon(
                              Icons.logout,
                              color: Color(0xFFd32f2f),
                            ),
                            label: const Text(
                              'Logout',
                              style: TextStyle(
                                color: Color(0xFFd32f2f),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              foregroundColor: const Color(0xFFd32f2f),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool hasNotification = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.grey.shade700, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            if (hasNotification)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF8B5CF6),
                  shape: BoxShape.circle,
                ),
              ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey.shade400,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
