import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_page.dart';
import 'login_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? _user;
  String _displayName = '';
  String _profilePictureUrl = '';
  Uint8List? _webProfileImage;

  @override
  void initState() {
    super.initState();
    _checkUserLoggedIn();
  }

  void _checkUserLoggedIn() {
    _user = FirebaseAuth.instance.currentUser;

    if (_user != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .get()
          .then((docSnapshot) {
        if (docSnapshot.exists) {
        } else {}
      });

      setState(() {});
    }
  }

  Future<void> _loadUserProfile() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(_user!.uid)
        .get();

    setState(() {
      _displayName = userDoc.get('name') ?? _user!.displayName ?? 'User';
      _profilePictureUrl = userDoc.get('profileImage') ?? '';
      if (kIsWeb && userDoc.get('webProfileImage') != null) {
        _webProfileImage =
            Uint8List.fromList(userDoc.get('webProfileImage').cast<int>());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Image.asset('assets/images/app_logo.png', height: 40),
        ),
        actions: [
          IconButton(
            icon: CircleAvatar(
              backgroundImage: kIsWeb
                  ? (_webProfileImage != null
                      ? MemoryImage(_webProfileImage!)
                      : null)
                  : (_profilePictureUrl.isNotEmpty
                      ? NetworkImage(_profilePictureUrl)
                      : const AssetImage('assets/images/default_profile.png')
                          as ImageProvider),
              child: _profilePictureUrl.isEmpty && _webProfileImage == null
                  ? const Icon(Icons.person, size: 40)
                  : null,
            ),
            onPressed: () {
              if (_user != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              }
            },
          ),
        ],
        leading: _user == null
            ? IconButton(
                icon: const Icon(Icons.login),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
              )
            : null,
      ),
      body: _buildHomeContent(),
    );
  }

  Widget _buildHomeContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _user != null ? 'Welcome, $_displayName' : 'Welcome, Guest',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 10),
              CircleAvatar(
                backgroundImage: kIsWeb
                    ? (_webProfileImage != null
                        ? MemoryImage(_webProfileImage!)
                        : null)
                    : (_profilePictureUrl.isNotEmpty
                        ? NetworkImage(_profilePictureUrl)
                        : const AssetImage('assets/images/default_profile.png')
                            as ImageProvider),
                child: _profilePictureUrl.isEmpty && _webProfileImage == null
                    ? const Icon(Icons.person, size: 40)
                    : null,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildClickableIcons(),
        ],
      ),
    );
  }

  Widget _buildClickableIcons() {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      children: [
        _buildIcon(Icons.local_hospital, 'Nearby Healthcare Facilities',
            '/healthcare'),
        _buildIcon(Icons.medication, 'Order Medicine', '/order_medicine'),
        _buildIcon(
            Icons.calendar_today, 'Book an Appointment', '/book_appointment'),
        _buildIcon(Icons.settings, 'Settings', '/settings'),
        _buildIcon(
            Icons.history, 'Transaction History', '/transaction_history'),
      ],
    );
  }

  Widget _buildIcon(IconData icon, String label, String route) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, route);
      },
      child: Column(
        children: [
          Icon(icon, size: 40),
          const SizedBox(height: 10),
          Text(label, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
