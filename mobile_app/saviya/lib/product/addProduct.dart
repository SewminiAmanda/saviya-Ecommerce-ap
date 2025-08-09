import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

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
    // Request runtime permissions (for Android 13+ and below)
    final status = await Permission.photos.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Photo permission is required.")));
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result == null || result.files.single.path == null) {
      print("No file selected.");
      return;
    }

    setState(() {
      isUploading = true;
      imageUrl = null;
    });

    try {
      final file = await compute(loadFile, result.files.single.path!);
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${result.files.single.name}';

      final uploadedPath = await supabase.storage
          .from('products')
          .upload(fileName, file);

      if (uploadedPath.isEmpty) {
        throw Exception('Upload failed or empty path');
      }

      final publicUrl = supabase.storage
          .from('products')
          .getPublicUrl(fileName);

      if (mounted) {
        setState(() {
          imageUrl = publicUrl;
          isUploading = false;
        });
      }

      print("Uploaded image URL: $imageUrl");
    } catch (e) {
      print('Exception during file upload: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('File upload failed: $e')));
      if (mounted) {
        setState(() => isUploading = false);
      }
    }
  }

  Future<void> submitProduct() async {
    if (!_formKey.currentState!.validate() || selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    if (isUploading) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please wait for the image to finish uploading'),
        ),
      );
      return;
    }

    final Map<String, dynamic> productData = {
      'userId': widget.userId,
      'productName': nameController.text,
      'description': descController.text,
      'categoryName': selectedCategory,
      'price': double.parse(priceController.text),
      'quantity': int.parse(quantityController.text),
      'image': imageUrl ?? '',
    };

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/api/product/create'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(productData),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Product added successfully')));
        Navigator.pop(context);
      } else {
        print(response.body);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to add product')));
      }
    } catch (e) {
      print('Error submitting product: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error submitting product')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final orange = Colors.orange;

    return Scaffold(
      appBar: AppBar(title: Text('Add New Product'), backgroundColor: orange),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Product Name'),
                validator: (value) =>
                    value!.isEmpty ? 'Enter product name' : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: descController,
                decoration: InputDecoration(labelText: 'Description'),
                validator: (value) =>
                    value!.isEmpty ? 'Enter description' : null,
              ),
              SizedBox(height: 12),
              categories.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<String>(
                      value: selectedCategory,
                      hint: Text('Select Category'),
                      items: categories.map<DropdownMenuItem<String>>((cat) {
                        return DropdownMenuItem(
                          value: cat['categoryname'],
                          child: Text(cat['categoryname']),
                        );
                      }).toList(),
                      onChanged: (value) =>
                          setState(() => selectedCategory = value),
                      validator: (value) =>
                          value == null ? 'Select category' : null,
                    ),
              SizedBox(height: 12),
              OutlinedButton.icon(
                icon: isUploading
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(Icons.upload),
                label: Text(
                  isUploading ? 'Uploading...' : 'Pick & Upload Image',
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
                      return Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) =>
                        Text('Failed to load image'),
                  ),
                ),
              SizedBox(height: 12),
              TextFormField(
                controller: priceController,
                decoration: InputDecoration(labelText: 'Base Price'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Enter price' : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: quantityController,
                decoration: InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Enter quantity' : null,
              ),
              SizedBox(height: 20),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: orange,
                  side: BorderSide(color: orange),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: submitProduct,
                child: Text('Add Product', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
