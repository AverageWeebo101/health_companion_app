import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_profile_page.dart';
import 'activity_log_page.dart';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final User? user = FirebaseAuth.instance.currentUser;
  String _name = '';
  String _email = '';
  String _contactNumber = '';
  String _bloodType = '';
  String _profilePictureUrl = '';
  Uint8List? _webImageData;

  @override
  void initState() {
    super.initState();
    if (user != null) {
      _loadUserProfile();
    } else {
      _showErrorDialog('User not logged in. Please log in again.');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      if (userDoc.exists) {
        var data = userDoc.data() as Map<String, dynamic>;
        setState(() {
          _name = data['name'] ?? 'No name';
          _email = data['email'] ?? 'No email';
          _contactNumber = data['contactNumber'] ?? 'No contact number';
          _bloodType = data['bloodType'] ?? 'No blood type';
          _profilePictureUrl = data['profileImage'] ?? '';

          print('Profile Image URL: $_profilePictureUrl');

          if (kIsWeb && data['webProfileImage'] != null) {
            _webImageData =
                Uint8List.fromList(data['webProfileImage'].cast<int>());
            print('Web Image Data loaded.');
          }
        });
      } else {
        _showErrorDialog('User profile not found.');
      }
    } catch (e) {
      _showErrorDialog('Failed to load profile: $e');
    }
  }

  Future<void> _deleteAccount() async {
    bool confirmed = await _showDeleteConfirmationDialog();
    if (!confirmed) return;

    try {
      await user!.delete();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .delete();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } catch (e) {
      _showErrorDialog('Failed to delete account. Please try again.');
    }
  }

  Future<bool> _showDeleteConfirmationDialog() async {
    return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Delete Account'),
              content: const Text(
                  'Are you sure you want to delete your account? This action is irreversible.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/');
            },
          )
        ],
      ),
      body: user == null
          ? const Center(child: Text('User not logged in.'))
          : _buildProfileContent(),
    );
  }

  Widget _buildProfileContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: _profilePictureUrl.isNotEmpty
                ? NetworkImage(
                    '$_profilePictureUrl?v=${DateTime.now().millisecondsSinceEpoch}')
                : const AssetImage('assets/images/default_profile.png')
                    as ImageProvider,
            onBackgroundImageError: (error, stackTrace) {
              print('Error loading profile image: $error');
            },
            child: _profilePictureUrl.isEmpty
                ? const Icon(Icons.person, size: 50)
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            _name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            _email,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Contact Number: $_contactNumber',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Blood Type: $_bloodType',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfilePage(userId: user!.uid),
                ),
              );
            },
            child: const Text('Edit Profile'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ActivityLogPage(),
                ),
              );
            },
            child: const Text('Check Account Activity Log'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _logout,
            child: const Text('Logout'),
          ),
          const Spacer(),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: _deleteAccount,
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }
}
