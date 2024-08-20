import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main_menu.dart';


class LoginMenu extends StatefulWidget {
  const LoginMenu({super.key, required this.title});

  final String title;

  @override
  State<LoginMenu> createState() => _LoginMenuState();
}


class _LoginMenuState extends State<LoginMenu> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String _name = '';
  String _height = '';
  String _age = '';
  bool _login = true; //true = login || false = register

  Future<void> _submitForm() async {
  final form = _formKey.currentState;
  if (form == null || !form.validate()) {
    return;
  }

  form.save();

  try {
    if (_login) {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email,
        password: _password,
      );
    } else {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _email,
        password: _password,
      );
      final db = FirebaseFirestore.instance;
      await db.collection('users').doc(userCredential.user!.uid).set({
        'email': _email,
        'name': _name,
        'height': _height,
        'age': _age,
        'created_at': Timestamp.now(),
      });
    }
     Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MyNewHomePage()
        ),
      );
  } on FirebaseAuthException catch (e) {
    String errorMessage = 'Authentication failed';
    if (e.code == 'user-not-found') {
      errorMessage = 'No user found for that email.';
    } else if (e.code == 'wrong-password') {
      errorMessage = 'Wrong password provided for that user.';
    } else if (e.code == 'email-already-in-use') {
      errorMessage = 'The email is already in use.';
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Authentication Error'),
          content: Text(errorMessage),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_login ? 'Login' : 'Register'),
        backgroundColor: Colors.orange, // Color de fondo de la AppBar
        elevation: 0, 
      ),
      body: Center(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            shrinkWrap: true,
            children: [
              if (!_login) ...[
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Name', icon: Icon(Icons.person)),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                  onSaved: (value) => _name = value!,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Height', icon: Icon(Icons.height)),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your height';
                    }
                    return null;
                  },
                  onSaved: (value) => _height = value!,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Age', icon: Icon(Icons.cake)),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your age';
                    }
                    return null;
                  },
                  onSaved: (value) => _age = value!,
                ),
                const SizedBox(height: 16),
              ],
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email', icon: Icon(Icons.email)),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
                onSaved: (value) => _email = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Password', icon: Icon(Icons.lock)),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
                onSaved: (value) => _password = value!,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent, // Color de fondo del botón
                  textStyle: const TextStyle(color: Colors.white), // Color del texto del botón
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(_login ? 'Login' : 'Create Profile'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _login = !_login;
                  });
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.orange, // Color del texto del botón
                ),
                child: Text(_login ? 'I don\'t have an account' : 'I already have an account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}