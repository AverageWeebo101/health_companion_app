import 'dart:io' as io;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({Key? key}) : super(key: key);

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _contactNumberController =
      TextEditingController();
  String _bloodType = 'A+';
  XFile? _profileImage;
  Uint8List? _webImageData;
  bool _isRegistering = false;

  Future<void> _pickImage() async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
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
                  child: _profileImage == null
                      ? const Icon(Icons.person, size: 50)
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Pick Profile Image'),
              ),
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
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
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
                onPressed: _isRegistering ? null : () => _registerUser(context),
                child: _isRegistering
                    ? const CircularProgressIndicator()
                    : const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickProfileImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = XFile(pickedFile.path);
      });
    }
  }

  Future<void> _registerUser(BuildContext context) async {
    setState(() {
      _isRegistering = true;
    });

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      String? profileImageUrl;

      if (_profileImage != null) {
        profileImageUrl = await _uploadProfileImage(userCredential.user!.uid);
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'name': _nameController.text,
        'email': _emailController.text,
        'contactNumber': _contactNumberController.text,
        'bloodType': _bloodType,
        'profileImage': profileImageUrl ?? '',
      });

      Navigator.pushReplacementNamed(context, '/profile');
    } catch (e) {
      print('Error registering user: $e');
    }

    setState(() {
      _isRegistering = false;
    });
  }
}
