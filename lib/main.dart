import 'dart:convert';

import 'package:appnews/constant/constantFile.dart';
import 'package:appnews/register.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:appnews/mainMenu.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MaterialApp(
    home: Login(),
    debugShowCheckedModeBanner: false,
  ));
}

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

enum LoginStatus { notSignIn, signIn }

class _LoginState extends State<Login> {
  String email, password;
  final _key = new GlobalKey<FormState>();
  LoginStatus _loginStatus = LoginStatus.notSignIn;
  bool _secureText = true;

  showHide() {
    setState(() {
      _secureText = !_secureText;
    });
  }

  check() {
    final form = _key.currentState;

    if (form.validate()) {
      form.save();
      login();
    }
  }

  login() async {
    final response = await http
        .post(BaseUrl.login, body: {"email": email, "password": password});

    final data = jsonDecode(response.body);
    int value = data["value"];
    String message = data["message"];
    String userNameAPI = data['username'];
    String emailAPI = data['email'];
    String idUser = data['id_users'];

    if (value == 1) {
      setState(() {
        _loginStatus = LoginStatus.signIn;
        savePref(value, userNameAPI, emailAPI, idUser);
      });
      print(message);
    } else {
      print(message);
    }
  }

  savePref(int value, String userName, String email, String idUser) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      preferences.setInt("value", value);
      preferences.setString("username", userName);
      preferences.setString("email", email);
      preferences.setString("id_users", idUser);
      preferences.commit();
    });
  }

  var value;

  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      value = preferences.getInt("value");
      _loginStatus = value == 1 ? LoginStatus.signIn : LoginStatus.notSignIn;
    });
  }

  signOut() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      preferences.setInt("value", null);
      preferences.commit();
      _loginStatus = LoginStatus.notSignIn;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPref();
  }

  @override
  Widget build(BuildContext context) {
    switch (_loginStatus) {
      case LoginStatus.notSignIn:
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
                        icon: Icon(_secureText
                            ? Icons.visibility_off
                            : Icons.visibility),
                      )),
                ),
                MaterialButton(
                  onPressed: check,
                  child: Text("Login"),
                ),
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => Register()));
                  },
                  child: Text(
                    "Create New Account",
                    textAlign: TextAlign.center,
                  ),
                )
              ],
            ),
          ),
        );
        break;
      case LoginStatus.signIn:
        return MainMenu(signOut);
        break;
    }
  }
}
