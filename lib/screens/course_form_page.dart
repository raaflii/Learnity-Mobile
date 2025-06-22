import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CourseFormPage extends StatefulWidget {
  final Map<String, dynamic>? course;
  const CourseFormPage({super.key, this.course});

  @override
  State<CourseFormPage> createState() => _CourseFormPageState();
}

class _CourseFormPageState extends State<CourseFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _thumbController = TextEditingController();

  String? _selectedCategory;
  List<Map<String, dynamic>> _categories = [];
  bool _loading = false;

  final supa = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    if (widget.course != null) {
      _titleController.text = widget.course!['title'] ?? '';
      _descController.text = widget.course!['description'] ?? '';
      _priceController.text = widget.course!['price'].toString();
      _thumbController.text = widget.course!['thumbnail_url'] ?? '';
      _selectedCategory = widget.course!['category_id'];
    }
  }

  Future<void> _loadCategories() async {
    final result = await supa.from('category_course').select('id, name');
    setState(() {
      _categories = List<Map<String, dynamic>>.from(result);
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final payload = {
      'title': _titleController.text.trim(),
      'description': _descController.text.trim(),
      'price': double.tryParse(_priceController.text.trim()) ?? 0,
      'thumbnail_url': _thumbController.text.trim(),
      'category_id': _selectedCategory,
      'teacher_id': supa.auth.currentUser!.id,
    };

    try {
      if (widget.course == null) {
        await supa.from('course').insert(payload);
      } else {
        await supa
            .from('course')
            .update(payload)
            .eq('id', widget.course!['id']);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Error: $e')),
              ],
            ),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final primary = const Color(0xFF7475d6);
    final secondary = const Color.fromARGB(255, 125, 126, 194);
    final accent = const Color(0xFF00BCD4);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          widget.course == null ? 'Create Course' : 'Edit Course',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with gradient
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [primary, secondary],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Icon(
                      widget.course == null
                          ? Icons.add_circle_outline
                          : Icons.edit_outlined,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.course == null
                        ? 'Create New Course'
                        : 'Edit Course Details',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Form Card
            Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title Field
                      _buildSectionTitle('Course Title', Icons.book_outlined),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _titleController,
                        label: 'Enter course title',
                        icon: Icons.title,
                        validator:
                            (v) =>
                                v == null || v.isEmpty
                                    ? 'Title is required'
                                    : null,
                      ),

                      const SizedBox(height: 24),

                      // Description Field
                      _buildSectionTitle(
                        'Description',
                        Icons.description_outlined,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _descController,
                        label: 'Course description',
                        maxLines: 4,
                      ),

                      const SizedBox(height: 24),

                      // Category Field
                      _buildSectionTitle('Category', Icons.category_outlined),
                      const SizedBox(height: 12),
                      _buildDropdown(),

                      const SizedBox(height: 24),

                      // Price Field
                      _buildSectionTitle(
                        'Price',
                        Icons.monetization_on_outlined,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _priceController,
                        label: 'Price (IDR)',
                        icon: Icons.attach_money,
                        keyboardType: TextInputType.number,
                      ),

                      const SizedBox(height: 24),

                      // Thumbnail Section
                      _buildSectionTitle('Thumbnail', Icons.image_outlined),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _thumbController,
                        label: 'Thumbnail URL',
                        icon: Icons.link,
                        onChanged: (_) => setState(() {}),
                      ),

                      const SizedBox(height: 16),

                      // Thumbnail Preview
                      if (_thumbController.text.trim().isNotEmpty)
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.grey.shade200,
                              width: 2,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: CachedNetworkImage(
                              imageUrl: _thumbController.text.trim(),
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              placeholder:
                                  (context, url) => Container(
                                    height: 200,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                              errorWidget:
                                  (context, url, error) => Container(
                                    height: 200,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.broken_image,
                                          size: 60,
                                          color: Colors.grey.shade400,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Failed to load image',
                                          style: TextStyle(
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                            ),
                          ),
                        ),

                      const SizedBox(height: 32),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                            shadowColor: primary.withOpacity(0.3),
                          ),
                          child:
                              _loading
                                  ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        widget.course == null
                                            ? Icons.add
                                            : Icons.update,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        widget.course == null
                                            ? 'Create Course'
                                            : 'Update Course',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    IconData? icon, // ubah dari required ke optional
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon:
            icon != null
                ? Icon(icon, color: Colors.grey.shade600)
                : null, // tampilkan hanya jika icon != null
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1f2967), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.all(16),
      ),
      validator: validator,
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      decoration: InputDecoration(
        labelText: 'Select category',
        prefixIcon: Icon(Icons.category, color: Colors.grey.shade600),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1f2967), width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.all(16),
      ),
      items:
          _categories
              .map(
                (c) => DropdownMenuItem<String>(
                  value: c['id'],
                  child: Text(c['name']),
                ),
              )
              .toList(),
      onChanged: (v) => setState(() => _selectedCategory = v),
      validator: (v) => v == null ? 'Category is required' : null,
      icon: const Icon(Icons.keyboard_arrow_down),
    );
  }
}
