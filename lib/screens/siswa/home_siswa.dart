import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:mobile_edu/screens/siswa/home_tab_page.dart';
import 'package:mobile_edu/screens/siswa/my_course_tab_page.dart';
import 'package:mobile_edu/screens/siswa/all_course_tab_page.dart';
import 'package:mobile_edu/screens/siswa/profile_tab_page.dart';

class HomeSiswa extends StatefulWidget {
  final int initialIndex;
  const HomeSiswa({super.key, this.initialIndex = 0});

  @override
  State<HomeSiswa> createState() => _HomeSiswaState();
}

class _HomeSiswaState extends State<HomeSiswa> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late final PageController _pageController;

  final List<IconData> _iconList = const [
    LucideIcons.home,
    LucideIcons.graduationCap,
    LucideIcons.bookOpen,
    LucideIcons.user,
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    _pageController.addListener(() {
      final newIndex = _pageController.page?.round();
      if (newIndex != null && newIndex != _currentIndex) {
        setState(() => _currentIndex = newIndex);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          HomeTab(),
          MyCourseTab(),
          AllCourseTab(),
          ProfileTab(),
        ],
      ),

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
