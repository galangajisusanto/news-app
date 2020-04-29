import 'dart:io';

import 'package:appnews/constant/constantFile.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:async/async.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

class AddNews extends StatefulWidget {
  final VoidCallback reload;

  AddNews(this.reload);

  @override
  _AddNewsState createState() => _AddNewsState();
}

class _AddNewsState extends State<AddNews> {
  File _imageFile;
  String title, content, description, idUsers;

  final _key = new GlobalKey<FormState>();

  _choseGallery() async {
    var image = await ImagePicker.pickImage(
        source: ImageSource.gallery, maxWidth: 1080, maxHeight: 1920);
    setState(() {
      _imageFile = image;
    });
  }

  check() {
    final form = _key.currentState;
    if (form.validate()) {
      form.save();
      submit();
    }
  }

  submit() async {
    try {
      var stream =
          http.ByteStream(DelegatingStream.typed(_imageFile.openRead()));
      var length = await _imageFile.length();
      var uri = Uri.parse(BaseUrl.addNews);
      var request = http.MultipartRequest("POST", uri);
      request.files.add(http.MultipartFile('image', stream, length,
          filename: path.basename(_imageFile.path)));

      request.fields['title'] = title;
      request.fields['content'] = content;
      request.fields['description'] = description;
      request.fields['id_users'] = idUsers;

      var response = await request.send();
      if (response.statusCode > 2) {
        print("Image Upload");
        setState(() {
          widget.reload();
          Navigator.pop(context);
        });
      } else {
        print("Image upload failed");
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      idUsers = preferences.getString("id_users");
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
    var placeholder = Container(
      width: double.infinity,
      height: 50,
      child: Image.asset('./images/placeholder.png'),
    );

    return Scaffold(
      appBar: AppBar(),
      body: Form(
        key: _key,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: <Widget>[
            InkWell(
              onTap: _choseGallery,
              child: Container(
                width: double.infinity,
                child: _imageFile == null
                    ? placeholder
                    : Image.file(
                        _imageFile,
                        fit: BoxFit.fill,
                      ),
              ),
            ),
            TextFormField(
                onSaved: (e) => title = e,
                decoration: InputDecoration(labelText: "Title")),
            TextFormField(
                onSaved: (e) => content = e,
                decoration: InputDecoration(labelText: "Content")),
            TextFormField(
                onSaved: (e) => description = e,
                decoration: InputDecoration(labelText: "Description")),
            MaterialButton(
              onPressed: () {
                check();
              },
              child: Text("Submit"),
            )
          ],
        ),
      ),
    );
  }
}
