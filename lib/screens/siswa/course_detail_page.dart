import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_edu/screens/siswa/reviews_tab.dart';
import 'package:mobile_edu/screens/siswa/video_player_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class CourseDetailPage extends StatefulWidget {
  final Map course;
  const CourseDetailPage({super.key, required this.course});

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage>
    with TickerProviderStateMixin {
  final SupabaseClient _supabase = Supabase.instance.client;
  bool _isEnrolled = false;
  List<dynamic> _topics = [];
  bool _isLoadingTopics = true;
  String? _errorMessage;
  late TabController _tabController;
  // ignore: unused_field
  String? _username;
  // ignore: unused_field
  late dynamic _course;
  Map<String, dynamic> _instructor = {};
  List<Map<String, dynamic>> _reviews = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _checkEnrollmentStatus();
    _fetchTopics();
    _fetchUsername();
    _fetchCourse();
    _fetchInstructor(); // Add this line
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchInstructor() async {
    final courseId = widget.course['id'];

    try {
      final courseRes =
          await Supabase.instance.client
              .from('course')
              .select('teacher_id')
              .eq('id', courseId)
              .single();

      final teacherId = courseRes['teacher_id'];

      final teacherRes =
          await Supabase.instance.client
              .from('profiles')
              .select('full_name')
              .eq('id', teacherId)
              .single();

      final name = teacherRes['full_name'] ?? 'Instructor';

      final profileRes =
          await Supabase.instance.client
              .from('profiles')
              .select('avatar_url')
              .eq('id', teacherId)
              .maybeSingle();

      final avatar = profileRes?['avatar_url'];

      setState(() {
        _instructor = {
          'name': name,
          'avatar': avatar,
          'title': 'Senior Lecturer',
          'rating': 4.7,
          'students': 1200,
        };
      });
    } catch (e) {
      debugPrint('Gagal fetch instructor: $e');
      setState(() {
        _instructor = {
          'name': 'Instructor',
          'avatar': null,
          'title': 'Senior Lecturer',
          'rating': 4.7,
          'students': 1200,
        };
      });
    }
  }

  Future<void> _fetchUsername() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final res =
        await Supabase.instance.client
            .from('profiles')
            .select('username')
            .eq('id', user.id)
            .single();

    setState(() {
      _username = res['username'] ?? 'Siswa';
    });
  }

  void _fetchCourse() async {
    final course =
        await _supabase
            .from('course')
            .select('*, category_course(name)')
            .eq('id', widget.course['id'])
            .single();
    setState(() {
      _course = course;
    });
  }

  Future<void> _checkEnrollmentStatus() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      setState(() => _isEnrolled = false);
      return;
    }
    try {
      final response = await _supabase
          .from('enrollment')
          .select()
          .eq('user_id', user.id)
          .eq('course_id', widget.course['id'])
          .limit(1);

      setState(() {
        _isEnrolled = response.isNotEmpty;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error checking enrollment: $e')),
        );
      }
      setState(() => _isEnrolled = false);
    }
  }

  Future<void> _fetchTopics() async {
    setState(() {
      _isLoadingTopics = true;
      _errorMessage = null;
    });
    try {
      final response = await _supabase
          .from('topic')
          .select()
          .eq('course_id', widget.course['id'])
          .order('order_no', ascending: true);
      setState(() {
        _topics = response;
        _isLoadingTopics = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading topics: $e')));
      }
      setState(() {
        _errorMessage = 'Failed to load topics: $e';
        _isLoadingTopics = false;
      });
    }
  }

  Future<void> _toggleEnrollment() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to enroll.')),
        );
      }
      return;
    }

    try {
      if (_isEnrolled) {
        await _supabase
            .from('enrollment')
            .delete()
            .eq('user_id', user.id)
            .eq('course_id', widget.course['id']);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unenrolled successfully!')),
          );
        }
      } else {
        await _supabase.from('enrollment').insert({
          'user_id': user.id,
          'course_id': widget.course['id'],
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Enrolled successfully!')),
          );
        }
      }

      await _checkEnrollmentStatus();
      setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update enrollment: $e')),
        );
      }
    }
  }

  Widget _buildCourseHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7475d6), Color.fromARGB(255, 125, 126, 177)],
        ),
      ),
      child: Column(
        children: [
          // App Bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const Expanded(
                    child: Text(
                      'Course',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.share, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),

          // Course Video/Thumbnail
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  if (widget.course['thumbnail_url'] != null)
                    CachedNetworkImage(
                      imageUrl: widget.course['thumbnail_url'],
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder:
                          (context, url) => Container(
                            height: 200,
                            color: Colors.grey[300],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                      errorWidget:
                          (context, url, error) => Container(
                            height: 200,
                            color: Colors.grey[300],
                            child: const Icon(Icons.broken_image, size: 60),
                          ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.course['title'] ?? 'Course Title',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      averageRating.toStringAsFixed(1),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      '${_topics.length} lessons',
                      style: TextStyle(color: Colors.white.withOpacity(0.8)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildEnrollmentSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rp ${_formatPrice(widget.course['price'] ?? '0')}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7475d6),
                      ),
                    ),
                    const Text(
                      'Full course access',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 140,
                height: 50,
                child: ElevatedButton(
                  onPressed: _toggleEnrollment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _isEnrolled ? Colors.green : const Color(0xFF1f2967),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_isEnrolled ? Icons.check : Icons.add, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _isEnrolled ? 'Enrolled' : 'Enroll',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  double get averageRating {
    if (_reviews.isEmpty) return 0.0;
    final total = _reviews.fold<double>(
      0.0,
      (sum, r) => sum + ((r['rating'] ?? 0).toDouble()),
    );
    return total / _reviews.length;
  }

  void updateReviews(List<Map<String, dynamic>> reviews) {
    setState(() {
      _reviews = reviews;
    });
  }

  Widget _buildLessonsTab() {
    if (_isLoadingTopics) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
      );
    }

    if (_topics.isEmpty) {
      return const Center(
        child: Text('No topics available for this course yet.'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _topics.length,
      itemBuilder: (context, index) {
        final topic = _topics[index];
        final youtubeVideoId = YoutubePlayer.convertUrlToId(
          topic["video_url"] ?? '',
        );

        final isLocked = !_isEnrolled && index >= 2;
        final canPlay = _isEnrolled || index < 2;

        return Container(
          margin: const EdgeInsets.only(bottom: 12, top: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child:
                      youtubeVideoId != null
                          ? CachedNetworkImage(
                            imageUrl: YoutubePlayer.getThumbnail(
                              videoId: youtubeVideoId,
                              quality: ThumbnailQuality.medium,
                            ),
                            width: 80,
                            height: 60,
                            fit: BoxFit.cover,
                            placeholder:
                                (context, url) => Container(
                                  width: 80,
                                  height: 60,
                                  color: Colors.grey[200],
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                            errorWidget:
                                (context, url, error) => Container(
                                  width: 80,
                                  height: 60,
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.videocam_off),
                                ),
                          )
                          : Container(
                            width: 80,
                            height: 60,
                            color: Colors.grey[200],
                            child: const Icon(Icons.video_library_outlined),
                          ),
                ),
                if (isLocked)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Icon(Icons.lock, color: Colors.white, size: 24),
                      ),
                    ),
                  ),
                if (canPlay && !isLocked)
                  const Positioned.fill(
                    child: Center(
                      child: Icon(
                        Icons.play_circle_filled,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
              ],
            ),
            title: Text(
              '${topic['order_no']}. ${topic['title']}',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isLocked ? Colors.grey : Colors.black,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  topic['description'] ?? 'No description.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isLocked ? Colors.grey : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: isLocked ? Colors.grey : Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${5 + index * 2} min',
                      style: TextStyle(
                        fontSize: 12,
                        color: isLocked ? Colors.grey : Colors.grey[500],
                      ),
                    ),
                    if (index < 2 && !_isEnrolled) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'FREE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            trailing:
                isLocked
                    ? const Icon(Icons.lock, color: Colors.grey)
                    : const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () {
              if (canPlay && youtubeVideoId != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => YoutubeVideoPlayerPage(
                          videoId: youtubeVideoId,
                          title: topic['title'],
                        ),
                  ),
                );
              } else if (isLocked) {
                _showEnrollDialog();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Video URL is invalid or not found.'),
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildDescriptionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.course['description'] ?? 'No description available.',
            style: const TextStyle(
              fontSize: 16,
              height: 1.6,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 30),

          // Instructor Info
          const Text(
            'Instructor',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Show loading if instructor data is empty
          if (_instructor.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(child: CircularProgressIndicator()),
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage:
                        (_instructor['avatar'] != null &&
                                _instructor['avatar'].toString().isNotEmpty)
                            ? NetworkImage(_instructor['avatar'])
                            : null,
                    child:
                        (_instructor['avatar'] == null ||
                                _instructor['avatar'].toString().isEmpty)
                            ? Text(
                              (_instructor['name']?.isNotEmpty ?? false)
                                  ? _instructor['name'][0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            )
                            : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _instructor['name'] ??
                              'Instructor', // Add null check here
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _instructor['title'] ??
                              'Senior Lecturer', // Add null check here
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${_instructor['rating'] ?? 4.7}', // Add null check here
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              '${_instructor['students'] ?? 1200} students', // Add null check here
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showEnrollDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),

                      // Hero section dengan animasi
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.workspace_premium,
                                size: 60,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Upgrade to Premium',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Unlock your full learning potential',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // What you'll get section
                      const Text(
                        'What you\'ll get:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1f2967),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Premium features
                      _buildPremiumFeature(
                        Icons.play_circle_fill,
                        'Complete Video Library',
                        'Access all ${widget.course['total_videos'] ?? '50+'} premium videos',
                        const Color(0xFF4CAF50),
                      ),

                      _buildPremiumFeature(
                        Icons.download_for_offline,
                        'Offline Access',
                        'Download videos and watch without internet',
                        const Color(0xFF2196F3),
                      ),

                      _buildPremiumFeature(
                        Icons.quiz,
                        'Interactive Quizzes',
                        'Test your knowledge with exclusive exercises',
                        const Color(0xFFFF9800),
                      ),

                      _buildPremiumFeature(
                        Icons.military_tech,
                        'Certificate',
                        'Get verified certificate upon completion',
                        const Color(0xFF9C27B0),
                      ),

                      _buildPremiumFeature(
                        Icons.support_agent,
                        'Priority Support',
                        '24/7 direct access to instructors',
                        const Color(0xFFE91E63),
                      ),

                      const SizedBox(height: 32),

                      // Pricing section dengan lebih menarik
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF667eea).withOpacity(0.1),
                              const Color(0xFF764ba2).withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF667eea).withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF6B6B),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    '🔥 LIMITED TIME',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Rp ${_formatPrice((widget.course['price'] * 1.5).toInt())}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Rp ${_formatPrice(widget.course['price'])}',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1f2967),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'One-time payment • Lifetime access • 30-day money back',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // CTA Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _toggleEnrollment();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF667eea),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.rocket_launch, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Start Learning Now',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Maybe later',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPremiumFeature(
    IconData icon,
    String title,
    String description,
    Color iconColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 24, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1f2967),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Icon(Icons.check_circle, color: Colors.green[400], size: 20),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],

      body: NestedScrollView(
        headerSliverBuilder:
            (context, innerBoxIsScrolled) => [
              SliverToBoxAdapter(child: _buildCourseHeader()),
              SliverToBoxAdapter(child: _buildEnrollmentSection()),

              SliverPersistentHeader(
                pinned: true,
                delegate: _TabBarDelegate(
                  TabBar(
                    controller: _tabController,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.grey[600],
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                      color: const Color(0xFF1f2967),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    tabs: const [
                      Tab(text: 'Lessons'),
                      Tab(text: 'Description'),
                      Tab(text: 'Reviews'),
                    ],
                  ),
                ),
              ),
            ],

        body: AnimatedBuilder(
          animation: _tabController,
          builder: (context, _) {
            return IndexedStack(
              index: _tabController.index,
              children: [
                _buildLessonsTab(),
                _buildDescriptionTab(),
                ReviewsTab(
                  courseId: widget.course['id'],
                  isEnrolled: _isEnrolled,
                  onReviewLoaded: updateReviews,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

String _formatPrice(dynamic price) {
  if (price == null) return '0,00';

  final formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: '',
    decimalDigits: 2,
  );

  return formatter.format(price).trim();
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  static const double _topOffset = 30; // jarak yang diinginkan

  _TabBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height + _topOffset;

  @override
  double get maxExtent => _tabBar.preferredSize.height + _topOffset;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Material(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.only(top: _topOffset),
        child: _tabBar,
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) => false;
}
