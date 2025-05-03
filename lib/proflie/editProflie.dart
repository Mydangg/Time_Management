import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:time_management/proflie/theme.dart';

class EditProfilePage extends StatefulWidget {
  final String uid;

  const EditProfilePage({super.key, required this.uid});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  File? _selectedImage;
  String? _photoUrl;
  bool _isLoading = true;
  Uint8List? _webImage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      DocumentSnapshot doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.uid)
              .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        _nameController.text = data['name'] ?? '';
        _emailController.text = data['email'] ?? '';
        _phoneController.text = data['phone'] ?? '';
        _photoUrl = data.containsKey('photoUrl') ? data['photoUrl'] : null;
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error Loading Data: $e")));
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _pickImage() async {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      if (kIsWeb) {
        // Trên Web, sử dụng Uint8List
        final bytes = await picked.readAsBytes();
        setState(() {
          _selectedImage = null; // Xóa `File` nếu có
          _photoUrl = null; // Xóa URL cũ
          _webImage = bytes; // Lưu ảnh dưới dạng Uint8List
        });
      } else {
        // Trên Mobile/Desktop, sử dụng File
        setState(() {
          _selectedImage = File(picked.path);
          _webImage = null; // Xóa Uint8List nếu có
        });
      }
    }
  }

  Future<String?> _uploadImage() async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child(
        'profile_images/${widget.uid}.jpg',
      );

      if (kIsWeb && _webImage != null) {
        // Upload ảnh từ Uint8List (Web)
        final uploadTask = await storageRef.putData(_webImage!);
        final downloadUrl = await uploadTask.ref.getDownloadURL();
        print('Uploaded Image URL (Web): $downloadUrl');
        return downloadUrl;
      } else if (_selectedImage != null) {
        // Upload ảnh từ File (Mobile/Desktop)
        final uploadTask = await storageRef.putFile(_selectedImage!);
        final downloadUrl = await uploadTask.ref.getDownloadURL();
        print('Uploaded Image URL (Mobile/Desktop): $downloadUrl');
        return downloadUrl;
      } else {
        throw Exception('No image selected');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Image Update Error: $e")));
      return null;
    }
  }

  void _saveProfile() async {
    try {
      if (_nameController.text.trim().isEmpty ||
          _emailController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please Enter Full Information")),
        );
        return;
      }

      String? photoUrl = _photoUrl;

      if (_selectedImage != null) {
        photoUrl = await _uploadImage();
        print('New Photo URL: $photoUrl'); // In URL ảnh mới
        setState(() {
          _photoUrl = photoUrl; // Cập nhật URL ảnh
        });
      }

      await FirebaseFirestore.instance.collection('users').doc(widget.uid).set({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'photoUrl': _photoUrl ?? '', // Thêm giá trị mặc định nếu chưa có
      }, SetOptions(merge: true));
      print('Photo URL saved to Firestore: $_photoUrl');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Updated Successfully!")));

      Navigator.pop(context); // Quay lại trang trước
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Update Failed: $e")));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Update Information"),
        // backgroundColor: Colors.white,
        // foregroundColor: Colors.black87,
        elevation: 1,
        actions: [
          IconButton(
            onPressed: _saveProfile,
            icon: const Icon(Icons.check),
            tooltip: "Update",
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child: Column(
                  children: [
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage:
                                _webImage != null
                                    ? MemoryImage(_webImage!)
                                    : _selectedImage != null
                                    ? FileImage(_selectedImage!)
                                    : (_photoUrl != null &&
                                                _photoUrl!.isNotEmpty
                                            ? NetworkImage(
                                              '$_photoUrl?${DateTime.now().millisecondsSinceEpoch}',
                                            )
                                            : const AssetImage(
                                              'assets/images/app_logo.png',
                                            ))
                                        as ImageProvider,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 4,
                            child: ClipOval(
                              child: Material(
                                color: Colors.blueAccent,
                                child: InkWell(
                                  splashColor: Colors.white,
                                  onTap: _pickImage,
                                  child: const SizedBox(
                                    width: 32,
                                    height: 32,
                                    child: Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    buildLabel("Username"),
                    buildTextField(
                      _nameController,
                      "Enter username",
                      Icons.person,
                    ),
                    const SizedBox(height: 20),
                    buildLabel("Email"),
                    buildTextField(
                      _emailController,
                      "Entern email",
                      Icons.email,
                    ),
                    const SizedBox(height: 20),
                    buildLabel("Phone Number"),
                    buildTextField(
                      _phoneController,
                      "Enter phone number",
                      Icons.phone,
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),
              ),
    );
  }

  Widget buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget buildTextField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.deepPurple),
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
