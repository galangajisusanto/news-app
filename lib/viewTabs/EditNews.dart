import 'dart:io';

import 'package:appnews/constant/NewsModel.dart';
import 'package:appnews/constant/constantFile.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:async/async.dart';

class EditNews extends StatefulWidget {
  final NewsModel model;

  final VoidCallback reload;

  EditNews(this.model, this.reload);

  @override
  _EditNewsState createState() => _EditNewsState();
}

class _EditNewsState extends State<EditNews> {
  File _imageFile;

  String title, content, description, idUsers;

  TextEditingController txtTitle, txtContent, txtDescription;

  final _key = new GlobalKey<FormState>();

  check() {
    final form = _key.currentState;
    if (form.validate()) {
      form.save();
      submit();
    } else {}
  }

  submit() async {
    try {
      var stream =
          http.ByteStream(DelegatingStream.typed(_imageFile.openRead()));
      var length = await _imageFile.length();
      var uri = Uri.parse(BaseUrl.editNews);
      var request = http.MultipartRequest("POST", uri);
      request.files.add(http.MultipartFile('image', stream, length,
          filename: path.basename(_imageFile.path)));

      request.fields['title'] = title;
      request.fields['content'] = content;
      request.fields['description'] = description;
      request.fields['id_users'] = idUsers;
      request.fields['id_news'] = widget.model.id_news;

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

  setup() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      idUsers = preferences.getString("id_users");
    });
    txtTitle = TextEditingController(text: widget.model.title);
    txtContent = TextEditingController(text: widget.model.content);
    txtDescription = TextEditingController(text: widget.model.description);
  }

  _choseGallery() async {
    var image = await ImagePicker.pickImage(
        source: ImageSource.gallery, maxWidth: 1080, maxHeight: 1920);
    setState(() {
      _imageFile = image;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setup();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Form(
        key: _key,
        child: ListView(
          padding: EdgeInsets.all(15),
          children: <Widget>[
            Container(
              width: double.infinity,
              child: InkWell(
                onTap: () {
                  _choseGallery();
                },
                child: _imageFile == null
                    ? Image.network(BaseUrl.insertImage + widget.model.image)
                    : Image.file(
                        _imageFile,
                        fit: BoxFit.fill,
                      ),
              ),
            ),
            TextFormField(
              controller: txtTitle,
              onSaved: (e) => title = e,
              decoration: InputDecoration(labelText: "Title"),
            ),
            TextFormField(
              controller: txtContent,
              onSaved: (e) => content = e,
              decoration: InputDecoration(labelText: "Content"),
            ),
            TextFormField(
              controller: txtDescription,
              onSaved: (e) => description = e,
              decoration: InputDecoration(labelText: "Description"),
            ),
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
