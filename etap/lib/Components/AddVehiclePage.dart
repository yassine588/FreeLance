import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddVehiclePage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const AddVehiclePage({Key? key, required this.userData}) : super(key: key);

  @override
  _AddVehiclePageState createState() => _AddVehiclePageState();
}

class _AddVehiclePageState extends State<AddVehiclePage> {
  final String apiBaseUrl = 'http://192.168.1.12:3000';
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final TextEditingController _marqueController = TextEditingController();
  final TextEditingController _modeleController = TextEditingController();
  final TextEditingController _immatriculationController = TextEditingController();
  
  // Form values
  String _selectedEtat = 'DISPONIBLE';

  // Vehicle status options
  final List<String> _etatOptions = [
    'DISPONIBLE',
    'EN_PANNE', 
    'EN_REPARATION',
    'HORS_SERVICE'
  ];

  String _getEtatText(String etat) {
    switch (etat) {
      case 'DISPONIBLE':
        return 'Available';
      case 'EN_PANNE':
        return 'Broken';
      case 'EN_REPARATION':
        return 'In Repair';
      case 'HORS_SERVICE':
        return 'Out of Service';
      default:
        return etat;
    }
  }

  Future<void> _submitVehicle() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final vehicleData = {
        "marque": _marqueController.text,
        "modele": _modeleController.text,
        "immatriculation": _immatriculationController.text,
        "etat": _selectedEtat,
      };

      final response = await http.post(
        Uri.parse("$apiBaseUrl/vehicules"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(vehicleData),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Vehicle added successfully")),
        );
        // Clear the form
        _formKey.currentState!.reset();
        _marqueController.clear();
        _modeleController.clear();
        _immatriculationController.clear();
        setState(() {
          _selectedEtat = 'DISPONIBLE';
        });
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to add vehicle');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error adding vehicle: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add New Vehicle"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Brand field
              TextFormField(
                controller: _marqueController,
                decoration: InputDecoration(
                  labelText: "Brand*",
                  border: OutlineInputBorder(),
                  hintText: "e.g., Toyota, Renault, Mercedes",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the vehicle brand';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Model field
              TextFormField(
                controller: _modeleController,
                decoration: InputDecoration(
                  labelText: "Model*",
                  border: OutlineInputBorder(),
                  hintText: "e.g., Hilux, Kangoo, Sprinter",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the vehicle model';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // License plate field
              TextFormField(
                controller: _immatriculationController,
                decoration: InputDecoration(
                  labelText: "License Plate*",
                  border: OutlineInputBorder(),
                  hintText: "e.g., 1234 TU 1234",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the license plate';
                  }
                  if (value.length > 15) {
                    return 'License plate must be 15 characters or less';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Status dropdown
              DropdownButtonFormField<String>(
                value: _selectedEtat,
                decoration: InputDecoration(
                  labelText: "Status*",
                  border: OutlineInputBorder(),
                ),
                items: _etatOptions.map((String etat) {
                  return DropdownMenuItem<String>(
                    value: etat,
                    child: Text(_getEtatText(etat)),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedEtat = newValue!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a status';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),

              // Submit button
              ElevatedButton(
                onPressed: _submitVehicle,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green,
                ),
                child: Text(
                  "Add Vehicle",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _marqueController.dispose();
    _modeleController.dispose();
    _immatriculationController.dispose();
    super.dispose();
  }
}