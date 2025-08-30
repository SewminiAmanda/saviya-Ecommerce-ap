import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;

class UploadVerificationPage extends StatefulWidget {
  final int userId;

  const UploadVerificationPage({super.key, required this.userId});

  @override
  State<UploadVerificationPage> createState() => _UploadVerificationPageState();
}

class _UploadVerificationPageState extends State<UploadVerificationPage> {
  File? _file;
  bool _isUploading = false;
  PlatformFile? _pickedInfo;
  String? _fileUrl;

  final SupabaseClient supabase = Supabase.instance.client;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      withData: true,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _pickedInfo = result.files.single;
        _file = File(result.files.single.path!);
      });
    }
  }

  Future<void> _uploadAndSubmit() async {
    if (_pickedInfo == null || _pickedInfo!.bytes == null) return;

    setState(() => _isUploading = true);

    try {
      final fileName = '${widget.userId}_${p.basename(_pickedInfo!.name)}';

      // Upload to Supabase Storage
      await supabase.storage
          .from('verification_docs') // ✅ replace with your actual bucket
          .uploadBinary(
            fileName,
            _pickedInfo!.bytes!,
            fileOptions: const FileOptions(upsert: true),
          );

      // Get public URL
      final publicUrl = supabase.storage
          .from('verification_docs')
          .getPublicUrl(fileName);

      setState(() => _fileUrl = publicUrl);

      // Send URL to your backend
      final response = await http.put(
        Uri.parse(
          'http://localhost:8080/api/users/update-verification-doc/${widget.userId}',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'verification_docs': publicUrl}),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Verification document uploaded successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload your verification documents'),
        backgroundColor: Colors.orange,
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.verified_user, size: 80, color: Colors.orange),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _isUploading ? null : _pickFile,
                icon: const Icon(Icons.attach_file),
                label: const Text('Select File'),
              ),
              const SizedBox(height: 20),
              if (_pickedInfo != null)
                Text(
                  'Selected: ${_pickedInfo!.name}',
                  style: const TextStyle(fontSize: 14),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isUploading ? null : _uploadAndSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 12,
                  ),
                ),
                child: _isUploading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Upload & Submit'),
              ),
              const SizedBox(height: 40),
              const Text(
                "This information is used only for verification purposes.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
