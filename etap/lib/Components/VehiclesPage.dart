import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VehiclesPage extends StatefulWidget {
  const VehiclesPage({Key? key}) : super(key: key);

  @override
  State<VehiclesPage> createState() => _VehiclesPageState();
}

class _VehiclesPageState extends State<VehiclesPage> {
  final String apiBaseUrl = 'http://192.168.1.12:3000';
  List<dynamic> _vehicles = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchVehicles();
  }
Future<void> _fetchVehicles() async {
  try {
    final response = await http.get(
      Uri.parse("$apiBaseUrl/vehicules"),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("Raw API response: $data"); // Add this for debugging
      
      setState(() {
        if (data is Map && data.containsKey('vehicules')) {
          _vehicles = data['vehicules'] is List ? data['vehicules'] : [];
        } else if (data is Map && data.containsKey('vehicles')) {
          _vehicles = data['vehicles'] is List ? data['vehicles'] : [];
        } else if (data is Map && data.containsKey('data')) {
          _vehicles = data['data'] is List ? data['data'] : [];
        } else if (data is List) {
          _vehicles = data;
        } else {
          _vehicles = [];
        }
        _isLoading = false;
        _errorMessage = '';
      });
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load vehicles: ${response.statusCode}';
      });
    }
  } catch (e) {
    print("Error fetching vehicles: $e");
    setState(() {
      _isLoading = false;
      _errorMessage = 'Connection error: Please check your server';
    });
  }
}

  String _getStatusText(String status) {
    switch (status) {
      case 'DISPONIBLE':
        return 'Available';
      case 'EN_PANNE':
        return 'Broken';
      case 'EN_REPARATION':
        return 'In Repair';
      case 'HORS_SERVICE':
        return 'Out of Service';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'DISPONIBLE':
        return Colors.green;
      case 'EN_PANNE':
        return Colors.red;
      case 'EN_REPARATION':
        return Colors.orange;
      case 'HORS_SERVICE':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  Widget _buildVehicleCard(Map<String, dynamic> vehicle) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 3,
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.directions_car, size: 30, color: Colors.blue),
        ),
        title: Text(
          '${vehicle['marque'] ?? 'Unknown'} ${vehicle['modele'] ?? ''}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(vehicle['immatriculation'] ?? 'No plate'),
            if (vehicle['annee'] != null) Text('Year: ${vehicle['annee']}'),
          ],
        ),
        trailing: Chip(
          label: Text(
            _getStatusText(vehicle['etat'] ?? 'UNKNOWN'),
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          backgroundColor: _getStatusColor(vehicle['etat'] ?? 'UNKNOWN'),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        ),
        onTap: () {
          _showVehicleDetails(vehicle);
        },
      ),
    );
  }

  void _showVehicleDetails(Map<String, dynamic> vehicle) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('${vehicle['marque']} ${vehicle['modele']}'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Plate: ${vehicle['immatriculation']}'),
                if (vehicle['annee'] != null) Text('Year: ${vehicle['annee']}'),
                if (vehicle['couleur'] != null) Text('Color: ${vehicle['couleur']}'),
                if (vehicle['kilometrage'] != null) Text('Mileage: ${vehicle['kilometrage']} km'),
                Text('Status: ${_getStatusText(vehicle['etat'])}'),
                const SizedBox(height: 16),
                Text(
                  'Additional Details',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade700),
                ),
                if (vehicle['dateMiseEnService'] != null) 
                  Text('Service Date: ${vehicle['dateMiseEnService']}'),
                if (vehicle['dernierEntretien'] != null) 
                  Text('Last Maintenance: ${vehicle['dernierEntretien']}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
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
        title: const Text('Vehicles Management'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchVehicles,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Navigate to add vehicle page
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Add vehicle functionality coming soon')),
              );
            },
            tooltip: 'Add Vehicle',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading vehicles...'),
                ],
              ),
            )
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchVehicles,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _vehicles.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.directions_car, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text(
                            'No vehicles found',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add a vehicle or check your connection',
                            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _fetchVehicles,
                            child: const Text('Refresh'),
                          ),
                        ],
                      ),
                    )
                   :RefreshIndicator(
  onRefresh: _fetchVehicles,
  child: ListView.builder(
    itemCount: _vehicles.length,
    itemBuilder: (context, index) {
      final vehicle = _vehicles[index] is Map 
          ? Map<String, dynamic>.from(_vehicles[index] as Map) 
          : <String, dynamic>{};
      return _buildVehicleCard(vehicle);
    },
  ),
),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchVehicles,
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}