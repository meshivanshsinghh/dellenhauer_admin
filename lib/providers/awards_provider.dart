import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dellenhauer_admin/model/awards/awards_model.dart';
import 'package:flutter/material.dart';

class AwardsProvider extends ChangeNotifier {
  BuildContext? context;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  void attachContext(BuildContext context) {
    this.context = context;
  }

  // getting courses list
  Stream<List<AwardsModel>> getAwards() {
    return firebaseFirestore
        .collection('admin')
        .doc('awards')
        .collection('awardsCollection')
        .snapshots()
        .asyncMap((event) {
      List<AwardsModel> awards = [];
      for (var document in event.docs) {
        awards.add(AwardsModel.fromMap(document.data()));
      }
      return awards;
    });
  }

  // add new award to list
  Future<void> addNewAward(
      {required String title, required String description}) async {
    DocumentReference d = firebaseFirestore
        .collection('admin')
        .doc('awards')
        .collection('awardsCollection')
        .doc();
    AwardsModel awardsModel = AwardsModel(
        id: d.id, name: title, description: description, isActive: true);
    await firebaseFirestore
        .collection('admin')
        .doc('awards')
        .collection('awardsCollection')
        .doc(d.id)
        .set(awardsModel.toMap());

    // updating the total count for courses
  }

  // update course
  Future<void> updateAward({required String id, required bool isActive}) async {
    await firebaseFirestore
        .collection('admin')
        .doc('awards')
        .collection('awardsCollection')
        .doc(id)
        .update({
      'isActive': isActive,
    });
  }
}
