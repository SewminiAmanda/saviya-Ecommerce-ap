import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:easy_localization/easy_localization.dart';
import '../services/auth_service.dart';

final supabase = Supabase.instance.client;

class AddProductPage extends StatefulWidget {
  final int userId;

  const AddProductPage({super.key, required this.userId});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();
  TextEditingController descController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController minQuantityController = TextEditingController();

  List categories = [];
  String? selectedCategory;
  String? imageUrl;

  bool isUploading = false;

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8080/api/categories'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            categories = data['categories'];
          });
        }
      } else {
        print('Failed to load categories');
      }
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  Future<File> loadFile(String path) async => File(path);

  Future<void> pickAndUploadFile() async {
    final status = await Permission.photos.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('photo_permission_required'.tr())));
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'heic'],
    );


    if (result == null || result.files.single.path == null) {
      debugPrint("❌ No file selected.");
      return;
    }

    setState(() {
      isUploading = true;
      imageUrl = null;
    });

    try {
      final filePath = result.files.single.path!;
      final file = File(filePath);

      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${result.files.single.name}';

      debugPrint("📂 Preparing to upload file: $filePath");
      debugPrint("📝 Generated file name: $fileName");

      final uploadedPath = await supabase.storage
          .from('products')
          .upload(fileName, file);

      debugPrint("✅ Upload response path: $uploadedPath");

      debugPrint("✅ Upload response path: $uploadedPath");

      if (uploadedPath.isEmpty) throw Exception('Upload failed');

      final publicUrl = supabase.storage
          .from('products')
          .getPublicUrl(fileName);

      debugPrint("🌍 Public URL generated: $publicUrl");

      if (mounted) {
        setState(() {
          imageUrl = publicUrl;
          isUploading = false;
        });
      }
    } catch (e, st) {
      debugPrint("❌ Upload error: $e");
      debugPrint("📌 StackTrace: $st");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('file_upload_failed'.tr(args: [e.toString()]))),
      );
      if (mounted) setState(() => isUploading = false);
    }
  }

  Future<void> submitProduct() async {
    if (!_formKey.currentState!.validate() || selectedCategory == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('fill_all_fields'.tr())));
      return;
    }

    if (isUploading) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('wait_image_upload'.tr())));
      return;
    }

    final Map<String, dynamic> productData = {
      'userId': widget.userId,
      'productName': nameController.text,
      'description': descController.text,
      'categoryName': selectedCategory,
      'price': double.tryParse(priceController.text) ?? 0,
      'quantity': int.tryParse(quantityController.text) ?? 0,
      'minQuantity': int.tryParse(minQuantityController.text) ?? 1,
      'image': imageUrl ?? '',
    };

    debugPrint("📦 Sending product data: ${jsonEncode(productData)}");

    try {
      final token = await AuthService.getToken();
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/api/product/create'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(productData),
      );

      debugPrint("📥 Response status: ${response.statusCode}");
      debugPrint("📥 Response body: ${response.body}");

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('product_added_success'.tr())));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('failed_add_product'.tr())));
      }
    } catch (e, st) {
      debugPrint("❌ Submit error: $e");
      debugPrint("📌 StackTrace: $st");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('error_submitting_product'.tr())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final orange = Colors.orange;

    return Scaffold(
      appBar: AppBar(title: Text('add_product'.tr()), backgroundColor: orange),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'product_name'.tr()),
                validator: (value) =>
                    value!.isEmpty ? 'enter_product_name'.tr() : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: descController,
                decoration: InputDecoration(labelText: 'description'.tr()),
                validator: (value) =>
                    value!.isEmpty ? 'enter_description'.tr() : null,
              ),
              const SizedBox(height: 12),
              categories.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<String>(
                      value: selectedCategory,
                      hint: Text('select_category'.tr()),
                      items: categories.map<DropdownMenuItem<String>>((cat) {
                        return DropdownMenuItem(
                          value: cat['categoryname'],
                          child: Text(cat['categoryname']),
                        );
                      }).toList(),
                      onChanged: (value) =>
                          setState(() => selectedCategory = value),
                      validator: (value) =>
                          value == null ? 'select_category_error'.tr() : null,
                    ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: isUploading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.upload),
                label: Text(
                  isUploading ? 'uploading'.tr() : 'pick_upload_image'.tr(),
                ),
                onPressed: isUploading ? null : pickAndUploadFile,
              ),
              if (imageUrl != null && !isUploading)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Image.network(
                    imageUrl!,
                    height: 150,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) =>
                        Text('failed_load_image'.tr()),
                  ),
                ),
              const SizedBox(height: 12),
              TextFormField(
                controller: priceController,
                decoration: InputDecoration(labelText: 'base_price'.tr()),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'enter_price'.tr() : null,
              ),
              TextFormField(
                controller: minQuantityController,
                decoration: InputDecoration(labelText: 'Minimum Quantity'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'Enter minimum quantity' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: quantityController,
                decoration: InputDecoration(labelText: 'quantity'.tr()),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'enter_quantity'.tr() : null,
              ),
              const SizedBox(height: 20),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: orange,
                  side: BorderSide(color: orange),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: submitProduct,
                child: Text(
                  'add_product_btn'.tr(),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
