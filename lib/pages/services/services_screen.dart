import 'package:dellenhauer_admin/providers/services_provider.dart';
import 'package:dellenhauer_admin/utils/styles.dart';
import 'package:dellenhauer_admin/utils/utils.dart';
import 'package:dellenhauer_admin/utils/widgets/empty.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  late ServicesProvider serviceProvider;
  final TextEditingController _serviceController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    _serviceController.selection = TextSelection.fromPosition(
        TextPosition(offset: _serviceController.text.length));
    final w = MediaQuery.of(context).size.width;
    serviceProvider = Provider.of<ServicesProvider>(context, listen: false);
    return Container(
      margin: const EdgeInsets.only(left: 30, top: 30, bottom: 30),
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
            'Services',
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
          // text field to add new service to our app
          Wrap(
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                child: TextFormField(
                  decoration: inputDecoration(
                    'Services',
                    'Enter new service...',
                    _serviceController,
                  ),
                  cursorColor: Colors.redAccent,
                  onChanged: (value) {
                    setState(() {
                      _serviceController.text = value;
                    });
                  },
                  controller: _serviceController,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: () {
                      if (_serviceController.text.trim().isNotEmpty) {
                        serviceProvider
                            .addNewService(
                          serviceName: _serviceController.text.trim(),
                        )
                            .whenComplete(() {
                          showSnackbar(context, 'Service added successfully');
                          setState(() {
                            _serviceController.clear();
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
              )
            ],
          ),
          const SizedBox(height: 10),
          Divider(color: Colors.grey.shade200),
          const SizedBox(height: 10),
          StreamBuilder(
            stream: serviceProvider.getServiceList(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return itemBuilder(snapshot.data![index].name!,
                          snapshot.data![index].isActive!, (value) {
                        serviceProvider.updateService(
                          serviceModel: snapshot.data![index],
                          isActive: value,
                        );
                      });
                    },
                  ),
                );
              } else if (snapshot.hasError) {
                return emptyPage(
                  FontAwesomeIcons.briefcase,
                  'No services found!',
                );
              }
              return const Center(
                child: CircularProgressIndicator(color: Colors.redAccent),
              );
            },
          )
        ],
      ),
    );
  }

  Widget itemBuilder(String title, bool value, ValueChanged<bool> onChanged) {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      margin: const EdgeInsets.only(top: 10, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
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
