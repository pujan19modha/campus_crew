import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttershare/widgets/header.dart';

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  String displayName;

  submit() {
    final form = _formKey.currentState;

    if (form.validate()) {
      form.save();
      SnackBar snackbar = SnackBar(content: Text("Welcome $displayName!"));
      _scaffoldKey.currentState.showSnackBar(snackbar);
      Timer(Duration(milliseconds: 1500), () {
        Navigator.pop(context, displayName);
      });
    }
  }

  @override
  Widget build(BuildContext parentContext) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: header(context,
          titleText: "Seting Up Profile", removeBackButton: true),
      body: ListView(
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 25.0),
                  child: Center(
                    child: Text(
                      "Set Your Name",
                      style: TextStyle(fontSize: 25.0),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Container(
                    child: Form(
                      autovalidateMode: AutovalidateMode.always, key: _formKey,
                      child: TextFormField(
                        validator: (val) {
                          if (val.trim().length < 3 || val.isEmpty) {
                            return "Name too short";
                          } else if (val.trim().length > 21) {
                            return "Name too long";
                          } else {
                            return null;
                          }
                        },
                        onSaved: (val) => displayName = val,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Name",
                          labelStyle: TextStyle(fontSize: 15.0),
                          hintText: "3 - 21 Characters",
                        ),
                      ),
                    ),
                  ),
                ),
                WillPopScope(
                onWillPop: () async => false,
                child: GestureDetector(
                  onTap: submit,
                  child: Container(
                    height: 50.0,
                    width: 350.0,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(100.0),
                    ),
                    child: Center(
                      child: Text(
                        "Submit",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
               )
              ],
            ),
          )
        ],
      ),
    );
  }
}
