import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'profile_page.dart';
import 'login_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:health_companion_app/providers/theme_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? _user;
  String _displayName = 'Guest';
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
      print('User is logged in with UID: ${_user!.uid}');

      _loadUserProfile();
    } else {
      print('No user is logged in.');
    }
    setState(() {});
  }

  Future<void> _loadUserProfile() async {
    if (_user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(_user!.uid)
            .get();

        final data = userDoc.data() as Map<String, dynamic>;

        print('User document data: $data');

        setState(() {
          _displayName = data.containsKey('name')
              ? data['name']
              : _user!.displayName ?? 'User';

          _profilePictureUrl =
              data.containsKey('profileImage') ? data['profileImage'] : '';

          if (kIsWeb && data.containsKey('webProfileImage')) {
            _webProfileImage =
                Uint8List.fromList(data['webProfileImage'].cast<int>());
          }
        });

        print('Loaded display name: $_displayName');
        print('Loaded profile picture URL: $_profilePictureUrl');
      } catch (e) {
        print('Error loading user profile: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Image.asset('assets/images/app_logo.png', height: 40),
        ),
        actions: [
          IconButton(
            icon: CircleAvatar(
              backgroundImage: _profilePictureUrl.isNotEmpty
                  ? NetworkImage(_profilePictureUrl)
                  : const AssetImage('assets/images/default_profile.png')
                      as ImageProvider,
              child: _profilePictureUrl.isEmpty
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
          IconButton(
            icon: Icon(
                themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode),
            onPressed: () {
              themeProvider.toggleTheme();
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
