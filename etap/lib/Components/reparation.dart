import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class AddReparationPage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const AddReparationPage({Key? key, required this.userData}) : super(key: key);

  @override
  _AddReparationPageState createState() => _AddReparationPageState();
}

class _AddReparationPageState extends State<AddReparationPage> {
  final String apiBaseUrl = 'http://192.168.1.12:3000';
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  
  // Form values
  DateTime _selectedStartDate = DateTime.now();
  DateTime? _selectedEndDate;
  String _selectedStatus = 'EN_COURS';
  String _selectedPriority = 'MOYENNE';
  List<dynamic> _vehicles = [];
  bool _loadingVehicles = true;
  String? _selectedVehicleId;

  // Status options
  final List<String> _statusOptions = [
    'EN_COURS',
    'TERMINEE',
    'ANNULEE'
  ];

  // Priority options
  final List<String> _priorityOptions = [
    'FAIBLE',
    'MOYENNE',
    'ELEVEE',
    'URGENTE'
  ];

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
        setState(() {
          // Handle the specific response format from your controller
          if (data is Map && data.containsKey('vehicules')) {
            _vehicles = data['vehicules'] is List ? data['vehicules'] : [];
          } else if (data is List) {
            _vehicles = data;
          } else {
            _vehicles = [];
          }
          _loadingVehicles = false;
        });
      } else {
        throw Exception('Failed to load vehicles: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching vehicles: $e");
      setState(() => _loadingVehicles = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading vehicles: $e")),
      );
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _selectedStartDate : (_selectedEndDate ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _selectedStartDate = picked;
        } else {
          _selectedEndDate = picked;
        }
      });
    }
  }

 Future<void> _submitReparation() async {
  if (!_formKey.currentState!.validate()) return;
  
  if (_selectedVehicleId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please select a vehicle")),
    );
    return;
  }

  try {
    final reparationData = {
      "vehicule": _selectedVehicleId,
      "dateDebut": _selectedStartDate.toIso8601String(),
      "dateFin": _selectedEndDate?.toIso8601String(),
      "description": _descriptionController.text,
      "statut": _selectedStatus,       
      "priorite": _selectedPriority,   
      "cout": _costController.text.isNotEmpty 
          ? double.parse(_costController.text) 
          : 0.0,                      
    };

    final response = await http.post(
      Uri.parse("$apiBaseUrl/reparations"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(reparationData),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Repair record added successfully")),
      );

      // reset form
      _formKey.currentState!.reset();
      _descriptionController.clear();
      _costController.clear();
      setState(() {
        _selectedVehicleId = null;
        _selectedStartDate = DateTime.now();
        _selectedEndDate = null;
        _selectedStatus = 'EN_COURS';
        _selectedPriority = 'MOYENNE';
      });
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['error'] ?? errorData['message'] ?? 'Failed to add repair record');
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error adding repair record: $e")),
    );
  }
}

  String _getStatusText(String status) {
    switch (status) {
      case 'EN_COURS':
        return 'In Progress';
      case 'TERMINEE':
        return 'Completed';
      case 'ANNULEE':
        return 'Cancelled';
      default:
        return status;
    }
  }

  String _getPriorityText(String priority) {
    switch (priority) {
      case 'FAIBLE':
        return 'Low';
      case 'MOYENNE':
        return 'Medium';
      case 'ELEVEE':
        return 'High';
      case 'URGENTE':
        return 'Urgent';
      default:
        return priority;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Repair Record"),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchVehicles,
            tooltip: 'Refresh Vehicles',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Vehicle Selection
              _loadingVehicles
                  ? Center(child: CircularProgressIndicator())
                  : _vehicles.isEmpty
                      ? Text("No vehicles available")
                      : DropdownButtonFormField<String>(
                          value: _selectedVehicleId,
                          decoration: InputDecoration(
                            labelText: "Select Vehicle",
                            border: OutlineInputBorder(),
                          ),
                          items: _vehicles.map((vehicle) {
                            return DropdownMenuItem<String>(
                              value: vehicle['_id'],
                              child: Text(
                                "${vehicle['marque']} ${vehicle['modele']} (${vehicle['immatriculation']})",
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedVehicleId = newValue;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a vehicle';
                            }
                            return null;
                          },
                        ),
              SizedBox(height: 20),

              // Start Date
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: "Start Date",
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      controller: TextEditingController(
                        text: DateFormat('yyyy-MM-dd').format(_selectedStartDate),
                      ),
                      onTap: () => _selectDate(context, true),
                      readOnly: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a start date';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // End Date (optional)
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: "End Date (Optional)",
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      controller: TextEditingController(
                        text: _selectedEndDate != null 
                            ? DateFormat('yyyy-MM-dd').format(_selectedEndDate!)
                            : '',
                      ),
                      onTap: () => _selectDate(context, false),
                      readOnly: true,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Status
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: InputDecoration(
                  labelText: "Status",
                  border: OutlineInputBorder(),
                ),
                items: _statusOptions.map((String status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(_getStatusText(status)),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedStatus = newValue!;
                  });
                },
              ),
              SizedBox(height: 16),

              // Priority
              DropdownButtonFormField<String>(
                value: _selectedPriority,
                decoration: InputDecoration(
                  labelText: "Priority",
                  border: OutlineInputBorder(),
                ),
                items: _priorityOptions.map((String priority) {
                  return DropdownMenuItem<String>(
                    value: priority,
                    child: Text(_getPriorityText(priority)),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedPriority = newValue!;
                  });
                },
              ),
              SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please describe the repair';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Cost
              TextFormField(
                controller: _costController,
                decoration: InputDecoration(
                  labelText: "Cost (Optional)",
                  border: OutlineInputBorder(),
                  prefixText: '\$ ',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final cost = double.tryParse(value);
                    if (cost == null || cost < 0) {
                      return 'Please enter a valid cost';
                    }
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),

              // Submit Button
              ElevatedButton(
                onPressed: _submitReparation,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  "Add Repair Record",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}