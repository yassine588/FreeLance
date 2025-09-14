import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChauffeurPage extends StatefulWidget {
  const ChauffeurPage({Key? key}) : super(key: key);

  @override
  State<ChauffeurPage> createState() => _ChauffeurPageState();
}

class _ChauffeurPageState extends State<ChauffeurPage> {
  final String apiBaseUrl = 'http://192.168.1.12:3000';
  List<Map<String, dynamic>> _drivers = [];
  bool _isLoading = true;
  String _errorMessage = '';

  Future<void> _fetchDrivers() async {
    try {
      final url = Uri.parse("$apiBaseUrl/chauffeurs");
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _drivers = List<Map<String, dynamic>>.from(data['chauffeurs'] ?? []);
          _isLoading = false;
          _errorMessage = '';
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to fetch drivers: ${response.statusCode}';
        });
        print("Failed to fetch drivers: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error fetching drivers: $e';
      });
      print("Error fetching drivers: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchDrivers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drivers Management'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchDrivers,
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
                        onPressed: _fetchDrivers,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _drivers.isEmpty
                  ? const Center(
                      child: Text(
                        'No drivers found',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _drivers.length,
                      itemBuilder: (context, index) {
                        final driver = _drivers[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue[100],
                              child: const Icon(Icons.person, color: Colors.blue),
                            ),
                            title: Text(
                              driver['name'] ?? 'Unknown',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Email: ${driver['email'] ?? 'No email'}'),
                                Text('Status: ${driver['status'] ?? 'Unknown'}'),
                              ],
                            ),
                            trailing: Chip(
                              label: Text(
                                driver['status'] ?? 'Unknown',
                                style: const TextStyle(color: Colors.white),
                              ),
                              backgroundColor: _getStatusColor(driver['status']),
                            ),
                            onTap: () {
                              // View driver details
                            },
                          ),
                        );
                      },
                    ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'Available':
        return Colors.green;
      case 'On Duty':
        return Colors.blue;
      case 'On Leave':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}