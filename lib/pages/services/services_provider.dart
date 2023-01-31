import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ServicesModel {
  String? name;
  bool? isActive;
  String? id;
  ServicesModel({this.name, this.isActive, this.id});

  // from map
  ServicesModel.fromMap(Map<String, dynamic> map) {
    if (map.isEmpty) {
      return;
    }
    name = map['name'];
    isActive = map['isActive'] ?? false;
    id = map['id'];
  }
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'isActive': isActive,
      'id': id,
    };
  }
}

class ServicesProvider extends ChangeNotifier {
  BuildContext? context;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  void attachContext(BuildContext context) {
    this.context = context;
  }

  // getting services list
  Stream<List<ServicesModel>> getServiceList() {
    return firebaseFirestore
        .collection('admin')
        .doc('services')
        .collection('serviceCollection')
        .snapshots()
        .asyncMap((event) {
      List<ServicesModel> services = [];
      for (var document in event.docs) {
        services.add(ServicesModel.fromMap(document.data()));
      }
      return services;
    });
  }

  // update service status
  Future<void> updateService(
      {required ServicesModel serviceModel, required bool isActive}) async {
    await firebaseFirestore
        .collection('admin')
        .doc('services')
        .collection('serviceCollection')
        .doc(serviceModel.id)
        .update({
      'isActive': isActive,
    });
  }

  // adding a new service to our database
  Future<void> addNewService({required String serviceName}) async {
    DocumentReference a = await firebaseFirestore
        .collection('admin')
        .doc('services')
        .collection('serviceCollection')
        .doc();

    await firebaseFirestore
        .collection('admin')
        .doc('services')
        .collection('serviceCollection')
        .doc()
        .set(ServicesModel(
          id: a.id,
          isActive: true,
          name: serviceName,
        ).toJson());
  }
}
