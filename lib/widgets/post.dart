import 'dart:async';
import 'package:fluttershare/pages/profile.dart';
import 'package:fluttershare/pages/upload.dart';
import 'package:animator/animator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/comments.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:fluttershare/pages/read_more_text.dart';
import 'package:fluttershare/widgets/custom_image.dart';
import 'package:fluttershare/widgets/progress.dart';

class Post extends StatefulWidget {
  final String postId;
  final String ownerId;
  final String displayName;
  final String location;
  final String description;
  final String mediaUrl;
  final dynamic likes;

  Post({
    this.postId,
    this.ownerId,
    this.displayName,
    this.location,
    this.description,
    this.mediaUrl,
    this.likes,
  });

  factory Post.fromDocument(DocumentSnapshot doc) {
    return Post(
      postId: doc['postId'],
      ownerId: doc['ownerId'],
      displayName: doc['displayName'],
      location: doc['location'],
      description: doc['description'],
      mediaUrl: doc['mediaUrl'],
      likes: doc['likes'],
    );
  }

  int getLikeCount(likes) {
    // if no likes, return 0
    if (likes == null) {
      return 0;
    }
    int count = 0;
    // if the key is explicitly set to true, add a like
    likes.values.forEach((val) {
      if (val == true) {
        count += 1;
      }
    });
    return count;
  }

  int getCommentCount(comments) {
    // if no likes, return 0
    if (comments == null) {
      return 0;
    }
    int count = 0;
    // if the key is explicitly set to true, add a like
    comments.values.forEach((val) {
      if (val == true) {
        count += 1;
      }
    });
    return count;
  }

  @override
  _PostState createState() => _PostState(
        postId: this.postId,
        ownerId: this.ownerId,
        displayName: this.displayName,
        location: this.location,
        description: this.description,
        mediaUrl: this.mediaUrl,
        likes: this.likes,
        likeCount: getLikeCount(this.likes),
      );
}

class _PostState extends State<Post> {
  final String currentUserId = currentUser?.id;
  final String postId;
  final String ownerId;
  final String displayName;
  final String location;
  final String description;
  final String mediaUrl;
  int likeCount;
  Map likes;
  bool isLiked;
  bool showStar = false;

  _PostState({
    this.postId,
    this.ownerId,
    this.displayName,
    this.location,
    this.description,
    this.mediaUrl,
    this.likes,
    this.likeCount,
  });

  showProfile(BuildContext context, {String profileId}) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Profile(
                  profileId: profileId,
                )));
  }

  buildPostHeader() {
    return FutureBuilder(
      future: usersRef.document(ownerId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        User user = User.fromDocument(snapshot.data);
        bool isPostOwner = currentUserId == ownerId;
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(user.photoUrl),
            backgroundColor: Colors.grey,
          ),
          title: GestureDetector(
            onTap: () => showProfile(context, profileId: user.id),
            child: Text(
              user.displayName,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          subtitle: Text(location),
          trailing: isPostOwner
              ? IconButton(
                  onPressed: () => handleDeletePost(context),
                  icon: Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                    size: 25.0,
                  ),
                )
              : Text(""),
        );
      },
    );
  }

  handleDeletePost(BuildContext parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            title: Text("Delete Post"),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Upload()));
                  deletePost();
                },
                child: Text(
                  "Delete",
                  style:
                      TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancel"),
              ),
            ],
          );
        });
  }

  deletePost() async {
    postsRef
        .document(ownerId)
        .collection('userPosts')
        .document(postId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    storageRef.child("post_$postId.jpg").delete();

    QuerySnapshot activityFeedSnapshot = await activityFeedRef
        .document(ownerId)
        .collection("feedItems")
        .where('postId', isEqualTo: postId)
        .getDocuments();

    activityFeedSnapshot.documents.forEach((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    QuerySnapshot commentsSnapshot = await commentsRef.document(postId).collection('comments').getDocuments();
    commentsSnapshot.documents.forEach((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  handleLikePost() {
    bool _isLiked = likes[currentUserId] == true;

    if (_isLiked) {
      postsRef
          .document(ownerId)
          .collection('userPosts')
          .document(postId)
          .updateData({'likes.$currentUserId': false});
      removeLikeFromActivityFeed();
      setState(() {
        likeCount -= 1;
        isLiked = false;
        likes[currentUserId] = false;
      });
    } else if (!_isLiked) {
      postsRef
          .document(ownerId)
          .collection('userPosts')
          .document(postId)
          .updateData({'likes.$currentUserId': true});
      addLikeToActivityFeed();
      setState(() {
        likeCount += 1;
        isLiked = true;
        likes[currentUserId] = true;
        showStar = true;
      });
      Timer(Duration(seconds: 1), () {
        setState(() {
          showStar = false;
        });
      });
    }
  }

  addLikeToActivityFeed() {
    bool isNotPostOwner = currentUserId != ownerId;
    if (isNotPostOwner) {
      activityFeedRef
          .document(ownerId)
          .collection("feedItems")
          .document(postId)
          .setData({
        "type": "like",
        "displayName": currentUser.displayName,
        "userId": currentUser.id,
        "userDP": currentUser.photoUrl,
        "postId": postId,
        "mediaUrl": mediaUrl,
        "timestamp": timestamp,
      });
    }
  }

  removeLikeFromActivityFeed() {
    bool isNotPostOwner = currentUserId != ownerId;
    if (isNotPostOwner) {
      activityFeedRef
          .document(ownerId)
          .collection("feedItems")
          .document(postId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
    }
  }

  buildPostImage() {
    return GestureDetector(
      onLongPress: handleLikePost,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          cachedNetworkImage(mediaUrl),
          showStar
              ? Animator(
                  duration: Duration(milliseconds: 333),
                  tween: Tween(begin: 0.0, end: 1.75),
                  curve: Curves.linearToEaseOut,
                  cycles: 2,
                  builder: (anim) => Transform.scale(
                    scale: anim.value,
                    child: Icon(
                      Icons.star,
                      size: 100.0,
                      color: Colors.yellow[300],
                    ),
                  ),
                )
              : Text(""),
        ],
      ),
    );
  }

  buildPostFooter() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(padding: EdgeInsets.only(top: 40.0, left: 22.0)),
            GestureDetector(
              onTap: handleLikePost,
              child: Icon(
                isLiked ? Icons.star : Icons.star_border,
                size: 33.0,
                color: Colors.red,
              ),
            ),
            Padding(padding: EdgeInsets.only(right: 22.0)),
            GestureDetector(
              onTap: () => showComments(
                context,
                postId: postId,
                ownerId: ownerId,
                mediaUrl: mediaUrl,
              ),
              child: Icon(
                Icons.insert_comment,
                size: 30.0,
                color: Colors.cyan,
              ),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 25.0),
              child: Text(
                "$likeCount Stars",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 25.0),
              child: Text(
                "",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ReadMoreText(
                description,
                trimLines: 2,
                colorClickableText: Colors.indigoAccent,
                trimMode: TrimMode.Line,
                trimCollapsedText: '...Show More',
                trimExpandedText: ' Show Less',
              ),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(left: 20.0),
          child: Row(
            children: <Widget>[],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    isLiked = (likes[currentUserId] == true);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        buildPostHeader(),
        buildPostImage(),
        buildPostFooter()
      ],
    );
  }
}

showComments(BuildContext context,
    {String postId, String ownerId, String mediaUrl}) {
  Navigator.push(context, MaterialPageRoute(builder: (context) {
    return Comments(
      postId: postId,
      postOwnerId: ownerId,
      postMediaUrl: mediaUrl,
    );
  }));
}
