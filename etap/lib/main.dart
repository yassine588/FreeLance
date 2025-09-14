import 'package:flutter/material.dart';
import 'package:etap/Components/LoginPage.dart';
import 'package:etap/Components/Signup.dart';
import 'package:etap/Components/ChauffeurDashboard.dart';
import 'package:etap/Components/VehiclesPage.dart';
import 'package:etap/Components/ExplorePage.dart';
import 'package:etap/Components/AdminApprovalPage.dart';
import 'package:etap/Components/home.dart';
import 'package:etap/Components/chefParkPage.dart';
import 'package:etap/Components/OperatorPage.dart';
import 'package:etap/Components/reparation.dart';
import 'package:etap/Components/AddVehiclePage.dart';
import 'package:etap/Components/AddAssignmentPage.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ETAP Fleet Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/signup': (context) => SignupPage(),
        '/home': (context) => EtapPage(),
        '/vehicles': (context) => VehiclesPage(),
        '/explore': (context) => ExplorePage(),
        '/assignments': (context) =>const AddAssignmentPage(),
         '/addVehicle': (context) {
    final userData = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    return AddVehiclePage(userData: userData);
  },
        '/adminApproval': (context) => AdminApprovalPage(),
        '/chefPark': (context) {
          final userData = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return ChefParkPage(userData: userData);
        },
        '/operateur': (context) => OperatorPage(),
        '/chauffeurDashboard': (context) {
          final userData = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return ChauffeurDashboard(userData: userData);
        },
         '/addReparation': (context) {
    final userData = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    return AddReparationPage(userData: userData);
  },
      },
    );
  }
}

// Simple HomePage for non-chauffeur users
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ETAP Dashboard'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to ETAP Fleet Management',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),
            Wrap(
              spacing: 20,
              runSpacing: 20,
              children: [
                _buildDashboardCard(
                  context,
                  title: 'Vehicles',
                  icon: Icons.directions_car,
                  route: '/vehicles',
                  color: Colors.blue,
                ),
                _buildDashboardCard(
                  context,
                  title: 'Dashboard',
                  icon: Icons.dashboard,
                  route: '/explore',
                  color: Colors.green,
                ),
                _buildDashboardCard(
                  context,
                  title: 'Admin Approval',
                  icon: Icons.admin_panel_settings,
                  route: '/adminApproval',
                  color: Colors.orange,
                ),
                _buildDashboardCard(
                  context,
                  title: 'Logout',
                  icon: Icons.logout,
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/');
                  },
                  color: Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(BuildContext context, {
    required String title,
    required IconData icon,
    String? route,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap ?? () {
          if (route != null) {
            Navigator.pushNamed(context, route);
          }
        },
        child: Container(
          width: 150,
          height: 150,
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}