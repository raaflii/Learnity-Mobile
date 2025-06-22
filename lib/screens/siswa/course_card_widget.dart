import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mobile_edu/screens/siswa/course_detail_page.dart';
import 'package:mobile_edu/screens/siswa/providers/review_provider.dart';
import 'package:mobile_edu/screens/siswa/providers/topic_provider.dart';

class CourseCard extends ConsumerWidget {
  final Map course;

  const CourseCard({super.key, required this.course});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncAvg = ref.watch(averageRatingProvider(course['id']));
    final asyncTopicCount = ref.watch(topicCountProvider(course['id']));

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CourseDetailPage(course: course)),
        );
      },
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.only(right: 16.0, bottom: 8.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: CachedNetworkImage(
                      imageUrl:
                          course['thumbnail_url'] ??
                          'https://via.placeholder.com/200x120.png?text=Course',
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder:
                          (context, url) => Container(
                            height: 120,
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                      errorWidget:
                          (context, url, error) => Container(
                            height: 120,
                            color: Colors.grey[200],
                            child: Icon(
                              Icons.broken_image,
                              color: Colors.grey[400],
                            ),
                          ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black26, blurRadius: 4),
                        ],
                      ),
                      child: const Icon(Icons.favorite_border, size: 18),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        children: [
                          asyncAvg.when(
                            data:
                                (avg) => Row(
                                  children: [
                                    ...List.generate(5, (index) {
                                      if (index < avg.floor()) {
                                        // Bintang penuh
                                        return Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 16,
                                        );
                                      } else if (index < avg &&
                                          avg - index >= 0.5) {
                                        // Bintang setengah
                                        return Icon(
                                          Icons.star_half,
                                          color: Colors.amber,
                                          size: 16,
                                        );
                                      } else {
                                        return Icon(
                                          Icons.star_border,
                                          color: Colors.grey[400],
                                          size: 16,
                                        );
                                      }
                                    }),
                                    const SizedBox(width: 4),
                                    Text(
                                      avg.toStringAsFixed(1),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                            loading:
                                () => Row(
                                  children: [
                                    ...List.generate(
                                      5,
                                      (index) => Icon(
                                        Icons.star_border,
                                        color: Colors.grey[300],
                                        size: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const SizedBox(
                                      width: 12,
                                      height: 12,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 1,
                                      ),
                                    ),
                                  ],
                                ),
                            error:
                                (e, _) => Row(
                                  children: [
                                    ...List.generate(
                                      5,
                                      (index) => Icon(
                                        Icons.star_border,
                                        color: Colors.grey[400],
                                        size: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Text(
                                      '0.0',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      asyncTopicCount.when(
                        data:
                            (topic) => Text(
                              '${topic.toInt()} lessons',
                              style: TextStyle(fontSize: 12),
                            ),
                        loading:
                            () => const SizedBox(
                              width: 10,
                              height: 10,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                        error: (_, __) => const Text('0 lessons'),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        course['title'] ?? 'Tanpa Judul',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
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
}

String _formatPrice(dynamic price) {
  if (price == null) return '0,00';

  final formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: '', // Tidak pakai Rp di sini, bisa kamu tambahkan di UI kalau perlu
    decimalDigits: 2,
  );

  return formatter.format(price).trim();
}
