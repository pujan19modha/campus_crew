import 'package:flutter/material.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:fluttershare/widgets/header.dart';
import 'package:fluttershare/widgets/post.dart';
import 'package:fluttershare/widgets/progress.dart';

class PostScreen extends StatelessWidget {
  final String userId;
  final String postId;
  
  PostScreen({ this.postId, this.userId });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: postsRef.document(currentUser.id).collection('userPosts').document(postId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        Post post = Post.fromDocument(snapshot.data);
        return Center(
          child: Scaffold(
            appBar: header(context, titleText: "Post"),
            body: ListView(
              children: <Widget>[
                Container(
                  child: post,
                ),
              ],
            ),
          ),
        );
      }
    );
  }
}
