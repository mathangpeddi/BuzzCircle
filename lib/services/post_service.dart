import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fp2/models/user.dart';
import 'package:fp2/screens/view_image.dart';
import 'package:fp2/services/services.dart';
import 'package:fp2/utils/firebase.dart';
import 'package:uuid/uuid.dart';

class PostService extends Service {
  String postId = const Uuid().v4();

//uploads profile picture to the users collection
  uploadProfilePicture(File image, User user) async {
    String? link = await uploadImage(profilePic, image);
    var ref = usersRef.doc(user.uid);
    ref.update({
      "photoUrl": link,
    });
  }

//uploads post to the post collection
uploadPost(File image, String location, String description) async {
  print('upload post function');
  
  // Step 1: Check Firebase Authentication
  if (firebaseAuth.currentUser == null) {
    print('User is not authenticated.');
    return;
  }

  // Step 2: Verify Firestore References
  print('Fetching user data...');
  DocumentSnapshot doc = await usersRef.doc(firebaseAuth.currentUser!.uid).get();
  print('User data fetched.');
  
  // Step 3: Check Firestore Security Rules
  if (!doc.exists) {
    print('User document does not exist.');
    return;
  }

  user = UserModel.fromJson(doc.data() as Map<String, dynamic>);
  var ref = postRef.doc();
  
  // Step 4: Test with Mock Data
  print('Uploading post data...');
  String? link = await uploadImage(posts, image);
  print('Image uploaded successfully.');
  
  // Step 5: Handle Errors
  ref.set({
    "id": ref.id,
    "postId": ref.id,
    "username": user!.username,
    "ownerId": firebaseAuth.currentUser!.uid,
    "mediaUrl": link,
    "description": description ?? "",
    "location": location ?? "Wooble",
    "timestamp": Timestamp.now(),
  }).then((_) {
    print('Post uploaded successfully.');
  }).catchError((e) {
    print('Error uploading post:');
    print(e);
  });
}


//upload a comment
  uploadComment(String currentUserId, String comment, String postId,
      String ownerId, String mediaUrl) async {
    DocumentSnapshot doc = await usersRef.doc(currentUserId).get();
    user = UserModel.fromJson(doc.data() as Map<String, dynamic>);
    await commentRef.doc(postId).collection("comments").add({
      "username": user!.username,
      "comment": comment,
      "timestamp": Timestamp.now(),
      "userDp": user!.photoUrl,
      "userId": user!.id,
    });
    bool isNotMe = ownerId != currentUserId;
    if (isNotMe) {
      addCommentToNotification("comment", comment, user!.username!, user!.id!,
          postId, mediaUrl, ownerId, user!.photoUrl!);
    }
  }

//add the comment to notification collection
  addCommentToNotification(
      String type,
      String commentData,
      String username,
      String userId,
      String postId,
      String mediaUrl,
      String ownerId,
      String userDp) async {
    await notificationRef.doc(ownerId).collection('notifications').add({
      "type": type,
      "commentData": commentData,
      "username": username,
      "userId": userId,
      "userDp": userDp,
      "postId": postId,
      "mediaUrl": mediaUrl,
      "timestamp": Timestamp.now(),
    });
  }

//add the likes to the notfication collection
  addLikesToNotification(String type, String username, String userId,
      String postId, String mediaUrl, String ownerId, String userDp) async {
    await notificationRef
        .doc(ownerId)
        .collection('notifications')
        .doc(postId)
        .set({
      "type": type,
      "username": username,
      "userId": firebaseAuth.currentUser!.uid,
      "userDp": userDp,
      "postId": postId,
      "mediaUrl": mediaUrl,
      "timestamp": Timestamp.now(),
    });
  }

  //remove likes from notification
  removeLikeFromNotification(
      String ownerId, String postId, String currentUser) async {
    bool isNotMe = currentUser != ownerId;

    if (isNotMe) {
      DocumentSnapshot doc = await usersRef.doc(currentUser).get();
      user = UserModel.fromJson(doc.data() as Map<String, dynamic>);
      notificationRef
          .doc(ownerId)
          .collection('notifications')
          .doc(postId)
          .get()
          .then((doc) => {
                if (doc.exists) {doc.reference.delete()}
              });
    }
  }
}
