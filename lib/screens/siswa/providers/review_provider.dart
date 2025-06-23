import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final reviewListProvider = StateProvider<List<Map<String, dynamic>>>((ref) => []);

final totalReviewProvider = Provider<int>((ref) {
  return ref.watch(reviewListProvider).length;
});

final averageRatingProvider = FutureProvider.family<double, String>((ref, courseId) async {
  final response = await Supabase.instance.client
      .from('review')
      .select('rating')
      .eq('course_id', courseId);

  final List data = response;
  if (data.isEmpty) return 0.0;

  double total = 0;
  for (final item in data) {
    total += (item['rating'] ?? 0).toDouble();
  }

  return total / data.length;
});