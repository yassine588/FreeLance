import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ExplorePage extends StatefulWidget {
  const ExplorePage({Key? key}) : super(key: key);

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final String apiBaseUrl = 'http://192.168.1.12:3000';
  Map<String, int> _stats = {};
  bool _isLoading = true;
  String _errorMessage = '';
  List<dynamic> _vehicles = [];

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }
  
  Future<void> _fetchStats() async {
  try {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    // Fetch chauffeur count from API
    final chauffeursResponse = await http.get(Uri.parse("$apiBaseUrl/count-chauffeurs"));
    final vehiclesResponse = await http.get(Uri.parse("$apiBaseUrl/vehicules"));
    
    print("Vehicles Response: ${vehiclesResponse.statusCode}, Body: ${vehiclesResponse.body}");

    if (chauffeursResponse.statusCode == 200 && vehiclesResponse.statusCode == 200) {
      final chauffeursData = jsonDecode(chauffeursResponse.body);
      final vehiclesData = jsonDecode(vehiclesResponse.body);
      
      final numberOfDrivers = chauffeursData['count'] ?? 0;
      
      // Correct way to get vehicle count from the API response structure
      final totalvehicles = vehiclesData['vehicules'] != null 
          ? (vehiclesData['vehicules'] as List).length
          : 0;

      setState(() {
        _stats = {
          'vehicles': totalvehicles,
          'drivers': numberOfDrivers,
          'activeRepairs': 5,
          'violations': 2,
        };
        _isLoading = false;
      });
    } else {
      throw Exception('Failed to load data. Drivers: ${chauffeursResponse.statusCode}, Vehicles: ${vehiclesResponse.statusCode}');
    }
  } catch (e) {
    print("Error fetching stats: $e");
    setState(() {
      _isLoading = false;
      _errorMessage = 'Failed to load dashboard data: $e';
      // Fallback values
      _stats = {
        'vehicles': 24,
        'drivers': 0,
        'activeRepairs': 5,
        'violations': 12,
      };
    });
  }
}
  Widget _buildStatCard(String title, int count, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: color),
            const SizedBox(height: 8),
            Text(
              count.toString(),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchStats,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchStats,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Dashboard Overview',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        childAspectRatio: 1.2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildStatCard('Total Vehicles', _stats['vehicles']!, 
                              Icons.directions_car, Colors.blue),
                          _buildStatCard('Drivers', _stats['drivers']!, 
                              Icons.person, Colors.green),
                          _buildStatCard('Active Repairs', _stats['activeRepairs']!, 
                              Icons.build, Colors.orange),
                          _buildStatCard('Violations', _stats['violations']!, 
                              Icons.warning, Colors.red),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Recent Activity',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView(
                          children: const [
                            ListTile(
                              leading: Icon(Icons.build, color: Colors.orange),
                              title: Text('Repair #1234 completed'),
                              subtitle: Text('2 hours ago'),
                            ),
                            ListTile(
                              leading: Icon(Icons.warning, color: Colors.red),
                              title: Text('New violation reported'),
                              subtitle: Text('5 hours ago'),
                            ),
                            ListTile(
                              leading: Icon(Icons.directions_car, color: Colors.blue),
                              title: Text('Vehicle #V001 checked in'),
                              subtitle: Text('Yesterday'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}