import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  bool _isRegisterMode = true;
  bool _isDashboardMode = false;
  String _email = '';
  String _password = '';
  int _uuid = 0;

  void _currentUser() {
    final user = _auth.currentUser;
    if (user != null) {
     _uuid = user.uid.hashCode;
    }
  }

  void _submitForm() async {
    final isValid = _formKey.currentState?.validate();
    if (!isValid!) {
      return;
    }
    _formKey.currentState?.save();
    if (_isRegisterMode) {
      try {
        await _auth.createUserWithEmailAndPassword(
          email: _email,
          password: _password,
        );
        setState(() {
          _isRegisterMode = !_isRegisterMode;
        });
        _currentUser();
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Success'),
              content: Text('User created successfully ${_uuid}'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      } on FirebaseAuthException catch (e) {
        print('An error occurred: ${e.code}');
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text(e.message ?? 'An error occurred'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } else {
      try {
        await _auth.signInWithEmailAndPassword(
          email: _email,
          password: _password,
        );
        setState(() {
          _isRegisterMode = !_isRegisterMode;
          _isDashboardMode = !_isDashboardMode;
        });
        _currentUser();
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Success'),
              content: Text('User logged in successfully ${_uuid}'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      } on FirebaseAuthException catch (e) {
        print('An error occurred: ${e.code}');
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text(e.message ?? 'An error occurred'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }

  }


  @override
  Widget build(BuildContext context) {
    if(_isDashboardMode) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Dashboard'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('You are logged in!'),
              ElevatedButton(
                child: Text('Logout'),
                onPressed: () {
                  _auth.signOut();
                  setState(() {
                    _isDashboardMode = !_isDashboardMode;
                  });
                },
              ),
            ],
          ),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text(_isRegisterMode ? 'Register' : 'Login'),
        ),
        body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value!.isEmpty || !value!.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _email = value!;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value!.isEmpty || value!.length < 7) {
                      return 'Password must be at least 7 characters long';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _password = value!;
                  },
                ),
                ElevatedButton(
                  child: Text(_isRegisterMode ? 'Register' : 'Login'),
                  onPressed: _submitForm,
                ),
                ElevatedButton(
                  child: Text(_isRegisterMode ? 'Switch to Login' : 'Switch to Register'),
                  onPressed: () {
                    setState(() {
                      _isRegisterMode = !_isRegisterMode;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}