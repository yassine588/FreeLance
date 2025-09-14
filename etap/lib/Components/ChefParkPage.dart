import 'package:flutter/material.dart';
import 'package:etap/Components/reparation.dart';
import 'package:etap/Components/AddVehiclePage.dart'; 
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChefParkPage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const ChefParkPage({Key? key, required this.userData}) : super(key: key);

  @override
  State<ChefParkPage> createState() => _ChefParkPageState();
}

class _ChefParkPageState extends State<ChefParkPage> {
  int _currentIndex = 0;
  late List<Widget> _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = [
      RepairsTab(userData: widget.userData),
      const PannesTab(),
      const PiecesTab(),
    ];
  }

  void _logout() {
    Navigator.of(context).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Park Management'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.build),
            label: 'Repairs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.warning),
            label: 'Breakdowns',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Parts',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0 
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddReparationPage(userData: widget.userData),
                  ),
                );
              },
              backgroundColor: Colors.orange,
              child: const Icon(Icons.add, color: Colors.white),
              tooltip: 'Add New Repair',
            )
          : null,
    );
  }
}

class RepairsTab extends StatefulWidget {
  final Map<String, dynamic> userData;

  const RepairsTab({Key? key, required this.userData}) : super(key: key);

  @override
  _RepairsTabState createState() => _RepairsTabState();
}

