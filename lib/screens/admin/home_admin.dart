import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:mobile_edu/auth/login_page.dart';
import 'package:mobile_edu/screens/admin/category_tab.dart';
import 'package:mobile_edu/screens/admin/course_tab.dart';
import 'package:mobile_edu/screens/admin/user_tab.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeAdmin extends StatefulWidget {
  const HomeAdmin({super.key});

  @override
  State<HomeAdmin> createState() => _HomeAdminState();
}

class _HomeAdminState extends State<HomeAdmin> {
  int _currentIndex = 0;

  final List<IconData> _iconList = [
    LucideIcons.users,
    LucideIcons.grid,
    LucideIcons.bookOpen,
    LucideIcons.user,
  ];

  final List<Widget> _pages = [
    const UsersTab(),
    const CategoryListPage(),
    const CoursesTabAdmin(),
    const AdminProfileTab(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          border: Border(
            top: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_iconList.length, (i) {
            final isActive = _currentIndex == i;
            return GestureDetector(
              onTap: () => _onTabTapped(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      isActive
                          ? const Color(0xFF1f2967).withOpacity(0.12)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _iconList[i],
                  size: 24,
                  color:
                      isActive ? const Color(0xFF1f2967) : Colors.grey.shade500,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class AdminProfileTab extends StatefulWidget {
  const AdminProfileTab({super.key});
  @override
  State<AdminProfileTab> createState() => _AdminProfileTabState();
}

class _AdminProfileTabState extends State<AdminProfileTab> {
  static const mainColor = Color(0xFF7475d6);
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Admin Profile',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w600,
              color: mainColor,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.logout),
            label: const Text('Logout', style: TextStyle(fontSize: 18)),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: mainColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 5,
            ),
          ),
        ],
      ),
    );
  }
}

class CourseFormPage extends StatefulWidget {
  final Map? course;
  const CourseFormPage({super.key, this.course});
  @override
  State<CourseFormPage> createState() => _CourseFormPageState();
}

class _CourseFormPageState extends State<CourseFormPage> {
  final supa = Supabase.instance.client;
  final titleCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final thumbnailCtrl = TextEditingController();
  String? selectedCategoryId;
  String? selectedTeacherId;
  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> teachers = [];
  static const mainColor = Color(0xFF1f2967);

  @override
  void initState() {
    super.initState();
    if (widget.course != null) {
      titleCtrl.text = widget.course!['title'];
      priceCtrl.text = widget.course!['price'].toString();
      descCtrl.text = widget.course!['description'] ?? '';
      thumbnailCtrl.text = widget.course!['thumbnail_url'] ?? '';
      selectedCategoryId = widget.course!['category_id'];
      selectedTeacherId = widget.course!['teacher_id'];
    }
    loadCategories();
    loadTeachers();
  }

  Future<void> loadCategories() async {
    final data = await supa.from('category_course').select();
    setState(() => categories = List<Map<String, dynamic>>.from(data));
  }

  Future<void> loadTeachers() async {
    final data = await supa
        .from('public_users')
        .select('id, email')
        .eq('role', 'pengajar');
    setState(() => teachers = List<Map<String, dynamic>>.from(data));
  }

  Future<void> saveCourse() async {
    final courseData = {
      'title': titleCtrl.text.trim(),
      'price': num.tryParse(priceCtrl.text.trim()) ?? 0,
      'description': descCtrl.text.trim(),
      'thumbnail_url': thumbnailCtrl.text.trim(),
      'category_id': selectedCategoryId,
      'teacher_id': selectedTeacherId,
    };
    if (widget.course == null) {
      await supa.from('course').insert(courseData);
    } else {
      await supa
          .from('course')
          .update(courseData)
          .eq('id', widget.course!['id']);
    }
    if (context.mounted) Navigator.pop(context, true);
  }

  InputDecoration inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: mainColor),
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: mainColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.course != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Course' : 'Add Course'),
        backgroundColor: mainColor,
        foregroundColor: Colors.white,
        elevation: 6,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: ListView(
          children: [
            TextField(
              controller: titleCtrl,
              decoration: inputDecoration('Title'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: priceCtrl,
              keyboardType: TextInputType.number,
              decoration: inputDecoration('Price'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descCtrl,
              maxLines: 4,
              decoration: inputDecoration('Description'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedTeacherId,
              items:
                  teachers
                      .map(
                        (user) => DropdownMenuItem<String>(
                          value: user['id'].toString(),
                          child: Text(user['email'] ?? 'No Email'),
                        ),
                      )
                      .toList(),
              onChanged: (val) => setState(() => selectedTeacherId = val),
              decoration: inputDecoration('Teacher'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedCategoryId,
              items:
                  categories
                      .map(
                        (cat) => DropdownMenuItem(
                          value: cat['id'] as String,
                          child: Text(cat['name']),
                        ),
                      )
                      .toList(),
              onChanged: (val) => setState(() => selectedCategoryId = val),
              decoration: inputDecoration('Category'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: thumbnailCtrl,
              decoration: inputDecoration('Thumbnail URL'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 20),
            if (thumbnailCtrl.text.isNotEmpty)
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                clipBehavior: Clip.antiAlias,
                shadowColor: mainColor.withOpacity(0.3),
                child: Image.network(
                  thumbnailCtrl.text,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, __, ___) => SizedBox(
                        height: 180,
                        child: Center(
                          child: Icon(
                            Icons.broken_image,
                            color: Colors.grey.shade400,
                            size: 50,
                          ),
                        ),
                      ),
                ),
              ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: saveCourse,
                icon: Icon(isEdit ? Icons.save : Icons.add),
                label: Text(
                  isEdit ? 'Update Course' : 'Create Course',
                  style: const TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainColor,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
