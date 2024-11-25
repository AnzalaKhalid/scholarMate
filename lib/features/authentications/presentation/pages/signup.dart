import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scholar_mate/features/authentications/presentation/pages/login_screen.dart';
import 'package:scholar_mate/features/authentications/presentation/pages/otp_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _email = '';
  String _password = '';
  String _confirmPassword = '';
  String _name = '';
  String _fatherName = '';
  String? _selectedDepartment;
  String _idNumber = '';
  String _semester = '';
  String _errorMessage = '';
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;


  final List<String> _departments = [
    'Education', 'IBLC', 'Computer Science', 'Political Science',
    'Botany', 'Biotechnology', 'Biochemistry', 'Chemistry', 
    'English Literature', 'BBA', 'Commerce', 'Economics', 'Sociology',
  ];


  bool _validateEmail(String email) {
    final String domain = email.split('@').last;
    return domain == 'stud.uot.edu.pk';
  }


  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() { _isLoading = true; });

      try {
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: _email,
          password: _password,
        );
        String userId = userCredential.user!.uid;

        // Save user information to Firestore
        await _firestore.collection('users').doc(userId).set({
          'name': _name,
          'fatherName': _fatherName,
          'department': _selectedDepartment,
          'idNumber': _idNumber,
          'semester': _semester,
          'email': _email,
          'isVerified': false,
          'userId': userId,
        });

        // Navigate to SendVerificationEmailPage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => OtpVerificationScreen(email: _email, fromLoginPage: false,)),
        );
      } catch (e) {
        setState(() { _errorMessage = e.toString(); });
      } finally {
        setState(() { _isLoading = false; });
      }
    }
  }
  
  Widget _buildTextFormField({
    required String hintText,
    required IconData prefixIcon,
    required ValueChanged<String> onChanged,
    required String? Function(String?) validator,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(prefixIcon, color: const Color.fromARGB(255, 129, 1, 152)),
        filled: true,
        fillColor: Colors.grey[100],
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF027FE6)),
          borderRadius: BorderRadius.circular(12),
        ),
        suffixIcon: suffixIcon,
      ),
      obscureText: obscureText,
      onChanged: onChanged,
      validator: validator,
    );
  }
  
    Widget _buildCard(List<Widget> children) {
    return SizedBox(
      width: 350,
      child: Card(
        color: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: children,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            colors: [
              Color(0xFF015DA9),
              Color(0xFF016BC1),
              Color(0xFF027FE6),
              Color(0xFF028AF9),
            ],
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 80),
              const Image(
                image: AssetImage("assets/logo1.png"),
                height: 90,
                width: 90,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: 350,
                child: Card(
                  color: Colors.white,
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Create Your Account',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                          const SizedBox(height: 20),
                          _buildTextFormField(
                            hintText: 'University Email',
                            prefixIcon: Icons.email,
                            onChanged: (value) => _email = value,
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Please enter an email';
                              if (!_validateEmail(value)) return 'Please use your university email';
                              return null;
                            },
                          ),
                          const SizedBox(height: 15),
                          _buildTextFormField(
                            hintText: 'Password',
                            prefixIcon: Icons.lock,
                            onChanged: (value) => _password = value,
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Please enter a password';
                              if (value.length < 6) return 'Password must be at least 6 characters';
                              return null;
                            },
                            obscureText: !_isPasswordVisible,
                            suffixIcon: IconButton(
                              icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                              onPressed: () { setState(() { _isPasswordVisible = !_isPasswordVisible; }); },
                            ),
                          ),
                          const SizedBox(height: 15),
                          _buildTextFormField(
                            hintText: 'Confirm Password',
                            prefixIcon: Icons.lock_outline,
                            onChanged: (value) => _confirmPassword = value,
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Please confirm your password';
                              if (value != _password) return 'Passwords do not match';
                              return null;
                            },
                            obscureText: !_isConfirmPasswordVisible,
                            suffixIcon: IconButton(
                              icon: Icon(_isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off),
                              onPressed: () { setState(() { _isConfirmPasswordVisible = !_isConfirmPasswordVisible; }); },
                            ),
                          ),
                          const SizedBox(height: 15),
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              hintText: 'Select Department',
                              prefixIcon: const Icon(Icons.school, color: Color.fromARGB(255, 129, 1, 152)),
                              filled: true,
                              fillColor: Colors.grey[100],
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: Color(0xFF027FE6)),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            value: _selectedDepartment,
                            onChanged: (value) { setState(() { _selectedDepartment = value; }); },
                            items: _departments.map((String department) {
                              return DropdownMenuItem<String>(
                                value: department,
                                child: Text(department),
                              );
                            }).toList(),
                            validator: (value) {
                              if (value == null) return 'Please select a department';
                              return null;
                            },
                          ),
                          const SizedBox(height: 15),
                          _buildTextFormField(
                            hintText: 'Name',
                            prefixIcon: Icons.person,
                            onChanged: (value) => _name = value,
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Please enter your name';
                              return null;
                            },
                          ),
                          const SizedBox(height: 15),
                          _buildTextFormField(
                            hintText: 'Father Name',
                            prefixIcon: Icons.person,
                            onChanged: (value) => _fatherName = value,
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Please enter your father\'s name';
                              return null;
                            },
                          ),
                          const SizedBox(height: 15),
                          _buildTextFormField(
                            hintText: 'ID Number',
                            prefixIcon: Icons.person,
                            onChanged: (value) => _idNumber = value,
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Please enter your ID number';
                              return null;
                            },
                          ),
                          const SizedBox(height: 15),
                          _buildTextFormField(
                            hintText: 'Semester',
                            prefixIcon: Icons.school,
                            onChanged: (value) => _semester = value,
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Please enter your semester';
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          if (_errorMessage.isNotEmpty)
                            Text(
                              _errorMessage,
                              style: const TextStyle(color: Colors.red),
                            ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _signUp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF027FE6),
                              minimumSize: const Size.fromHeight(50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                                    'Sign Up',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Already have an account?", style: TextStyle(fontSize: 15)),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => const LoginPage()),
                                  );
                                },
                                child: const Text("Sign In", style: TextStyle(color: Color(0xFF027FE6))),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            
            ],
          ),
        ),
      ),
    );
  }
}
