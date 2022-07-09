import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:readmore/readmore.dart';
import 'package:fluttershare/widgets/header.dart';
import 'package:fluttershare/widgets/progress.dart';
// ignore: unused_import
import 'package:timeago/timeago.dart' as timeago;


class Comments extends StatefulWidget {
  final String postId;
  final String postOwnerId;
  final String postMediaUrl;

  Comments({
    this.postId,
    this.postOwnerId,
    this.postMediaUrl,
  });

  @override
  CommentsState createState() => CommentsState(
    postId : this.postId,
    postOwnerId : this.postOwnerId,
    postMediaUrl : this.postMediaUrl,  
  );
}

class CommentsState extends State<Comments> {
  TextEditingController commentController = TextEditingController();
  final String postId;
  final String postOwnerId;
  final String postMediaUrl;

  CommentsState({
    this.postId,
    this.postOwnerId,
    this.postMediaUrl,
  });

  buildComments() {
    return StreamBuilder(
      stream: commentsRef.document(postId).collection('comments').orderBy("timestamp", descending: false).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        List<Comment> comments = [];
        snapshot.data.documents.forEach((doc) {
          comments.add(Comment.fromDocument(doc));
        });
        return ListView(children: comments,);
      },
    );
  }

  addComment() {
    commentsRef
      .document(postId)
      .collection("comments")
      .add({
        "displayName" : currentUser.displayName,
        "comment" : commentController.text,
        "timestamp" : timestamp,
        "avatarUrl" : currentUser.photoUrl,
        "userId" : currentUser.id,
      });
      bool isNotPostOwner = postOwnerId != currentUser.id;
      if (isNotPostOwner) {
      
    activityFeedRef
    .document(postOwnerId)
    .collection('feedItems')
    .add({
      "type" : "comment",
      "commentData" : commentController.text,
      "displayName" : currentUser.displayName,
      "userId" : currentUser.id,
      "userDP" : currentUser.photoUrl,
      "postId" : postId,
      "mediaUrl" : postMediaUrl,
      "timestamp" : timestamp,
    });
  }
    commentController.clear();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, titleText: "Comments"),
      body: Column(
        children: <Widget>[
          Expanded(child: buildComments(),),
          Divider(),
          ListTile(
            title: TextFormField(
              controller: commentController,
              decoration: InputDecoration(labelText: "Drop A Comment..."),
            ),
            trailing: OutlinedButton(
              onPressed: addComment,
              
              child: Text("Drop", style: TextStyle(fontSize: 20),),
            ),
          ),
        ],
      ),
    );
  }
}

class Comment extends StatelessWidget {
  final String displayName;
  final String userId;
  final String avatarUrl;
  final String comment;
  final Timestamp timestamp;

  Comment({
   this.displayName,
   this.userId,
   this.avatarUrl,
   this.comment,
   this.timestamp,    
  });

  factory Comment.fromDocument(DocumentSnapshot doc) {
    return Comment(
      displayName: doc['displayName'],
      userId: doc['userId'],
      comment: doc['comment'],
      timestamp: doc['timestamp'],
      avatarUrl: doc['avatarUrl'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          title: ReadMoreText(comment,
               trimLength: 50,
               colorClickableText: Colors.indigoAccent,
               trimMode: TrimMode.Length,
               trimCollapsedText: '...Show More',
               trimExpandedText: ' Show Less',),
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(avatarUrl),
          ),
          subtitle: Text("by $displayName"),
        ),
        Divider(),
      ],
    );
  }
}
