import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:fluttershare/widgets/progress.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as Im;
import 'package:uuid/uuid.dart';

class Upload extends StatefulWidget {
  final User currentUser;

  Upload({this.currentUser});

  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload>
    with AutomaticKeepAliveClientMixin<Upload> {
  TextEditingController locationController = TextEditingController();
  TextEditingController captionController = TextEditingController();
  File file;
  bool isUploading = false;
  String postId = Uuid().v4();
  photoCamera() async {
    Navigator.pop(context);
    File file = await ImagePicker.pickImage(
        source: ImageSource.camera, maxHeight: 1080, maxWidth: 1080);
    setState(() {
      this.file = file;
    });
  }

  photoGallery() async {
    Navigator.pop(context);
    File file = await ImagePicker.pickImage(
        source: ImageSource.gallery, maxHeight: 1080, maxWidth: 1080);
    setState(() {
      this.file = file;
    });
  }
//My Salad-Fitting!!!

//<--!Removed!-->//

//Aaya Sudhi!!!
  photoSource(parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            title: Text(
              "Select Source",
              textAlign: TextAlign.center,
            ),
            children: <Widget>[
              SimpleDialogOption(
                child: Text(
                  "Camera",
                  textAlign: TextAlign.left,
                ),
                onPressed: photoCamera,
              ),
              SimpleDialogOption(
                child: Text(
                  "Gallery",
                  textAlign: TextAlign.left,
                ),
                onPressed: photoGallery,
              ),
            ],
          );
        });
  }

//My Salad-Fitting!!!

//<--!Removed!-->//

//Aaya Sudhi!
  Container buildSplashScreen() {
    return Container(
      color: Theme.of(context).accentColor.withOpacity(0.3),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SvgPicture.asset(
            'assets/images/upload.svg',
            height: 300.0,
          ),
          Padding(
            padding: EdgeInsets.only(top: 22.0),
            child: new RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100.0)),
              child: Text(
                "Upload",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22.0,
                ),
              ),
              color: Colors.purple,
              onPressed: () => photoSource(context),
            ),
          ),
        ],
      ),
    );
  }
//My Salad-Fiting!!!

//<--!Removed!-->//

//Aaya Sudhi!
  clearMedia() {
    setState(() {
      file = null;
    });
  }

  compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image imageFile = Im.decodeImage(file.readAsBytesSync());
    final compressedImageFile = File('$path/img_$postId.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 50));
    setState(() {
      file = compressedImageFile;
    });
  }

  Future<String> uploadImage(imageFile) async {
    StorageUploadTask uploadTask =
        storageRef.child("post_$postId.jpg").putFile(imageFile);
    StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    return downloadUrl;
  }

  createPostInFirestore(
      {String mediaUrl, String location, String description}) {
    postsRef
        .document(widget.currentUser.id)
        .collection("userPosts")
        .document(postId)
        .setData({
      "postId": postId,
      "ownerId": widget.currentUser.id,
      "displayName": widget.currentUser.displayName,
      "mediaUrl": mediaUrl,
      "description": description,
      "location": location,
      "timestamp": timestamp,
      "likes": {},
    });
  }

  handleSubmit() async {
    setState(() {
      isUploading = true;
    });
    await compressImage();
    String mediaUrl = await uploadImage(file);
    createPostInFirestore(
      mediaUrl: mediaUrl,
      location: locationController.text,
      description: captionController.text,
    );
    captionController.clear();
    locationController.clear();
    setState(() {
      file = null;
      isUploading = false;
      postId = Uuid().v4();
    });
  }

  Scaffold buildUploadForm() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: clearMedia,
        ),
        title: Text(
          "Edit Post",
          textAlign: TextAlign.left,
          style: TextStyle(color: Colors.white, fontSize: 20.0),
        ),
        actions: [
          FlatButton(
            onPressed: isUploading ? null : () => handleSubmit(),
            child: Text(
              "Post",
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        children: <Widget>[
          isUploading ? linearProgress() : Text(""),
          Container(
            //padding: EdgeInsets.only(top: 10.0,),
            //height: 333.0,
            //width: MediaQuery.of(context).size.width * 1,
            child: Center(
              child: AspectRatio(
                aspectRatio: 1 / 1,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: FileImage(file),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 15.0),
          ),
          ListTile(
            leading: Icon(
              Icons.mode_edit,
              size: 33,
              color: Colors.blueGrey,
            ),
            title: Container(
              width: 250.0,
              child: TextFormField(
                validator: (value) {
                  if (value.isEmpty) {
                    return "Error";
                  }
                  return null;
                },
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                maxLines: null,
                controller: captionController,
                decoration: InputDecoration(
                  hintText: "Write A Caption...",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.pin_drop,
              color: Colors.orange,
              size: 35.0,
            ),
            title: Container(
              width: 250.0,
              child: TextField(
                controller: locationController,
                decoration: InputDecoration(
                  hintText: "Add Location...",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Divider(),
          Container(
            width: 200.0,
            height: 100.0,
            alignment: Alignment.center,
            child: RaisedButton.icon(
              label: Text(
                "Use Current Location",
                style: TextStyle(color: Colors.white),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100.0),
              ),
              color: Colors.blue,
              onPressed: getUserLocation,
              icon: Icon(
                Icons.my_location,
                color: Colors.white,
              ),
            ),
          ),
          Container(
            child: Text(
              "Note : You Need To Turn On Location For Getting Your Current Location.",
              style: (TextStyle(color: Colors.grey)),
            ),
            padding: EdgeInsets.only(left: 7, right: 7),
          ),
        ],
      ),
    );
  }

  getUserLocation() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemarks = await Geolocator()
        .placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark placemark = placemarks[0];
    String completeAddress =
        '${placemark.locality}, ${placemark.administrativeArea},${placemark.country}';
    print(completeAddress);
    String formattedAddress =
        "${placemark.locality}, ${placemark.administrativeArea},${placemark.country}";
    locationController.text = formattedAddress;
  }

  bool get wantKeepAlive => true;


  @override
  Widget build(BuildContext context) {
    super.build(context);

    return file == null ? buildSplashScreen() : buildUploadForm();
  }
}
