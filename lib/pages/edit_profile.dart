import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/widgets/progress.dart';
import 'package:fluttershare/pages/home.dart';

class EditProfile extends StatefulWidget {
  final String currentUserId;

  EditProfile({ this.currentUserId });

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController displayNameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  TextEditingController photoUrlController = TextEditingController();
  bool isLoading = false;
  User user;

  bool _displayNameValid = true;
  bool _bioValid = true;
  bool _photoUrlValid = true;

  @override
  void initState() {
    super.initState();
    getUser();
  }

getUser() async{
  setState(() {
    isLoading = true;
  });
  DocumentSnapshot doc = await usersRef.document(widget.currentUserId).get();
  user = User.fromDocument(doc);
  photoUrlController.text = user.photoUrl;
  displayNameController.text = user.displayName;
  bioController.text = user.bio;
  setState(() {
    isLoading = false;
  });
}

Column buildDisplayNameField() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Padding(padding: EdgeInsets.only(top: 11.0),
      child: Text("Name",
      style: TextStyle(color: Colors.grey),
      ),
      ),
      TextField(
        controller: displayNameController,
        decoration: InputDecoration(
          hintText: "Update Name",
          errorText: _displayNameValid ? null : "Invalid Name!"
        ),
      ),
    ],
  );
}

Column buildBioField() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Padding(padding: EdgeInsets.only(top: 11.0),
      child: Text("Bio",
      style: TextStyle(color: Colors.grey),
      ),
      ),
      Container(
        child: TextFormField(
        keyboardType: TextInputType.multiline,
        textInputAction: TextInputAction.newline,
        maxLines: null,
        controller: bioController,
        decoration: InputDecoration(
          hintText: "Update Bio",
          errorText: _bioValid ? null : "Bio Is Too Long!"
        ),
      ),
      ),
    ],
  );
}

Column buildPhotoUrlField() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Padding(padding: EdgeInsets.only(top: 11.0),
      child: Text("Profile Picture (BETA) ",
      style: TextStyle(color: Colors.grey),
      ),
      ),
      TextField(
        controller: photoUrlController,
        decoration: InputDecoration(
          hintText: "Enter Image URL",
          errorText: _photoUrlValid ? null : "Invalid URL!",
        ),
      ),
    ],
  );
}

updateProfileData() {
  setState(() {

    displayNameController.text.trim().length < 3 ||
    displayNameController.text.trim().length > 21 ||
    displayNameController.text.trim().isEmpty ? _displayNameValid = false  : 
    _displayNameValid = true;

    bioController.text.trim().length > 125 ? _bioValid = false :
    _bioValid = true;

    photoUrlController.text.trim().isEmpty ? _photoUrlValid = false  : 
    _photoUrlValid = true;
  });

  if (_displayNameValid && _bioValid && _photoUrlValid) {
    usersRef.document(widget.currentUserId).updateData({
      "displayName" : displayNameController.text,
      "bio" : bioController.text,
      "photoUrl" : photoUrlController.text,
    });
    SnackBar snackbar = SnackBar(content: Text("Profile Updated Successfully!"));
    _scaffoldKey.currentState.showSnackBar(snackbar);
  }
}

logout() async {
  await googleSignIn.signOut();
  Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
}

  @override
  Widget build(BuildContext context) {
    Align(alignment: Alignment.center);
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text(
          "Edit Profile",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.0,
          ),
        ),
      ),
      body: isLoading ? circularProgress() : ListView(
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                Padding(padding: EdgeInsets.only(top: 15, bottom: 7.5),
                child: CircleAvatar(
                  radius: 50.0,
                  backgroundImage: CachedNetworkImageProvider(user.photoUrl),
                ),
                ),
                Padding(padding: EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    buildDisplayNameField(),
                    buildBioField(),
                    buildPhotoUrlField(),
                  ],
                ),
                ),
                CupertinoButton(onPressed: updateProfileData,
                color: Colors.blue,
                child: Text("Update Profile",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontWeight: FontWeight.w500,
                ),
                ),
                ),
                Padding(padding: EdgeInsets.all(22.0),
                child: FlatButton.icon(
                  onPressed: logout, 
                  icon: Icon(CupertinoIcons.clear_thick_circled, color: Colors.red, size: 33,), label: Text("Logout", style: TextStyle(fontSize: 25, color: Colors.red,),),),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
