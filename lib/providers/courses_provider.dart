import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dellenhauer_admin/model/courses/courses_model.dart';
import 'package:flutter/material.dart';

class CoursesProvider extends ChangeNotifier {
  BuildContext? context;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  void attachContext(BuildContext context) {
    this.context = context;
  }

  // getting courses list
  Stream<List<CoursesModel>> getCourses() {
    return firebaseFirestore
        .collection('admin')
        .doc('courses')
        .collection('coursesCollection')
        .snapshots()
        .asyncMap((event) {
      List<CoursesModel> courses = [];
      for (var document in event.docs) {
        courses.add(CoursesModel.fromMap(document.data()));
      }
      return courses;
    });
  }

  // future builder
  Future<List<CoursesModel>> getAwardsFuture() async {
    List<CoursesModel> courses = [];
    await firebaseFirestore
        .collection('admin')
        .doc('courses')
        .collection('coursesCollection')
        .get()
        .then((value) {
      for (var document in value.docs) {
        if (document.data()['isActive'] == true) {
          courses.add(CoursesModel.fromMap(document.data()));
        }
      }
    });
    return courses;
  }

  // add new course to list
  Future<void> addNewCourse(
      {required String title, required String description}) async {
    DocumentReference d = firebaseFirestore
        .collection('admin')
        .doc('courses')
        .collection('coursesCollection')
        .doc();
    CoursesModel coursesModel = CoursesModel(
        id: d.id, name: title, description: description, isActive: true);
    await firebaseFirestore
        .collection('admin')
        .doc('courses')
        .collection('coursesCollection')
        .doc(d.id)
        .set(coursesModel.toMap());

    // updating the total count for courses
  }

  // update course
  Future<void> updateCourse(
      {required String id, required bool isActive}) async {
    await firebaseFirestore
        .collection('admin')
        .doc('courses')
        .collection('coursesCollection')
        .doc(id)
        .update({
      'isActive': isActive,
    });
  }
}