class _RepairsTabState extends State<RepairsTab> {
  final String apiBaseUrl = 'http://192.168.1.12:3000';
  List<dynamic> _repairs = [];
  Map<String, String> _vehicleNames = {}; // Store vehicle names by ID
  bool _isLoading = true;
  bool _isLoadingVehicles = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _gettAllReparations();
  }

  Future<void> _gettAllReparations() async {
    try {
      setState(() {
        _isLoading = true;
        _isLoadingVehicles = true;
      });

      final response = await http.get(
        Uri.parse("$apiBaseUrl/reparations"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("All Reparations: $data");
        
        List<dynamic> repairsList = [];
        if (data is List) {
          repairsList = data;
        } else if (data is Map && data.containsKey('reparations')) {
          repairsList = data['reparations'] is List ? data['reparations'] : [];
        } else if (data is Map && data.containsKey('data')) {
          repairsList = data['data'] is List ? data['data'] : [];
        }

        setState(() {
          _repairs = repairsList;
        });

        // Fetch vehicle names for all repairs
        await _fetchVehicleNames(repairsList);

        setState(() {
          _isLoading = false;
          _isLoadingVehicles = false;
          _errorMessage = '';
        });
      } else {
        setState(() {
          _isLoading = false;
          _isLoadingVehicles = false;
          _errorMessage = 'Failed to load reparations: ${response.statusCode}';
        });
      }
    } catch (e) {
      print("Error fetching reparations: $e");
      setState(() {
        _isLoading = false;
        _isLoadingVehicles = false;
        _errorMessage = 'Connection error: $e';
      });
    }
  }

  Future<void> _fetchVehicleNames(List<dynamic> repairs) async {
    final vehicleIds = repairs.map((repair) {
      final vehicleId = repair['vehicule']?.toString();
      return vehicleId;
    }).where((id) => id != null).toSet().toList();

    for (final vehicleId in vehicleIds) {
      if (vehicleId != null && !_vehicleNames.containsKey(vehicleId)) {
        try {
          final response = await http.get(
            Uri.parse("$apiBaseUrl/vehicules/$vehicleId"),
          );

          if (response.statusCode == 200) {
            final vehicleData = jsonDecode(response.body);
            final vehicleName = '${vehicleData['marque'] ?? 'Unknown'} ${vehicleData['modele'] ?? ''}';
            
            setState(() {
              _vehicleNames[vehicleId] = vehicleName;
            });
          } else {
            setState(() {
              _vehicleNames[vehicleId] = 'Unknown Vehicle';
            });
          }
        } catch (e) {
          print("Error fetching vehicle $vehicleId: $e");
          setState(() {
            _vehicleNames[vehicleId] = 'Unknown Vehicle';
          });
        }
      }
    }
  }

  String _getVehicleName(String vehicleId) {
    return _vehicleNames[vehicleId] ?? 'Loading vehicle...';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'EN_COURS':
        return Colors.blue;
      case 'TERMINEE':
        return Colors.green;
      case 'ANNULEE':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'EN_COURS':
        return Icons.build;
      case 'TERMINEE':
        return Icons.check_circle;
      case 'ANNULEE':
        return Icons.cancel;
      default:
        return Icons.build;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Repair Management',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddReparationPage(userData: widget.userData),
                        ),
                      );
                    },
                    icon: const Icon(Icons.build),
                    label: const Text('Add Repair'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddVehiclePage(userData: widget.userData),
                        ),
                      );
                    },
                    icon: const Icon(Icons.directions_car),
                    label: const Text('Add Vehicle'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(),
        
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage.isNotEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error, size: 64, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(
                            _errorMessage,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _gettAllReparations,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : _repairs.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.build, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'No repairs found',
                                style: TextStyle(fontSize: 18, color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _gettAllReparations,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _repairs.length,
                            itemBuilder: (context, index) {
                              final repair = _repairs[index] is Map 
                                  ? Map<String, dynamic>.from(_repairs[index] as Map) 
                                  : <String, dynamic>{};
                              
                              final vehicleId = repair['vehicule']?.toString();
                              final vehicleName = vehicleId != null 
                                  ? _getVehicleName(vehicleId)
                                  : 'Unknown Vehicle';

                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: ListTile(
                                  leading: Icon(
                                    _getStatusIcon(repair['etat'] ?? 'UNKNOWN'),
                                    color: _getStatusColor(repair['etat'] ?? 'UNKNOWN'),
                                    size: 32,
                                  ),
                                  title: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Repair #${repair['_id']?.substring(0, 8) ?? 'N/A'}'),
                                      Text(
                                        vehicleName,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Status: ${repair['etat'] ?? 'Unknown'}'),
                                      if (repair['dateDebut'] != null) 
                                        Text('Started: ${_formatDate(repair['dateDebut'])}'),
                                      if (repair['dateFin'] != null) 
                                        Text('Finished: ${_formatDate(repair['dateFin'])}'),
                                      if (repair['cout'] != null) 
                                        Text('Cost: ${repair['cout']} DT'),
                                      if (repair['priorite'] != null) 
                                        Text('Priority: ${repair['priorite']}'),
                                    ],
                                  ),
                                  trailing: _isLoadingVehicles
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                      : const Icon(Icons.chevron_right),
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Viewing repair details for $vehicleName')),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
        ),
      ],
    );
  }
}

class PannesTab extends StatelessWidget {
  const PannesTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        ListTile(
          leading: Icon(Icons.warning, color: Colors.red),
          title: Text('Breakdown #456 - Engine failure'),
          subtitle: Text('Vehicle: Toyota Hilux - Reported: 12/05/2023'),
        ),
        ListTile(
          leading: Icon(Icons.warning, color: Colors.orange),
          title: Text('Breakdown #457 - Brake issues'),
          subtitle: Text('Vehicle: Renault Kangoo - Being repaired'),
        ),
      ],
    );
  }
}

class PiecesTab extends StatelessWidget {
  const PiecesTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        ListTile(
          leading: Icon(Icons.settings, color: Colors.purple),
          title: Text('Engine Oil - 10W40'),
          subtitle: Text('Quantity: 25 units - Last ordered: 10/05/2023'),
        ),
        ListTile(
          leading: Icon(Icons.settings, color: Colors.purple),
          title: Text('Brake Pads - Front'),
          subtitle: Text('Quantity: 8 pairs - Need to order more'),
        ),
        ListTile(
          leading: Icon(Icons.settings, color: Colors.purple),
          title: Text('Air Filter'),
          subtitle: Text('Quantity: 15 units - In stock'),
        ),
      ],
    );
  }
}
