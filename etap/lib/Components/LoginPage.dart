import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final TextEditingController _email = TextEditingController();
    final TextEditingController _password = TextEditingController();

     Future<void> _checkEmail(String email) async {
      final response = await http.post(
        Uri.parse('http://192.168.1.12:3000/checkEmail'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );

            if (response.statusCode == 200) {
            final data = json.decode(response.body);
            print(data);
             if (data['exists'] == true) {
           Navigator.pushReplacementNamed(context, '/home');
              } else {
                 ScaffoldMessenger.of(context).showSnackBar(
                 const SnackBar(content: Text('Email not found. Please sign up.')),
        );
    } 
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to check email. Please try again.')),
        );
      }
    }


    // ✅ Primary button style (Sign in)
    final ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ).copyWith(
      overlayColor: MaterialStateProperty.resolveWith<Color?>(
        (states) {
          if (states.contains(MaterialState.hovered) ||
              states.contains(MaterialState.pressed)) {
            return Colors.blueAccent.withOpacity(0.2);
          }
          return null;
        },
      ),
    );

    final ButtonStyle secondaryButtonStyle = ElevatedButton.styleFrom(
      backgroundColor: Colors.grey,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ).copyWith(
      overlayColor: MaterialStateProperty.resolveWith<Color?>(
        (states) {
          if (states.contains(MaterialState.hovered) ||
              states.contains(MaterialState.pressed)) {
            return Colors.blue.withOpacity(0.2);
          }
          return null; // default
        },
      ),
    );

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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

              // Sign in button
              ElevatedButton(
                onPressed: () async {
                  await _checkEmail(_email.text);
                },
                style: primaryButtonStyle,
                child: const Text(
                  'Sign in',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 10),

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

              // Forgot password text button
              TextButton(
                onPressed: () {
                  // Navigator.push(context, MaterialPageRoute(builder: (_) => ForgotPasswordScreen()));
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
    );
  }
}
