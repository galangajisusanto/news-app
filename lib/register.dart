import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:appnews/constant/constantFile.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  String email, password, userName;

  bool _secureText = true;

  final _key = new GlobalKey<FormState>();

  showHide() {
    setState(() {
      _secureText = !_secureText;
    });
  }

  check() {
    final form = _key.currentState;
    if (form.validate()) {
      form.save();
      save();
    }
  }

  save() async {
    final response = await http.post(BaseUrl.register,
        body: {"username": userName, "email": email, "password": password});

    final data = jsonDecode(response.body);
    int value = data['value'];
    String message = data['message'];
    if (value == 1) {
      setState(() {
        Navigator.pop(context);
      });
    } else {
      print(message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Form(
        key: _key,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: <Widget>[
            TextFormField(
              validator: (e) {
                if (e.isEmpty) {
                  return "Please insert username";
                }
              },
              onSaved: (e) => userName = e,
              decoration: InputDecoration(labelText: "User Name"),
            ),
            TextFormField(
              validator: (e) {
                if (e.isEmpty) {
                  return "Please insert email";
                }
              },
              onSaved: (e) => email = e,
              decoration: InputDecoration(labelText: "Email"),
            ),
            TextFormField(
              obscureText: _secureText,
              onSaved: (e) => password = e,
              decoration: InputDecoration(
                  labelText: "Password",
                  suffixIcon: IconButton(
                    onPressed: showHide,
                    icon: Icon(
                        _secureText ? Icons.visibility_off : Icons.visibility),
                  )),
            ),
            MaterialButton(
              onPressed: () {
                check();
              },
              child: Text("Register"),
            )
          ],
        ),
      ),
    );
  }
}
