import 'package:appnews/viewTabs/Category.dart';
import 'package:appnews/viewTabs/Home.dart';
import 'package:appnews/viewTabs/News.dart';
import 'package:appnews/viewTabs/Profile.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainMenu extends StatefulWidget {
  final VoidCallback signOut;

  MainMenu(this.signOut);

  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  signOut() {
    setState(() {
      widget.signOut();
    });
  }

  String userName = "", email = "";

  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      userName = preferences.getString("username");
      email = preferences.getString("email");
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
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            IconButton(
              onPressed: () {
                signOut();
              },
              icon: Icon(Icons.lock_open),
            )
          ],
        ),
        body: TabBarView(
          children: <Widget>[Home(), News(), Category(), Profile()],
        ),
        bottomNavigationBar: TabBar(
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          tabs: <Widget>[
            Tab(
              icon: Icon(Icons.home),
              text: "Home",
            ),
            Tab(
              icon: Icon(Icons.new_releases),
              text: "News",
            ),
            Tab(
              icon: Icon(Icons.category),
              text: "Category",
            ),
            Tab(
              icon: Icon(Icons.perm_contact_calendar),
              text: "Profile",
            )
          ],
        ),
      ),
    );
  }
}
