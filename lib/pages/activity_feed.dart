// import 'dart:ui';
// import 'package:fluttershare/pages/post_screen.dart';
// import 'package:fluttershare/pages/profile.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:fluttershare/pages/home.dart';
// import 'package:fluttershare/widgets/header.dart';
// import 'package:fluttershare/widgets/progress.dart';

// class ActivityFeed extends StatefulWidget {
//   @override
//   _ActivityFeedState createState() => _ActivityFeedState();
// }

// class _ActivityFeedState extends State<ActivityFeed> {
//   getActivityFeed() async {
//     QuerySnapshot snapshot = await activityFeedRef
//         .document(currentUser.id)
//         .collection('feedItems')
//         .orderBy('timestamp', descending: true)
//         .limit(50)
//         .getDocuments();
//     List<ActivityFeedItem> feedItems = [];
//     snapshot.documents.forEach((doc) {
//       feedItems.add(ActivityFeedItem.fromDocument(doc));
//     });
//     return feedItems;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: header(context, titleText: "Notifications"),
//       body: Container(
//         child: FutureBuilder(
//             future: getActivityFeed(),
//             builder: (context, snapshot) {
//               if (!snapshot.hasData) {
//                 return circularProgress();
//               }
//               return ListView(
//                 children: snapshot.data,
//               );
//             }),
//       ),
//     );
//   }
// }

// Widget mediaPreview;
// String activityItemText;

// class ActivityFeedItem extends StatelessWidget {
//   final String displayName;
//   final String userId;
//   final String type;
//   final String mediaUrl;
//   final String postId;
//   final String userDP;
//   final String commentData;
//   final Timestamp timestamp;

//   ActivityFeedItem({
//     this.displayName,
//     this.userId,
//     this.type,
//     this.mediaUrl,
//     this.postId,
//     this.userDP,
//     this.commentData,
//     this.timestamp,
//   });

//   factory ActivityFeedItem.fromDocument(DocumentSnapshot doc) {
//     return ActivityFeedItem(
//       displayName: doc['displayName'],
//       userId: doc['userId'],
//       type: doc['type'],
//       postId: doc['postId'],
//       userDP: doc['userDP'],
//       commentData: doc['commentData'],
//       timestamp: doc['timestamp'],
//       mediaUrl: doc['mediaUrl'],
//     );
//   }

//   showPost(context) {
//     Navigator.push(
//         context,
//         MaterialPageRoute(
//             builder: (context) => PostScreen(
//                   postId: postId,
//                   userId: userId,
//                 )));
//   }

//   configureMediaPreview(context) {
//     if (type == "like" || type == "comment") {
//       mediaPreview = GestureDetector(
//         onTap: () => showPost(context),
//         child: Container(
//           height: 50.0,
//           width: 50.0,
//           child: AspectRatio(
//             aspectRatio: 16 / 9,
//             child: Container(
//               decoration: BoxDecoration(
//                 image: DecorationImage(
//                   fit: BoxFit.cover,
//                   image: CachedNetworkImageProvider(mediaUrl),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       );
//     } else {
//       mediaPreview = null;
//     }
//     if (type == 'like') {
//       activityItemText = "New Star On Your Post!";
//     } else if (type == 'follow') {
//       activityItemText = "$displayName Started Following You!";
//     } else if (type == 'comment') {
//       activityItemText = "New Comment On Your Post!";
//     } else {
//       activityItemText = "Error: Problem Loading Notification!";
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     configureMediaPreview(context);

