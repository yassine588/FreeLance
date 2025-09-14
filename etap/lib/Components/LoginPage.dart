import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _loading = false;
  final String apiBaseUrl ='http://192.168.1.12:3000';

  Future<void> _login() async {
    final email = _email.text.trim();
    final password = _password.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final accessResponse = await http.get(
        Uri.parse("$apiBaseUrl/accountAccess/$email"),
      );
      print(accessResponse.body);
      if (accessResponse.statusCode == 200) {
        final accessData = jsonDecode(accessResponse.body);

        if (!accessData['access']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(accessData['message'] ?? "Account pending admin approval")),
          );
          setState(() => _loading = false);
          return;
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to check account status")),
        );
        setState(() => _loading = false);
        return;
      }

      final loginResponse = await http.post(
        Uri.parse("$apiBaseUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      final loginData = jsonDecode(loginResponse.body);

      if (loginResponse.statusCode == 200 && loginData['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loginData["message"] ?? "Login successful")),
        );

        final userData = loginData['user'];
        if (userData['post'] == 'chauffeur') {
          Navigator.pushReplacementNamed(context, '/chauffeurDashboard', arguments: userData);
        } else if (userData['post'] == 'admin') {
          Navigator.pushReplacementNamed(context, '/home');
        } else if (userData['post'] == 'operator') {
          Navigator.pushReplacementNamed(context, '/operateur');
        } else if (userData['post'] == 'chef parc') {
          Navigator.pushReplacementNamed(context, '/chefPark', arguments: userData);
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loginData["message"] ?? "Login failed")),
        );
      }
    } catch (e) {
      print("Error during login: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Connection error: Please check your server")),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  final ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: Colors.blue,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15), 
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  );

  final ButtonStyle secondaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: Colors.grey,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15), 
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, 
      body: SafeArea(
        child: SingleChildScrollView(     
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const SizedBox(height: 40),
                Image.asset(
                  'lib/assets/etap.png',
                  width: 150,
                  height: 150,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _email,
                  decoration: const InputDecoration(
                    labelText: 'E-mail',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  obscureText: true,
                  controller: _password,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),

                // Sign in
                ElevatedButton(
                  onPressed: _loading ? null : _login,
                  style: primaryButtonStyle,
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Sign in',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),

                const SizedBox(height: 10),

                // Sign up
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/signup');
                  },
                  style: secondaryButtonStyle,
                  child: const Text(
                    'Sign up',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(height: 10),

                // Forgot password
                TextButton(
                  onPressed: () {
                    // TODO: Navigate to forgot password screen
                  },
                  child: const Text(
                    "Forgot Password?",
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
