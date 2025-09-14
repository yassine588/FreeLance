import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddAssignmentPage extends StatefulWidget {
  const AddAssignmentPage({Key? key}) : super(key: key);

  @override
  State<AddAssignmentPage> createState() => _AddAssignmentPageState();
}

class _AddAssignmentPageState extends State<AddAssignmentPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _addressController = TextEditingController();

  String? _selectedDriver;
  String? _selectedStatus;
  DateTime? _selectedTime;

  List<dynamic> _drivers = [];
  final List<String> _statuses = ['Pending', 'In Progress', 'Completed'];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchDrivers();
  }

  Future<void> _fetchDrivers() async {
    try {
      final url = Uri.parse("http://192.168.1.12:3000/chauffeurs"); 
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _drivers = data['chauffeurs'] ?? [];
        });
      } else {
        print("Failed to fetch drivers: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching drivers: $e");
    }
  }

  Future<void> _submitAssignment() async {
    if (_formKey.currentState!.validate() &&
        _selectedDriver != null &&
        _selectedStatus != null &&
        _selectedTime != null) {
      
      setState(() {
        _isLoading = true;
      });

      try {
        final url = Uri.parse("http://192.168.1.12:3000/assignments");
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'address': _addressController.text,
            'driverId': _selectedDriver,
            'status': _selectedStatus,
            'time': _selectedTime!.toIso8601String(),
          }),
        );

        print("Response status: ${response.statusCode}");
        print("Response body: ${response.body}");

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Assignment added successfully!')),
          );
          Navigator.pop(context);
        } else {
          final errorData = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add assignment: ${errorData['message']}')),
          );
        }
      } catch (e) {
        print("Error submitting assignment: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
    }
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      
      if (time != null) {
        setState(() {
          _selectedTime = DateTime(
            date.year, date.month, date.day, time.hour, time.minute
          );
        });
      }
    }
  }
  String _formatDateTime(DateTime dateTime) {
  return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Assignment')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Address Field
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter the address' : null,
              ),
              const SizedBox(height: 16),
              
              // Driver Dropdown
              DropdownButtonFormField<String>(
                value: _selectedDriver,
                items: _drivers
                    .map<DropdownMenuItem<String>>(
                      (driver) => DropdownMenuItem<String>(
                        value: driver['_id'] as String,
                        child: Text('${driver['name']}'),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDriver = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Select Driver',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null ? 'Please select a driver' : null,
              ),
              const SizedBox(height: 16),

              // Status Dropdown - Updated to match your model
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                items: _statuses
                    .map<DropdownMenuItem<String>>(
                      (status) => DropdownMenuItem<String>(
                        value: status,
                        child: Text(status),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Select Status',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null ? 'Please select status' : null,
              ),
              const SizedBox(height: 16),

              // Date & Time Picker
              InkWell(
                onTap: _selectDateTime,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Select Date & Time',
                    border: OutlineInputBorder(),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedTime == null
                            ? 'Select time'
                            : _formatDateTime(_selectedTime!),
                      ),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Submit Button
              ElevatedButton(
                onPressed: _isLoading ? null : _submitAssignment,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Add Assignment'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}