import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final topicCountProvider = FutureProvider.family<int, String>((ref, courseId) async {
  final response = await Supabase.instance.client
      .from('topic')
      .select('id')
      .eq('course_id', courseId);

  return response.length;
});