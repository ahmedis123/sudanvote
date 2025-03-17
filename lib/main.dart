import 'package:flutter/material.dart';
import '/screens/home_screen.dart';

import '/screens/home_election_list.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/login_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/voteing_screen.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(primarySwatch: Colors.teal),
    routes: {
      '/login': ((context) => const LoginScreen()),
      '/home': ((context) => const HomeScreen()),
      '/register': ((context) => const RegistrationScreen()),
      '/dashboard': ((context) => const AdminDashboard()),
      '/vote': ((context) => const VotingScreen()),
      '/election': ((context) => ElectionsScreen())
    },
    home: const LoginScreen(),
  ));
}