//     return Padding(
//       padding: EdgeInsets.only(bottom: 1.5),
//       child: Container(
//         color: Colors.white.withOpacity(0),
//         child: ListTile(
//           title: GestureDetector(
//             onTap: () => showPost(context),
//             child: RichText(
//               overflow: TextOverflow.ellipsis,
//               text: TextSpan(
//                 style: TextStyle(
//                   fontSize: 15.0,
//                   color: Colors.black,
//                 ),
//                 children: [
//                   TextSpan(
//                     text: "",
//                     style: TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   TextSpan(
//                     text: '$activityItemText',
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           leading: CircleAvatar(
//             backgroundImage: CachedNetworkImageProvider(userDP),
//           ),
//           subtitle: Text(
//             "By $displayName.",
//             overflow: TextOverflow.ellipsis,
//           ),
//           trailing: mediaPreview,
//         ),
//       ),
//     );
//   }
// }

// showProfile(BuildContext context, {String profileId}) {
//   Navigator.push(
//       context,
//       MaterialPageRoute(
//           builder: (context) => Profile(
//                 profileId: profileId,
//               )));
// }


import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:fluttershare/pages/post_screen.dart';
import 'package:fluttershare/pages/profile.dart';
import 'package:fluttershare/widgets/header.dart';
import 'package:fluttershare/widgets/progress.dart';

class ActivityFeed extends StatefulWidget {
  @override
  _ActivityFeedState createState() => _ActivityFeedState();
}

class _ActivityFeedState extends State<ActivityFeed> {
  getActivityFeed() async {
    QuerySnapshot snapshot = await activityFeedRef
        .document(currentUser.id)
        .collection('feedItems')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .getDocuments();
    List<ActivityFeedItem> feedItems = [];
    snapshot.documents.forEach((doc) {
      feedItems.add(ActivityFeedItem.fromDocument(doc));
    });
    return feedItems;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: header(context, titleText: "Notifications"),
      body: Container(
          child: FutureBuilder(
        future: getActivityFeed(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          return ListView(
            children: snapshot.data,
          );
        },
      )),
    );
  }
}

Widget mediaPreview;
String activityItemText;

class ActivityFeedItem extends StatelessWidget {
  final String displayName;
  final String userId;
  final String type; // 'like', 'follow', 'comment'
  final String mediaUrl;
  final String postId;
  final String userDP;
  final String commentData;
  final Timestamp timestamp;

  ActivityFeedItem({
    this.displayName,
    this.userId,
    this.type,
    this.mediaUrl,
    this.postId,
    this.userDP,
    this.commentData,
    this.timestamp,
  });

  factory ActivityFeedItem.fromDocument(DocumentSnapshot doc) {
    return ActivityFeedItem(
      displayName: doc['displayName'],
      userId: doc['userId'],
      type: doc['type'],
      postId: doc['postId'],
      userDP: doc['userDP'],
      commentData: doc['commentData'],
      timestamp: doc['timestamp'],
      mediaUrl: doc['mediaUrl'],
    );
  }

  showPost(context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostScreen(
          postId: postId,
          userId: userId,
        ),
      ),
    );
  }

  configureMediaPreview(context) {
    if (type == "like" || type == 'comment') {
      mediaPreview = GestureDetector(
        onTap: () => showPost(context),
        child: Container(
          height: 50.0,
          width: 50.0,
          child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: CachedNetworkImageProvider(mediaUrl),
                  ),
                ),
              )),
        ),
      );
    } else {
      mediaPreview = null;
    }

    if (type == 'like') {
      activityItemText = "New Star On Your Post!";
    } else if (type == 'follow') {
      activityItemText = "$displayName Started Following You!";
    } else if (type == 'comment') {
      activityItemText = 'New Comment On Your Post!';
    } else {
      activityItemText = "Error: Loading Notification!";
    }
  }

  @override
  Widget build(BuildContext context) {
    configureMediaPreview(context);

    return Padding(
      padding: EdgeInsets.only(bottom: 1.5),
      child: Container(
        color: Colors.white,
        child: ListTile(
          title: GestureDetector(
            onTap: () => showProfile(context, profileId: userId),
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                  style: TextStyle(
                    fontSize: 15.0,
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(
                      text: '$activityItemText',
                    ),
                  ]),
            ),
          ),
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(userDP),
          ),
          subtitle: Text(
            "By $displayName",
          ),
          trailing: mediaPreview,
        ),
      ),
    );
  }
}

showProfile(BuildContext context, {String profileId}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => Profile(
        profileId: profileId,
      ),
    ),
  );
}
