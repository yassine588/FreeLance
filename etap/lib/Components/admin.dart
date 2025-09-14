import 'package:flutter/material.dart';
import 'AdminApprovalPage.dart';
import 'ExplorePage.dart';
import 'VehiclesPage.dart';
import 'ChefParkPage.dart'; 
import 'OperatorPage.dart';
import 'ChauffeurPage.dart';
import 'SavedPage.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({Key? key}) : super(key: key);

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _selectedIndex = 0;

  // Use empty userData or navigate properly
  final Map<String, dynamic> _defaultUserData = {
    'name': 'Admin',
    'id': 'admin',
    'post': 'admin'
  };

  // Initialize pages in initState or build method instead of as const
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      ExplorePage(),
      VehiclesPage(),
      ChefParkPage(userData: _defaultUserData), // Use default data
      OperatorPage(),
      ChauffeurPage(),
      SavedPage(),
    ];
  }

  void _navigateToApprovalPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AdminApprovalPage()),
    );
  }
  void _navigatoToVehiclesPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => VehiclesPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.blueAccent,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            if (index == 5) { // If Saved icon is clicked (index 5)
              _navigateToApprovalPage(context);
            } else if (index == 1) { // If Vehicles icon is clicked (index 1)
              _navigatoToVehiclesPage(context);
            } else {
              _selectedIndex = index;
            }
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.explore),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.commute),
            label: 'Vehicles',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_parking),
            label: 'Chef Park',
          ),
          NavigationDestination(
            icon: Icon(Icons.engineering),
            label: 'Operator',
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Chauffeur',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.bookmark),
            icon: Icon(Icons.bookmark_border),
            label: 'Approvals', 
          ),
        ],
      ),
    );
  }
}