import 'package:flutter/material.dart';

// Placeholder pages for navigation
import 'explore_page.dart';
import 'vehicles_page.dart';
import 'chef_park_page.dart';
import 'operator_page.dart';
import 'chauffeur_page.dart';
import 'saved_page.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({Key? key}) : super(key: key);

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _selectedIndex = 0;

  // List of pages for navigation
  final List<Widget> _pages = const [
    ExplorePage(),
    VehiclesPage(),
    ChefParkPage(),
    OperatorPage(),
    ChauffeurPage(),
    SavedPage(),
  ];

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
            _selectedIndex = index;
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
            label: 'Saved',
          ),
        ],
      ),
    );
  }
}