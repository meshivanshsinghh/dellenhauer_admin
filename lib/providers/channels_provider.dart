import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dellenhauer_admin/model/channel/channel_model.dart';
import 'package:dellenhauer_admin/model/channel/related_channel_model.dart';
import 'package:dellenhauer_admin/model/users/user_model.dart';
import 'package:dellenhauer_admin/utils/utils.dart';
import 'package:flutter/material.dart';

class ChannelProvider extends ChangeNotifier {
  BuildContext? context;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  DocumentSnapshot? _lastVisible;
  DocumentSnapshot? get lastVisible => _lastVisible;
  bool _hasData = false;
  bool get hasData => _hasData;
  List<DocumentSnapshot> _channelData = [];
  List<DocumentSnapshot> get channelData => _channelData;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  List<RelatedChannel> _relatedChannels = [];
  List<RelatedChannel> get relatedChannels => _relatedChannels;

  void attachContext(BuildContext context) {
    this.context = context;
  }

  void setRelatedChannel(RelatedChannel relatedChannel) {
    _relatedChannels.add(relatedChannel);
    notifyListeners();
  }

  void removeRelatedChannel(String relatedChannelId) {
    for (var d in _relatedChannels) {
      if (d.relatedChannelId == relatedChannelId) {
        _relatedChannels.remove(d);
      }
    }
    notifyListeners();
  }

  void setLastVisible({DocumentSnapshot? documentSnapshot}) {
    _lastVisible = documentSnapshot;
    notifyListeners();
  }

  Future<void> getChannelData({
    required String orderBy,
    required bool descending,
  }) async {
    QuerySnapshot data;
    if (_lastVisible == null) {
      data = await firebaseFirestore
          .collection('channels')
          .orderBy(orderBy, descending: descending)
          .limit(10)
          .get();
    } else {
      data = await firebaseFirestore
          .collection('channels')
          .orderBy(orderBy, descending: descending)
          .startAfter([_lastVisible![orderBy]])
          .limit(10)
          .get();
    }
    if (data.docs.isNotEmpty) {
      _lastVisible = data.docs[data.docs.length - 1];
      _isLoading = false;
      _hasData = true;
      _channelData.addAll(data.docs);
      notifyListeners();
    } else {
      if (_lastVisible == null) {
        _isLoading = false;
        _hasData = false;
        notifyListeners();
      } else {
        _isLoading = false;
        _hasData = true;
        showSnackbar(context!, 'No more channels available');
        notifyListeners();
      }
    }
  }

  void setLoading({bool isLoading = false}) {
    _isLoading = isLoading;
    notifyListeners();
  }

  // getting user model from list of users
  Future<List<UserModel>> getUserDataFromUserId({
    isReload = true,
    required String groupId,
    required bool isModerator,
  }) async {
    // getting the channel data first
    List<UserModel> userData = [];
    List<String> id = [];
    await firebaseFirestore
        .collection('channels')
        .doc(groupId)
        .get()
        .then((value) async {
      ChannelModel channelData = ChannelModel.fromMap(value.data() as dynamic);

      if (isModerator) {
        id.addAll(channelData.moderatorsId!);
      } else {
        id.addAll(channelData.membersId!);
      }
    });

    // getting data from user id
    for (var userId in id) {
      await firebaseFirestore
          .collection('users')
          .doc(userId)
          .get()
          .then((value) {
        if (value.exists) {
          userData.add(UserModel.fromJson(value.data() as dynamic));
        }
      });
    }
    return userData;
  }

  Stream<List<UserModel>> getUserStream({
    required String groupId,
    required bool isModerator,
  }) {
    return firebaseFirestore
        .collection('channels')
        .doc(groupId)
        .snapshots()
        .asyncMap((event) async {
      ChannelModel channelData = ChannelModel.fromMap(event.data() as dynamic);

      if (isModerator) {
        List<UserModel> moderatorList = [];
        for (var id in channelData.moderatorsId!) {
          await firebaseFirestore
              .collection('users')
              .doc(id)
              .get()
              .then((value) {
            if (value.exists) {
              moderatorList.add(UserModel.fromJson(value.data() as dynamic));
            }
          });
        }
        return moderatorList;
      } else {
        List<UserModel> membersList = [];
        for (var id in channelData.membersId!) {
          await firebaseFirestore
              .collection('users')
              .doc(id)
              .get()
              .then((value) {
            if (value.exists) {
              membersList.add(UserModel.fromJson(value.data() as dynamic));
            }
          });
        }
        return membersList;
      }
    });
  }

  Future<List<ChannelModel>> getChannelList() async {
    List<ChannelModel> channels = [];
    await firebaseFirestore.collection('channels').get().then((value) {
      for (var document in value.docs) {
        if (document.exists) {
          channels.add(ChannelModel.fromMap(document.data()));
        }
      }
    });
    return channels;
  }

  Future<List<UserModel>> getUserList() async {
    List<UserModel> users = [];
    await firebaseFirestore.collection('users').get().then((value) {
      for (var document in value.docs) {
        if (document.exists) {
          users.add(UserModel.fromJson(document.data()));
        }
      }
    });
    return users;
  }

  Future<void> addUserToChannel(
      {required String userId,
      required bool isModerator,
      required String channelId}) async {
    DocumentSnapshot documentSnapshot =
        await firebaseFirestore.collection('channels').doc(channelId).get();
    if (documentSnapshot.exists) {
      ChannelModel channelData =
          ChannelModel.fromMap(documentSnapshot.data() as dynamic);
      if (isModerator) {
        if (!channelData.moderatorsId!.contains(userId)) {
          await firebaseFirestore.collection('channels').doc(channelId).update({
            'moderators_id': FieldValue.arrayUnion([userId])
          });
        }
      } else {
        if (!channelData.membersId!.contains(userId)) {
          await firebaseFirestore.collection('channels').doc(channelId).update({
            'members_id': FieldValue.arrayUnion([userId])
          });
        }
      }
    }
  }

  // removing id from collection
  Future<void> removeUserFromChannel(
      {required String userId,
      required bool isModerator,
      required String channelId}) async {
    await firebaseFirestore
        .collection('channels')
        .doc(channelId)
        .update(isModerator
            ? {
                'moderators_id': FieldValue.arrayRemove([userId])
              }
            : {
                'members_id': FieldValue.arrayRemove([userId])
              });
  }

  // updating channel data
  Future<void> updateChannelData({
    required String channelName,
    required String channelDescription,
    required bool autoJoin,
    required bool readOnly,
    required bool joinAccessRequired,
    required String visibility,
    required String channelId,
    required List<RelatedChannel> relatedChannels,
  }) async {
    _isLoading = true;
    notifyListeners();
    await firebaseFirestore.collection('channels').doc(channelId).update({
      'channel_name': channelName,
      'channel_description': channelDescription,
      'channel_autojoin': autoJoin,
      'related_channels': relatedChannels.map((e) => e.toMap()).toList(),
      'channel_readonly': readOnly,
      'join_access_required': joinAccessRequired,
      'visibility': visibility,
    }).whenComplete(() {
      _isLoading = false;
      notifyListeners();
    });
  }

  // deleting a channel from databse
  Future<void> deleteChannelFromDatabase({
    required String channelId,
  }) async {
    await firebaseFirestore.collection('channels').doc(channelId).delete();
  }
}
