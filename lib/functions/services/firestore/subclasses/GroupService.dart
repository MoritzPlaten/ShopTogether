import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shopping_app/functions/services/firestore/MyFirestoreService.dart';
import 'package:shopping_app/functions/services/firestore/subclasses/UserService.dart';
import 'package:shopping_app/objects/users/MyUsers.dart';

import '../../../../exceptions/MyCustomException.dart';
import '../../../../objects/groups/MyGroup.dart';
import '../../../../objects/products/MyProduct.dart';

class GroupService {

  ///[MyCustomException] Keys:
  ///- error: returns extern errors
  ///- no-user: user is not logged in!
  /// Has the [MyCustomException] of [UserService.addGroupUUIDsFromUser]
  void addGroup(MyGroup myGroup) async {

    try {

      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw MyCustomException("user is not logged in!", "no-user");
      }

      ///create a new group
      DocumentReference ref = FirebaseFirestore.instance.collection("groups").doc();

      ///update uuid from goup and add user who created the group
      myGroup.updateGroupUUID(ref.id);
      myGroup.updateUserUUIDs([user.uid]);
      myGroup.updateUserOwnerUUID(user.uid);
      await ref.set(myGroup.toMap());

      ///add the uuid from group in the current user
      await MyFirestoreService.userService.addGroupUUIDsToUser(user.uid, ref.id);
    } on MyCustomException catch(e) {

      throw MyCustomException("Group couldn't created: " + e.message, e.keyword);
    } catch(e) {

      throw MyCustomException(e.toString(), "error");
    }
  }

  void removeGroup(String groupUuid) async {

    DocumentReference<Map<String, dynamic>> refGroup =
    FirebaseFirestore.instance.collection("groups").doc(groupUuid);

    DocumentSnapshot<Map<String, dynamic>> groupSnapshot = await refGroup.get();

    if (groupSnapshot.exists) {

      List<dynamic> userUUIDs = groupSnapshot.get("userUUIDs");
      for (var userUUID in userUUIDs) {

        DocumentReference<Map<String, dynamic>> userRef =
        FirebaseFirestore.instance.collection("users").doc(userUUID.toString());

        DocumentSnapshot<Map<String, dynamic>> userSnapshot = await userRef.get();

        if (userSnapshot.exists) {

          List<String> groupUUIDs = List<String>.from(userSnapshot.get("groupUUIDs"));
          groupUUIDs.remove(groupUuid);
          userSnapshot.reference.update({
            "groupUUIDs": groupUUIDs,
          });
        }
      }
      refGroup.delete();
    }
  }

  void updateGroup(String groupUuid, MyProduct myProduct) {

  }

  Future<bool> isGroupExists(String groupUUID) async {

    DocumentReference<Map<String, dynamic>> ref =
    FirebaseFirestore.instance.collection("groups").doc(groupUUID);

    DocumentSnapshot<Map<String, dynamic>> snapshot = await ref.get();
    return snapshot.exists;
  }

  ///[MyCustomException] Keys:
  ///- snapchot-not-exists: the snapchot doesn't exists of the userUuid
  Future<void> addUserUUIDToGroup(String groupUUID, String userUUID) async {

    DocumentReference<Map<String, dynamic>> ref =
    FirebaseFirestore.instance.collection("groups").doc(groupUUID);

    DocumentSnapshot<Map<String, dynamic>> snapshot = await ref.get();

    if (snapshot.exists) {
      MyGroup group = MyGroup.fromMap(snapshot.data() as Map<String, dynamic>);
      List<String>? userUUIDsFromGroup = group.userUUIDs;
      userUUIDsFromGroup!.add(userUUID);

      FirebaseFirestore.instance
          .collection("groups")
          .doc(groupUUID)
          .update({"userUUIDs": userUUIDsFromGroup});
    } else {

      throw MyCustomException("the snapchot doesn't exists of the $groupUUID", "snapchot-not-exists");
    }
  }

  ///[MyCustomException] Keys:
  ///- snapchot-not-exists: the snapchot doesn't exists of the userUuid
  Future<void> removeUserUUIDFromGroup(String groupUUID, String userUUID) async {

    DocumentReference<Map<String, dynamic>> ref =
    FirebaseFirestore.instance.collection("groups").doc(groupUUID);

    DocumentSnapshot<Map<String, dynamic>> snapshot = await ref.get();

    if (snapshot.exists) {
      MyGroup group = MyGroup.fromMap(snapshot.data() as Map<String, dynamic>);
      List<String>? userUUIDsFromGroup = group.userUUIDs;
      userUUIDsFromGroup!.remove(userUUID);

      FirebaseFirestore.instance
          .collection("groups")
          .doc(groupUUID)
          .update({"userUUIDs": userUUIDsFromGroup});
    } else {

      throw MyCustomException("the snapchot doesn't exists of the $groupUUID", "snapchot-not-exists");
    }
  }

  /// [MyCustomException] Keys:
  /// - snapshot-not-exists: the snapshot of the isCurrentUserAlreadyInGroup(groupUUID) doesn`t exists!
  Future<int> getSizeOfMembers(String groupUUID) async {

    DocumentReference<Map<String, dynamic>> ref =
    FirebaseFirestore.instance.collection("groups").doc(groupUUID);

    DocumentSnapshot<Map<String, dynamic>> snapshot = await ref.get();

    if (!snapshot.exists) {
      throw MyCustomException("the snapshot of the $isCurrentUserInGroup(groupUUID) doesn`t exists!", "snapshot-not-exists");
    }

    int userLength = List<String>.from(snapshot.get("userUUIDs")).length;
    return userLength;
  }

  /// [MyCustomException] Keys:
  /// - snapshot-not-exists: the snapshot of the isCurrentUserAlreadyInGroup(groupUUID) doesn`t exists!
  Future<String> getNameOfGroup(String groupUUID) async {

    DocumentReference<Map<String, dynamic>> ref =
    FirebaseFirestore.instance.collection("groups").doc(groupUUID);

    DocumentSnapshot<Map<String, dynamic>> snapshot = await ref.get();

    if (!snapshot.exists) {
      throw MyCustomException("the snapshot of the $isCurrentUserInGroup(groupUUID) doesn`t exists!", "snapshot-not-exists");
    }

    String userLength = snapshot.get("groupName");
    return userLength;
  }

  /// [MyCustomException] Keys:
  /// - snapshot-not-exists: the snapshot of the isCurrentUserAlreadyInGroup(groupUUID) doesn`t exists!
  /// - not-logged-in: the current user is not logged in!
  Future<bool> isCurrentUserInGroup(String groupUUID) async {

    DocumentReference<Map<String, dynamic>> ref =
    FirebaseFirestore.instance.collection("groups").doc(groupUUID);

    DocumentSnapshot<Map<String, dynamic>> snapshot = await ref.get();

    if (!snapshot.exists) {
      throw MyCustomException("the snapshot of the $isCurrentUserInGroup(groupUUID) doesn`t exists!", "snapshot-not-exists");
    }

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw MyCustomException("the current user is not logged in!", "not-logged-in");
    }
    
    List<String> userUUIDs = List<String>.from(snapshot.get("userUUIDs"));
    
    return userUUIDs.contains(user.uid);
  }

  /// [MyCustomException] Keys:
  /// - snapshot-not-exists: the snapshot of the isCurrentUserAlreadyInGroup(groupUUID) doesn`t exists!
  /// - not-logged-in: the current user is not logged in!
  Future<bool> isSpecificUserInGroup(String userUUID, String groupUUID) async {

    DocumentReference<Map<String, dynamic>> ref =
    FirebaseFirestore.instance.collection("groups").doc(groupUUID);

    DocumentSnapshot<Map<String, dynamic>> snapshot = await ref.get();

    if (!snapshot.exists) {
      throw MyCustomException("the snapshot of the $isCurrentUserInGroup(groupUUID) doesn`t exists!", "snapshot-not-exists");
    }

    List<String> userUUIDs = List<String>.from(snapshot.get("userUUIDs"));

    return userUUIDs.contains(userUUID);
  }

  ///[MyCustomException] Keys:
  ///- snapshot-not-existent: snapshot doesn`t exists
  /*Stream<List<MyUser>> getMembersAsStream(String groupUUID) async* {
    Stream<DocumentSnapshot<Map<String, dynamic>>>groupStream = FirebaseFirestore.instance
        .collection("groups")
        .doc(groupUUID)
        .snapshots();

    await for (DocumentSnapshot snapshot in groupStream) {
      if (snapshot.exists) {
        MyGroup myGroup = MyGroup.fromMap(snapshot.data() as Map<String, dynamic>);
        List<String>? userUUIDs = myGroup.userUUIDs;

        if (userUUIDs != null && userUUIDs.isNotEmpty) {
          List<MyUser> users = [];

          for (String userUUID in userUUIDs) {
            MyUser user = await MyFirestoreService.userService.getUserAsObject(userUUID);
            users.add(user);
          }

          yield users;
        } else {
          yield [];
        }
      } else {
        throw MyCustomException(
            "the snapshot doesn't exist for $groupUUID", "snapshot-not-existent");
      }
    }
  }*/
  Future<Stream<List<MyUser>>> getMembersAsStream(String groupUUID) async {

    Stream<List<MyUser>> userStream = FirebaseFirestore.instance
        .collection("groups")
        .doc(groupUUID)
        .snapshots()
        .asyncMap((snapshot) {

      if (snapshot.exists) {
        MyGroup myGroup = MyGroup.fromMap(snapshot.data()!);
        List<String>? userUUIDs = myGroup.userUUIDs;

        if (userUUIDs != null && userUUIDs.isNotEmpty) {

          List<Future<MyUser>> userFutures = userUUIDs.map((String userUUID) =>
              MyFirestoreService.userService.getUserAsObject(userUUID)).toList();

          return Future.wait(userFutures);
        } else {
          return [];
        }
      } else {
        throw MyCustomException(
            "the snapshot doesn't exist for $groupUUID", "snapshot-not-existent");
      }
    });

    return userStream;
  }

  Future<List<String>> getMemberUUIDsAsList(String groupUUID) async {
    DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
        .collection("groups")
        .doc(groupUUID)
        .get();

    if (!snapshot.exists) {
      throw MyCustomException(
          "the snapshot doesn't exist for $groupUUID", "snapshot-not-existent");
    }

    MyGroup myGroup = MyGroup.fromMap(snapshot.data()!);
    List<String>? userUUIDs = myGroup.userUUIDs;

    if (userUUIDs == null) {
      return [];
    }

    if (userUUIDs.isEmpty) {
      return [];
    }

    return userUUIDs;
  }

  ///[MyCustomException] Keys:
  ///- snapshot-not-existent: snapshot doesn`t exists
  ///- not-logged-in: User is not logged in!
  /*Stream<bool> isCurrentMemberInGroupAsStream(String groupUUID) async* {
    StreamController<bool> controller = StreamController<bool>();

    Stream<DocumentSnapshot<Map<String, dynamic>>> groupStream = FirebaseFirestore.instance
        .collection("groups")
        .doc(groupUUID)
        .snapshots();

    await for (DocumentSnapshot snapshot in groupStream) {
      if (!snapshot.exists) {
        controller.addError(MyCustomException("The snapshot doesn't exist for $groupUUID", "snapshot-not-existent"));
        return;
      }

      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        controller.addError(MyCustomException("User is not logged in!", "not-logged-in"));
        return;
      }

      MyGroup myGroup = MyGroup.fromMap(snapshot.data()! as Map<String, dynamic>);
      List<String>? userUUIDs = myGroup.userUUIDs;

      if (userUUIDs != null && userUUIDs.isNotEmpty) {
        bool isUserInGroup = await GroupService().isSpecificUserInGroup(user.uid, groupUUID);
        yield isUserInGroup;
      } else {
        yield false;
      }
    }
  }*/

  Future<Stream<bool>> isCurrentMemberInGroupAsStream(String groupUUID) async {
    StreamController<bool> controller = StreamController<bool>();

    FirebaseFirestore.instance
        .collection("groups")
        .doc(groupUUID)
        .snapshots()
        .listen((snapshot) async {
      if (!snapshot.exists) {
        controller.addError(MyCustomException("The snapshot doesn't exist for $groupUUID", "snapshot-not-existent"));
        return;
      }

      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        controller.addError(MyCustomException("User is not logged in!", "not-logged-in"));
        return;
      }

      MyGroup myGroup = MyGroup.fromMap(snapshot.data()!);
      List<String>? userUUIDs = myGroup.userUUIDs;

      if (userUUIDs != null && userUUIDs.isNotEmpty) {
        bool isUserInGroup = await GroupService().isSpecificUserInGroup(user.uid, groupUUID);
        controller.add(isUserInGroup);
      } else {
        controller.add(false);
      }
    }, onError: (error) {
      controller.addError(error);
    });

    return controller.stream;
  }

  /// [MyCustomException] Keys:
  /// - no-user: no user is logged in!
  /// - group-exists-not: the groupUUID doesn`t exists!
  Future<bool> isUserGroupOwner(String groupUUID, String userUUID) async {

    if (await isGroupExists(groupUUID) == false) {
      throw MyCustomException("the group doesn`t exists", "group-exists-not");
    }

    DocumentReference<Map<String, dynamic>> ref =
    FirebaseFirestore.instance.collection("groups").doc(groupUUID);

    DocumentSnapshot<Map<String, dynamic>> snapshot = await ref.get();

    if (snapshot.exists == false) {
      throw MyCustomException("the group snapshot doesn`t exists!", "snapshot-exists-not");
    }

    String ownerUUID = snapshot.get("userOwnerUUID");

    if (ownerUUID.compareTo(userUUID) == 0) {
      return true;
    }

    return false;
  }
}