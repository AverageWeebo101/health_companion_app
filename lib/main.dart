import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/theme_provider.dart';

import 'pages/home_page.dart';
import 'pages/profile_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/edit_profile_page.dart';
import 'pages/activity_log_page.dart';
import 'pages/tos_page.dart';

import 'pages/order_medicine_pages/pharmacy_list.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  logUserLogin();
  runApp(const MyApp());
}

Future<void> logUserLogin() async {
  User? user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('activityLog')
        .add({
      'timestamp': Timestamp.now(),
      'activity': 'Login',
      'details': 'User logged in',
    });
  }
}

Future<void> logUserEdit(String detailChanges) async {
  User? user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('activityLog')
        .add({
      'timestamp': Timestamp.now(),
      'activity': 'Edit User Details',
      'details': detailChanges,
    });
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ThemeProvider _themeProvider;

  @override
  void initState() {
    super.initState();
    _themeProvider = ThemeProvider();
    _themeProvider.loadTheme();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => _themeProvider,
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            initialRoute: '/',
            routes: {
              '/': (context) => const HomePage(),
              '/login': (context) => const LoginPage(),
              '/register': (context) => const RegistrationPage(),
              '/profile': (context) => const ProfilePage(),
              '/activity_log': (context) => const ActivityLogPage(),
              '/tos': (context) => const TermsOfServicePage(),
              '/order_medicine': (context) => const PharmacyListPage(),
            },
            onGenerateRoute: (settings) {
              if (settings.name == '/edit_profile') {
                final String userId = settings.arguments as String;
                return MaterialPageRoute(
                  builder: (context) => EditProfilePage(userId: userId),
                );
              }
            },
          );
        },
      ),
    );
  }
}
