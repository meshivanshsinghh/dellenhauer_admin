import 'package:dellenhauer_admin/model/courses/courses_model.dart';
import 'package:dellenhauer_admin/providers/courses_provider.dart';
import 'package:dellenhauer_admin/providers/users_provider.dart';
import 'package:dellenhauer_admin/utils/widgets/empty.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class UsersCoursesList extends StatefulWidget {
  const UsersCoursesList({super.key});

  @override
  State<UsersCoursesList> createState() => _UsersCoursesListState();
}

class _UsersCoursesListState extends State<UsersCoursesList> {
  late CoursesProvider coursesProvider;
  late UsersProvider usersProvider;
  @override
  Widget build(BuildContext context) {
    coursesProvider = Provider.of<CoursesProvider>(context, listen: false);
    usersProvider = Provider.of<UsersProvider>(context, listen: true);
    return FractionallySizedBox(
      heightFactor: 0.8,
      widthFactor: 0.8,
      child: Scaffold(
          body: Column(
        children: [
          FutureBuilder<List<CoursesModel>>(
            future: coursesProvider.getAwardsFuture(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                return Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return coursesBuilder(snapshot.data![index]);
                    },
                  ),
                );
              } else if (snapshot.hasError) {
                emptyPage(FontAwesomeIcons.circleXmark, 'Error');
              } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                return Center(
                  child: emptyPage(
                    FontAwesomeIcons.trophy,
                    'No awards found!',
                  ),
                );
              }
              return const Center(
                child: CircularProgressIndicator(color: Colors.redAccent),
              );
            },
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
            ),
            child: const Text('Close'),
          ),
          const SizedBox(height: 20),
        ],
      )),
    );
  }

  Widget coursesBuilder(CoursesModel coursesModel) {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      margin: const EdgeInsets.only(top: 10, bottom: 10),
      child: ListTile(
        title: Text(coursesModel.name!),
        subtitle: Text(coursesModel.description!),
        isThreeLine: true,
        trailing: IconButton(
          icon: const Icon(FontAwesomeIcons.circlePlus),
          onPressed: () {
            usersProvider.setSelectedCourses(coursesModel);
          },
        ),
      ),
    );
  }
}
