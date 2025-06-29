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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors:[
                    const Color(0xFF7475d6), // Keep original color for light mode
                    const Color.fromARGB(255, 161, 161, 212),
                  ]
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
                        border: Border.all(
                          color: isDark 
                              ? Theme.of(context).colorScheme.outline
                              : Colors.white, 
                          width: 4
                        ),
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
                        backgroundColor: Theme.of(context).colorScheme.surface,
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
                                    style: TextStyle(
                                      fontSize: 40,
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDark 
                            ? Theme.of(context).colorScheme.onSurface
                            : Colors.white,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Email
                    Text(
                      user?.email ?? 'example@example.com',
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark 
                            ? Theme.of(context).colorScheme.onSurface.withOpacity(0.7)
                            : Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
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

                          const SizedBox(height: 40),

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: isDark 
              ? colorScheme.surfaceContainer
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark 
                ? colorScheme.outline.withOpacity(0.2)
                : Colors.grey.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark 
                  ? Colors.black.withOpacity(0.2)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark 
                    ? colorScheme.primaryContainer.withOpacity(0.3)
                    : colorScheme.primaryContainer.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: colorScheme.primary.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Icon(
                icon, 
                color: colorScheme.primary, 
                size: 20
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            if (hasNotification)
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios,
              color: colorScheme.onSurfaceVariant,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}