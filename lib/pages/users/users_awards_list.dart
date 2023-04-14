import 'package:dellenhauer_admin/model/awards/awards_model.dart';
import 'package:dellenhauer_admin/providers/awards_provider.dart';
import 'package:dellenhauer_admin/providers/users_provider.dart';
import 'package:dellenhauer_admin/utils/colors.dart';
import 'package:dellenhauer_admin/utils/widgets/empty.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class UsersAwardsList extends StatefulWidget {
  const UsersAwardsList({
    super.key,
  });

  @override
  State<UsersAwardsList> createState() => _UsersAwardsListState();
}

class _UsersAwardsListState extends State<UsersAwardsList> {
  late AwardsProvider awardsProvider;
  late UsersProvider usersProvider;

  @override
  Widget build(BuildContext context) {
    awardsProvider = Provider.of<AwardsProvider>(context, listen: false);
    usersProvider = Provider.of<UsersProvider>(context, listen: true);
    return FractionallySizedBox(
      heightFactor: 0.8,
      widthFactor: 0.8,
      child: Scaffold(
          body: Column(
        children: [
          FutureBuilder<List<AwardsModel>>(
            future: awardsProvider.getAwardsFuture(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                return Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return awardsBuilder(snapshot.data![index]);
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
                child: CircularProgressIndicator(color: kPrimaryColor),
              );
            },
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
            ),
            child: const Text('Close'),
          ),
          const SizedBox(height: 20),
        ],
      )),
    );
  }

  Widget awardsBuilder(AwardsModel awardsModel) {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      margin: const EdgeInsets.only(top: 10, bottom: 10),
      child: ListTile(
        title: Text(awardsModel.name!),
        subtitle: Text(awardsModel.description!),
        isThreeLine: true,
        trailing: IconButton(
          color: usersProvider.selectedUserAwards
                  .any((element) => element.id == awardsModel.id)
              ? Colors.grey
              : kPrimaryColor,
          icon: const Icon(FontAwesomeIcons.circlePlus),
          onPressed: () {
            if (!usersProvider.selectedUserAwards
                .any((element) => element.id == awardsModel.id)) {
              usersProvider.setselectedUserAwards(awardsModel);
            }
          },
        ),
      ),
    );
  }
}
