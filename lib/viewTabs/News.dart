import 'dart:convert';

import 'package:appnews/constant/NewsModel.dart';
import 'package:appnews/constant/constantFile.dart';
import 'package:appnews/viewTabs/EditNews.dart';
import 'package:appnews/viewTabs/addNews.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class News extends StatefulWidget {
  @override
  _NewsState createState() => _NewsState();
}

class _NewsState extends State<News> {
  final list = new List<NewsModel>();
  var loading = false;

  Future _getDataNews() async {
    list.clear();
    setState(() {
      loading = true;
    });

    final response = await http.get(BaseUrl.detailNews);
    if (response.contentLength == 2) {
    } else {
      final data = jsonDecode(response.body);
      data.forEach((api) {
        final ab = new NewsModel(
          api['id_news'],
          api['image'],
          api['title'],
          api['content'],
          api['description'],
          api['date_news'],
          api['id_user'],
          api['username'],
        );
        list.add(ab);
      });
      setState(() {
        loading = false;
      });
    }
  }

  _delete(String idNews) async {
    final response =
        await http.post(BaseUrl.deleteNews, body: {"id_news": idNews});

    final data = jsonDecode(response.body);
    int value = data['value'];
    String message = data['message'];

    if (value == 1) {
      _getDataNews();
      Navigator.pop(context);
    } else {
      print(message);
    }
  }

  dialogDelete(String idNews) {
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: ListView(
              padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
              shrinkWrap: true,
              children: <Widget>[
                Text(
                  "Do you want to delete this news ?",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Text("No")),
                    SizedBox(
                      width: 20,
                    ),
                    InkWell(
                        onTap: () {
                          _delete(idNews);
                        },
                        child: Text("Yes"))
                  ],
                ),
              ],
            ),
          );
        });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getDataNews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => AddNews(_getDataNews)));
        },
        child: Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: _getDataNews,
        child: loading
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final x = list[index];
                  return Container(
                    child: Column(
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Image.network(
                              BaseUrl.insertImage + x.image,
                              width: 150,
                              height: 120,
                              fit: BoxFit.fill,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    x.title,
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    height: 3,
                                  ),
                                  Text(x.date_news),
                                ],
                              ),
                            ),
                            IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) =>
                                          EditNews(x, _getDataNews)));
                                }),
                            IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  dialogDelete(x.id_news);
                                }),
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
