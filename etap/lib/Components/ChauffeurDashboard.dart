import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class ChauffeurDashboard extends StatefulWidget {
  final Map<String, dynamic> userData;

  const ChauffeurDashboard({Key? key, required this.userData}) : super(key: key);

  @override
  _ChauffeurDashboardState createState() => _ChauffeurDashboardState();
}

class _ChauffeurDashboardState extends State<ChauffeurDashboard> {
  final String apiBaseUrl = 'http://192.168.1.12:3000';
  final _formKey = GlobalKey<FormState>();
  List<dynamic> _assignedVehicles = [];
  List<dynamic> _assignments = [];
  bool _loadingVehicles = true;
  bool _loadingAssignments = true;
  String _selectedStatus = 'Available';
  String _selectedVehicle = '';
  DateTime _selectedDate = DateTime.now();
  String _selectedPanneType = 'Mechanical';
  final TextEditingController _descriptionController = TextEditingController();

  final List<String> _statusOptions = ['Available', 'On Duty', 'On Leave'];
  
  // Panne types
  final List<String> _panneTypes = [
    'Mechanical',
    'Electrical',
    'Accident',
    'Flat Tire',
    'Engine Issue',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _fetchAssignedVehicles();
    _fetchAssignmentForDriver();
  }

  void _logout() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/', 
      (route) => false, 
    );
  }

  void _logoutAlternative() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _showLogoutDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop(); 
                _logout();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _fetchAssignedVehicles() async {
    try {
      final response = await http.get(
        Uri.parse("$apiBaseUrl/vehicules/chauffeur/${widget.userData['id']}"),
      );
      print("Vehicles response: ${response.body}");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _assignedVehicles = data['data'] ?? [];
          if (_assignedVehicles.isNotEmpty) {
            _selectedVehicle = _assignedVehicles[0]['_id'];
          }
          _loadingVehicles = false;
        });
      } else {
        throw Exception('Failed to load assigned vehicles');
      }
    } catch (e) {
      print("Error fetching vehicles: $e");
      setState(() => _loadingVehicles = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading vehicles: $e")),
      );
    }
  }

  Future<void> _fetchAssignmentForDriver() async {
    try {
      final response = await http.get(
        Uri.parse("$apiBaseUrl/assignments/driver/${widget.userData['id']}"),
      );
      print("Assignments response: ${response.body}");
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _assignments = data['assignments'] ?? [];
          _loadingAssignments = false;
        });
      } else {
        throw Exception('Failed to load assignments: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching assignments: $e");
      setState(() => _loadingAssignments = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading assignments: $e")),
      );
    }
  }

  Future<void> _reportPanne() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      // Find the selected vehicle
      final vehicle = _assignedVehicles.firstWhere(
        (v) => v['_id'] == _selectedVehicle,
        orElse: () => {},
      );

      if (vehicle.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please select a valid vehicle")),
        );
        return;
      }

      final response = await http.post(
        Uri.parse("$apiBaseUrl/pannes"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "immatriculation": vehicle['immatriculation'],
          "date": _selectedDate.toIso8601String(),
          "description": _descriptionController.text,
          "type_panne": _selectedPanneType,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Breakdown reported successfully")),
        );
        _descriptionController.clear();
      } else {
        throw Exception('Failed to report breakdown: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error reporting breakdown: $e")),
      );
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    try {
      final response = await http.put(
        Uri.parse("$apiBaseUrl/chauffeurs/status"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "chauffeurId": widget.userData['id'],
          "status": newStatus,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _selectedStatus = newStatus;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Status updated to $newStatus")),
        );
      } else {
        throw Exception('Failed to update status: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating status: $e")),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chauffeur Dashboard"),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              _fetchAssignedVehicles();
              _fetchAssignmentForDriver();
            },
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _showLogoutDialog,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome message
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Welcome, ${widget.userData['name']}!",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: _showLogoutDialog,
                  child: Text(
                    "Logout",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            
            // Status Section
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Current Status",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        _buildStatusIndicator(_selectedStatus),
                        SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedStatus,
                            decoration: InputDecoration(
                              labelText: "Update Status",
                              border: OutlineInputBorder(),
                            ),
                            items: _statusOptions.map((String status) {
                              return DropdownMenuItem<String>(
                                value: status,
                                child: Text(status),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                _updateStatus(newValue);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // Report Panne Section
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Report Vehicle Breakdown",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      _loadingVehicles
                          ? Center(child: CircularProgressIndicator())
                          : _assignedVehicles.isEmpty
                              ? Text("No vehicles assigned to you")
                              : DropdownButtonFormField<String>(
                                  value: _selectedVehicle,
                                  decoration: InputDecoration(
                                    labelText: "Select Vehicle",
                                    border: OutlineInputBorder(),
                                  ),
                                  items: _assignedVehicles.map((vehicle) {
                                    return DropdownMenuItem<String>(
                                      value: vehicle['_id'],
                                      child: Text(
                                          "${vehicle['marque']} ${vehicle['modele']} (${vehicle['immatriculation']})"),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _selectedVehicle = newValue!;
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please select a vehicle';
                                    }
                                    return null;
                                  },
                                ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: "Date of Breakdown",
                                border: OutlineInputBorder(),
                                suffixIcon: Icon(Icons.calendar_today),
                              ),
                              controller: TextEditingController(
                                text: DateFormat('yyyy-MM-dd').format(_selectedDate),
                              ),
                              onTap: () => _selectDate(context),
                              readOnly: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select a date';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedPanneType,
                              decoration: InputDecoration(
                                labelText: "Type of Breakdown",
                                border: OutlineInputBorder(),
                              ),
                              items: _panneTypes.map((String type) {
                                return DropdownMenuItem<String>(
                                  value: type,
                                  child: Text(type),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedPanneType = newValue!;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select a breakdown type';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: "Description of the problem",
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please describe the problem';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: _reportPanne,
                          icon: Icon(Icons.report_problem),
                          label: Text("Report Breakdown"),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Assignments Section
            SizedBox(height: 20),
            Text(
              "Your Assignments",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            _loadingAssignments
                ? Center(child: CircularProgressIndicator())
                : _assignments.isEmpty
                    ? Text("No assignments for you")
                    : Expanded(
                        child: ListView.builder(
                          itemCount: _assignments.length,
                          itemBuilder: (context, index) {
                            final assignment = _assignments[index];
                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 6),
                              child: ListTile(
                                leading: Icon(Icons.assignment, size: 40, color: Colors.blue),
                                title: Text(
                                  assignment['address'] ?? 'No address',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Status: ${assignment['status'] ?? 'Unknown'}",
                                      style: TextStyle(color: _getAssignmentStatusColor(assignment['status'])),
                                    ),
                                    Text(
                                      "Time: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(assignment['time']))}",
                                    ),
                                  ],
                                ),
                                trailing: Chip(
                                  label: Text(
                                    assignment['status'] ?? 'Unknown',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: _getAssignmentStatusColor(assignment['status']),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(String status) {
    Color indicatorColor;
    switch (status) {
      case 'Available':
        indicatorColor = Colors.green;
        break;
      case 'On Duty':
        indicatorColor = Colors.blue;
        break;
      case 'On Leave':
        indicatorColor = Colors.orange;
        break;
      default:
        indicatorColor = Colors.grey;
    }

    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: indicatorColor,
        shape: BoxShape.circle,
      ),
    );
  }

  Color _getAssignmentStatusColor(String? status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'In Progress':
        return Colors.blue;
      case 'Completed':
        return Colors.green;
      default:
        return Colors.grey;
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
}