import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_edu/screens/siswa/course_detail_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AllCourseTab extends StatefulWidget {
  final String? initialCategoryId;
  const AllCourseTab({super.key, this.initialCategoryId});

  @override
  State<AllCourseTab> createState() => _AllCourseTabState();
}

class _AllCourseTabState extends State<AllCourseTab>
    with TickerProviderStateMixin {
  final SupabaseClient client = Supabase.instance.client;
  String _searchQuery = '';
  String? _selectedCategory;
  String _sortBy = 'newest';
  bool _isGridView = false;
  late Future<List<dynamic>> _categoriesFuture;
  late Future<List<dynamic>> _coursesFuture;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategoryId;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _fetchCategories();
    _fetchCourses();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _fetchCategories() {
    _categoriesFuture = client.from('category_course').select();
  }

  void _fetchCourses() {
    var query = client.from('course').select('*, category_course(name)');
    if (_searchQuery.isNotEmpty) {
      query = query.ilike('title', '%$_searchQuery%');
    }
    if (_selectedCategory != null) {
      query = query.eq('category_id', _selectedCategory!);
    }

    // Apply sorting
    switch (_sortBy) {
      case 'newest':
        _coursesFuture = query.order('created_at', ascending: false);
        break;
      case 'oldest':
        _coursesFuture = query.order('created_at', ascending: true);
        break;
      case 'price_low':
        _coursesFuture = query.order('price', ascending: true);
        break;
      case 'price_high':
        _coursesFuture = query.order('price', ascending: false);
        break;
      case 'popular':
        // Static implementation - you can add enrollment_count to backend later
        _coursesFuture = query.order('created_at', ascending: false);
        break;
    }

    setState(() {});
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        String tempSortBy = _sortBy; // ← buffer state lokal

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filter & Sort',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Urutkan berdasarkan',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildSortChip('Terbaru', 'newest', tempSortBy, (val) {
                        setModalState(() => tempSortBy = val);
                      }),
                      _buildSortChip('Terlama', 'oldest', tempSortBy, (val) {
                        setModalState(() => tempSortBy = val);
                      }),
                      _buildSortChip(
                        'Harga Terendah',
                        'price_low',
                        tempSortBy,
                        (val) {
                          setModalState(() => tempSortBy = val);
                        },
                      ),
                      _buildSortChip(
                        'Harga Tertinggi',
                        'price_high',
                        tempSortBy,
                        (val) {
                          setModalState(() => tempSortBy = val);
                        },
                      ),
                      _buildSortChip('Terpopuler', 'popular', tempSortBy, (
                        val,
                      ) {
                        setModalState(() => tempSortBy = val);
                      }),
                    ],
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(
                          () => _sortBy = tempSortBy,
                        ); // ← Simpan perubahan
                        Navigator.pop(context);
                        _fetchCourses();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1f2967),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Terapkan Filter',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).padding.bottom),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSortChip(
    String text,
    String value,
    String selectedValue,
    Function(String) onSelected,
  ) {
    final isSelected = selectedValue == value;

    return FilterChip(
      label: Text(text),
      selected: isSelected,
      onSelected: (_) => onSelected(value),
      selectedColor: const Color(0xFF1f2967).withOpacity(0.2),
      checkmarkColor: const Color(0xFF1f2967),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFF1f2967) : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF7475d6),
                    const Color.fromARGB(255, 161, 161, 212),
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10, top: 85, left: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'All Courses',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Find your best course to improve your magnificient skills',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Search Bar with enhanced design
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        gradient: LinearGradient(
                          colors: [Colors.grey[100]!, Colors.grey[50]!],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                          // Debounce search
                          Future.delayed(const Duration(milliseconds: 500), () {
                            if (_searchQuery == value) {
                              _fetchCourses();
                            }
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Cari kursus impian Anda...',
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey[600],
                          ),
                          suffixIcon:
                              _searchQuery.isNotEmpty
                                  ? IconButton(
                                    icon: Icon(
                                      Icons.clear,
                                      color: Colors.grey[600],
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _searchQuery = '';
                                        _fetchCourses();
                                      });
                                    },
                                  )
                                  : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Filter and View Toggle Row
                    Row(
                      children: [
                        Expanded(
                          child: FutureBuilder<List<dynamic>>(
                            future: _categoriesFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const SizedBox(
                                  height: 40,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                );
                              }
                              if (snapshot.hasError || !snapshot.hasData) {
                                return const SizedBox.shrink();
                              }

                              final categories = snapshot.data!;
                              return SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    _buildCategoryChip('Semua', null),
                                    const SizedBox(width: 8),
                                    ...categories.map(
                                      (category) => Padding(
                                        padding: const EdgeInsets.only(
                                          right: 8,
                                        ),
                                        child: _buildCategoryChip(
                                          category['name'],
                                          category['id'],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Row(
                          children: [
                            // Filter Button
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF1f2967).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: IconButton(
                                onPressed: _showFilterBottomSheet,
                                icon: const Icon(
                                  Icons.tune,
                                  color: Color(0xFF1f2967),
                                ),
                                tooltip: 'Filter',
                              ),
                            ),
                            const SizedBox(width: 8),
                            // View Toggle Button
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF1f2967).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _isGridView = !_isGridView;
                                  });
                                },
                                icon: Icon(
                                  _isGridView ? Icons.list : Icons.grid_view,
                                  color: const Color(0xFF1f2967),
                                ),
                                tooltip:
                                    _isGridView
                                        ? 'Tampilan List'
                                        : 'Tampilan Grid',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: _coursesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF1f2967),
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Terjadi kesalahan',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Error: ${snapshot.error}',
                            style: TextStyle(color: Colors.grey[600]),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.school_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Tidak ada kursus ditemukan',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Coba ubah kata kunci pencarian atau filter',
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    );
                  }

                  final courses = snapshot.data!;
                  return _isGridView
                      ? _buildGridView(courses)
                      : _buildListView(courses);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String text, String? categoryId) {
    final isSelected = _selectedCategory == categoryId;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: FilterChip(
        label: Text(text),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = selected ? categoryId : null;
            _fetchCourses();
          });
        },
        backgroundColor: Colors.grey[100],
        selectedColor: const Color(0xFF1f2967),
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.grey[700],
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: isSelected ? 2 : 0,
      ),
    );
  }

  Widget _buildListView(List<dynamic> courses) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];
        return _buildCourseCard(course, index);
      },
    );
  }

  Widget _buildGridView(List<dynamic> courses) {
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.6,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];
        return _buildGridCourseCard(course, index);
      },
    );
  }

  Widget _buildCourseCard(Map<String, dynamic> course, int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + (index * 100)),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CourseDetailPage(course: course)),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: 'course_${course['id']}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child:
                        course['thumbnail_url'] != null
                            ? CachedNetworkImage(
                              imageUrl: course['thumbnail_url'],
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                              placeholder:
                                  (context, url) => Container(
                                    height: 100,
                                    width: 100,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                              errorWidget:
                                  (context, url, error) => Container(
                                    height: 100,
                                    width: 100,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Icon(
                                      Icons.broken_image,
                                      color: Colors.grey[400],
                                      size: 32,
                                    ),
                                  ),
                            )
                            : Container(
                              height: 100,
                              width: 100,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF1f2967).withOpacity(0.7),
                                    const Color(0xFF1f2967).withOpacity(0.5),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: const Icon(
                                Icons.school,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course['title'],
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        course['description'] ?? 'Tidak ada deskripsi.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Rp ${_formatPrice(course['price'])}',
                              style: TextStyle(
                                color: Colors.green[700],
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (course['category_course'] != null &&
                          course['category_course']['name'] != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1f2967).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            course['category_course']['name'],
                            style: TextStyle(
                              color: const Color(0xFF1f2967),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGridCourseCard(Map<String, dynamic> course, int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + (index * 50)),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CourseDetailPage(course: course)),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Hero(
                  tag: 'course_grid_${course['id']}',
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child:
                        course['thumbnail_url'] != null
                            ? CachedNetworkImage(
                              imageUrl: course['thumbnail_url'],
                              width: double.infinity,
                              fit: BoxFit.cover,
                              placeholder:
                                  (context, url) => Container(
                                    color: Colors.grey[200],
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                              errorWidget:
                                  (context, url, error) => Container(
                                    color: Colors.grey[200],
                                    child: Icon(
                                      Icons.broken_image,
                                      color: Colors.grey[400],
                                      size: 32,
                                    ),
                                  ),
                            )
                            : Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF1f2967).withOpacity(0.7),
                                    const Color(0xFF1f2967).withOpacity(0.5),
                                  ],
                                ),
                              ),
                              child: const Icon(
                                Icons.school,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course['title'],
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Rp ${_formatPrice(course['price'])}',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      if (course['category_course'] != null &&
                          course['category_course']['name'] != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1f2967).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            course['category_course']['name'],
                            style: TextStyle(
                              color: const Color(0xFF1f2967),
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatPrice(dynamic price) {
    if (price == null) return '0,00';

    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol:
          '', // Tidak pakai Rp di sini, bisa kamu tambahkan di UI kalau perlu
      decimalDigits: 2,
    );

    return formatter.format(price).trim();
  }
}
