import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final supa = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getRandomCourses(int count) async {
    final response = await supa
        .from('course')
        .select()
        .limit(count);

    return response;
  }

  Future<List<Map<String, dynamic>>> getMyCourses() async {
    final uid = supa.auth.currentUser!.id;
    final response = await supa
        .from('enrollment')
        .select('course(*)')
        .eq('user_id', uid);

    return (response as List)
        .map((e) => e['course'] as Map<String, dynamic>)
        .toList();
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    final response = await supa
        .from('category_course')
        .select();
    return response;
  }
}
