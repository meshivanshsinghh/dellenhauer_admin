import 'package:dellenhauer_admin/pages/awards/awards_model.dart';
import 'package:dellenhauer_admin/pages/awards/awards_provider.dart';
import 'package:dellenhauer_admin/utils/styles.dart';
import 'package:dellenhauer_admin/utils/utils.dart';
import 'package:dellenhauer_admin/utils/widgets/empty.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class AwardsScreen extends StatefulWidget {
  const AwardsScreen({super.key});

  @override
  State<AwardsScreen> createState() => _AwardsScreenState();
}

class _AwardsScreenState extends State<AwardsScreen> {
  late AwardsProvider coursesProvider;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    coursesProvider = Provider.of<AwardsProvider>(context, listen: false);
    _titleController.selection = TextSelection.fromPosition(
        TextPosition(offset: _titleController.text.length));
    _descriptionController.selection = TextSelection.fromPosition(
        TextPosition(offset: _descriptionController.text.length));

    return Container(
      margin: const EdgeInsets.all(30),
      padding: EdgeInsets.only(
        left: w * 0.05,
        right: w * 0.20,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[300]!,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.05),
          const Text(
            'Awards',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w800,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 5, bottom: 15),
            height: 3,
            width: 50,
            decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(15)),
          ),
          // text field to add new course
          Wrap(
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                child: TextFormField(
                  controller: _titleController,
                  decoration: inputDecoration(
                      'Title', 'Enter new title...', _titleController),
                  cursorColor: Colors.redAccent,
                  onChanged: (value) {
                    setState(() {
                      _titleController.text = value;
                    });
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                child: TextFormField(
                  controller: _descriptionController,
                  decoration: inputDecoration('Description',
                      'Enter new description...', _descriptionController),
                  cursorColor: Colors.redAccent,
                  onChanged: (value) {
                    setState(() {
                      _descriptionController.text = value;
                    });
                  },
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: () {
                      if (_titleController.text.trim().isNotEmpty &&
                          _descriptionController.text.trim().isNotEmpty) {
                        coursesProvider
                            .addNewAward(
                          title: _titleController.text.trim(),
                          description: _descriptionController.text.trim(),
                        )
                            .whenComplete(() {
                          showSnackbar(context, 'Award created successfully!');
                          setState(() {
                            _titleController.clear();
                            _descriptionController.clear();
                          });
                        });
                      } else {
                        showSnackbar(context, 'Please fill out all field');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                    ),
                    child: const Text('Add')),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(color: Colors.grey.shade200),
          const SizedBox(height: 10),
          // stream builder for showcasing items from database
          StreamBuilder<List<AwardsModel>>(
              stream: coursesProvider.getAwards(),
              builder: (context, AsyncSnapshot<List<AwardsModel>> snapshot) {
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return Expanded(
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          return courseItemBuilder(
                              snapshot.data![index].name!,
                              snapshot.data![index].description!,
                              snapshot.data![index].isActive!, (value) {
                            coursesProvider.updateAward(
                              id: snapshot.data![index].id!,
                              isActive: value,
                            );
                          });
                        }),
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
              })
        ],
      ),
    );
  }

  Widget courseItemBuilder(String title, String description, bool value,
      ValueChanged<bool> onChanged) {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      margin: const EdgeInsets.only(top: 10, bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: ListTile(
              title: Text(title),
              subtitle: Text(description),
              isThreeLine: true,
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.redAccent,
          )
        ],
      ),
    );
  }
}
