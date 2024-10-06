import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class PharmacyListPage extends StatefulWidget {
  const PharmacyListPage({super.key});

  @override
  _PharmacyListPageState createState() => _PharmacyListPageState();
}

class _PharmacyListPageState extends State<PharmacyListPage> {
  bool _isLoggedIn = false;
  bool _showWarning = false;
  Timer? _warningTimer;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  @override
  void dispose() {
    _warningTimer?.cancel();
    super.dispose();
  }

  void _checkLoginStatus() {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      _isLoggedIn = user != null;
      if (!_isLoggedIn) {
        _showWarning = true;
        _warningTimer = Timer(Duration(seconds: 10), () {
          Navigator.pushReplacementNamed(context, '/');
        });
      }
    });
  }

  Future<void> _showUnavailableDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Unavailable'),
          content: Text('Pharmacy currently unavailable, try again later.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );

    await Future.delayed(Duration(seconds: 10));
    Navigator.of(context).pop();
  }

  Widget _buildStarRating(double rating) {
    int fullStars = rating.floor();
    bool halfStar = (rating - fullStars) >= 0.5;

    List<Widget> stars = [];

    for (int i = 0; i < 5; i++) {
      if (i < fullStars) {
        stars.add(Icon(Icons.star, color: Colors.yellow, size: 20));
      } else if (i == fullStars && halfStar) {
        stars.add(Icon(Icons.star_half, color: Colors.yellow, size: 20));
      } else {
        stars.add(Icon(Icons.star_border, color: Colors.yellow, size: 20));
      }
    }

    return Row(
      children: stars,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pharmacy List'),
      ),
      body: Stack(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance.collection('pharmacies').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final pharmacies = snapshot.data?.docs ?? [];

              return ListView.builder(
                itemCount: pharmacies.length,
                itemBuilder: (context, index) {
                  var pharmacy = pharmacies[index];
                  var name = pharmacy['name'];
                  var logoUrl = pharmacy['pharmaLogo'];
                  var rating = double.parse(pharmacy['rating']);
                  var numReviews = pharmacy['numReviews'];

                  return Card(
                    margin: EdgeInsets.all(10),
                    child: ListTile(
                      leading: Image.network(logoUrl, width: 50, height: 50),
                      title: Text(name, style: TextStyle(fontSize: 18)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStarRating(rating),
                          Text('$rating | Reviews: $numReviews'),
                        ],
                      ),
                      trailing: ElevatedButton.icon(
                        onPressed: () {
                          if (name == "Nefarious Remedies") {
                            Navigator.pushNamed(
                                context, '/nefarious_remedies_medpage');
                          } else {
                            _showUnavailableDialog();
                          }
                        },
                        icon: Icon(Icons.shopping_cart),
                        label: Text('Shop'),
                      ),
                    ),
                  );
                },
              );
            },
          ),
          if (_showWarning)
            Positioned.fill(
              child: AlertDialog(
                title: Text('Log In for Best Experience'),
                content: Text(
                    'For a secure and personalized experience, we recommend logging in before ordering.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: Text('Log In'),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _showWarning = false;
                      });
                      _warningTimer?.cancel();
                    },
                    child: Text('Continue Ordering'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
