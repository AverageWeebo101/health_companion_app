import 'dart:io' as io;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EditProfilePage extends StatefulWidget {
  final String userId;
  const EditProfilePage({Key? key, required this.userId}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactNumberController =
      TextEditingController();
  String _bloodType = 'A+';
  XFile? _profileImage;
  Uint8List? _webImageData;
  String? _currentProfileImageUrl;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .get();

    setState(() {
      _nameController.text = userDoc.get('name');
      _emailController.text = userDoc.get('email');
      _contactNumberController.text = userDoc.get('contactNumber');
      _bloodType = userDoc.get('bloodType');
      _currentProfileImageUrl = userDoc.get('profileImage');
    });
  }

  Future<void> _saveProfile(BuildContext context) async {
    setState(() {
      _isSaving = true;
    });

    String? profileImageUrl = _currentProfileImageUrl;

    if (_profileImage != null) {
      profileImageUrl = await _uploadProfileImage(widget.userId);
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .update({
      'name': _nameController.text,
      'email': _emailController.text,
      'contactNumber': _contactNumberController.text,
      'bloodType': _bloodType,
      'profileImage': profileImageUrl ?? '',
    });

    setState(() {
      _isSaving = false;
    });

    Navigator.pop(context);
  }

  Future<String?> _uploadProfileImage(String userId) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child(
          'profile_images/${FirebaseAuth.instance.currentUser!.uid}.jpg');

      if (kIsWeb && _webImageData != null) {
        final uploadTask = storageRef.putData(_webImageData!);
        final snapshot = await uploadTask;
        String downloadUrl = await snapshot.ref.getDownloadURL();
        return downloadUrl;
      } else if (!kIsWeb && _profileImage != null) {
        final file = io.File(_profileImage!.path);
        final uploadTask = storageRef.putFile(file);
        final snapshot = await uploadTask;
        String downloadUrl = await snapshot.ref.getDownloadURL();
        return downloadUrl;
      }
    } catch (e) {
      print('Error uploading profile image: $e');
      return null;
    }
    return null;
  }

  Future<void> _pickProfileImage() async {
    final ImagePicker picker = ImagePicker();
    XFile? pickedFile;

    if (kIsWeb) {
      pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _webImageData = bytes;
          _profileImage = pickedFile;
        });
      }
    } else {
      pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _profileImage = pickedFile;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickProfileImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: kIsWeb
                      ? (_webImageData != null
                          ? MemoryImage(_webImageData!)
                          : null)
                      : (_profileImage != null
                          ? FileImage(io.File(_profileImage!.path))
                          : null),
                  child: _profileImage == null &&
                          (_currentProfileImageUrl == null ||
                              _currentProfileImageUrl!.isEmpty)
                      ? const Icon(Icons.person, size: 50)
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _contactNumberController,
                decoration: const InputDecoration(labelText: 'Contact Number'),
                keyboardType: TextInputType.number,
                maxLength: 11,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _bloodType,
                decoration: const InputDecoration(labelText: 'Blood Type'),
                items: ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-']
                    .map((bloodType) => DropdownMenuItem(
                          value: bloodType,
                          child: Text(bloodType),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _bloodType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isSaving ? null : () => _saveProfile(context),
                child: _isSaving
                    ? const CircularProgressIndicator()
                    : const Text('Save Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
