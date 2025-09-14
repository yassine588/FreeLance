import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminApprovalPage extends StatefulWidget {
  @override
  _AdminApprovalPageState createState() => _AdminApprovalPageState();
}

class _AdminApprovalPageState extends State<AdminApprovalPage> {
  List<dynamic> _pendingUsers = [];
  bool _loading = true;
  @override
  void initState() {
    super.initState();
    _fetchPendingUsers();
  }

  Future<void> _fetchPendingUsers() async {
    try {
      final response = await http.get(
        Uri.parse("http://192.168.1.12:3000/admin/pending-users"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _pendingUsers = data['users'];
          _loading = false;
        });
      } else {
        throw Exception('Failed to load pending users');
      }
    } catch (e) {
      print("Error fetching pending users: $e");
      setState(() => _loading = false);
    }
  }

  Future<void> _approveUser(String userId) async {
    try {
      final response = await http.post(
        Uri.parse("http://192.168.1.12:3000/admin/approve-user/$userId"),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("User approved successfully")),
        );
        _fetchPendingUsers(); // Refresh the list
      } else {
        throw Exception('Failed to approve user');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error approving user: $e")),
      );
    }
  }

  Future<void> _rejectUser(String userId) async {
    try {
      final response = await http.delete(
        Uri.parse("http://192.168.1.12:3000/admin/reject-user/$userId"),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("User rejected successfully")),
        );
        _fetchPendingUsers(); // Refresh the list
      } else {
        throw Exception('Failed to reject user');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error rejecting user: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Pending User Approvals")),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : _pendingUsers.isEmpty
              ? Center(child: Text("No pending approvals"))
              : ListView.builder(
                  itemCount: _pendingUsers.length,
                  itemBuilder: (context, index) {
                    final user = _pendingUsers[index];
                    return ListTile(
                      title: Text(user['name']),
                      subtitle: Text("${user['email']} - ${user['post']}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.check, color: Colors.green),
                            onPressed: () => _approveUser(user['_id']),
                          ),
                          IconButton(
                            icon: Icon(Icons.close, color: Colors.red),
                            onPressed: () => _rejectUser(user['_id']),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}