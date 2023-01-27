import 'package:dellenhauer_admin/pages/overview/overview_provider.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key});

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  late OverviewProvider overviewProvider;
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      overviewProvider = Provider.of<OverviewProvider>(context, listen: false);
      overviewProvider.attachContext(context);
      overviewProvider.loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    overviewProvider = Provider.of<OverviewProvider>(context, listen: true);
    return Container(
        margin: const EdgeInsets.all(30),
        padding: EdgeInsets.only(left: w * 0.05),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey[300]!,
                blurRadius: 10,
                offset: const Offset(3, 3),
              ),
            ]),
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.only(top: 30, bottom: 10),
          child: overviewProvider.userCount == 0 &&
                  overviewProvider.requestCount == 0 &&
                  overviewProvider.channelCount == 0 &&
                  overviewProvider.servicesCount == 0
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Colors.redAccent,
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    overviewProvider.loadData(reload: true);
                  },
                  color: Colors.red,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Hey Admin!',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 30),
                        ),
                        const SizedBox(height: 30),
                        Wrap(
                          direction: Axis.horizontal,
                          runSpacing: 10,
                          spacing: 10,
                          children: [
                            card('TOTAL USERS', overviewProvider.userCount,
                                FontAwesomeIcons.solidUser),
                            card(
                                'TOTAL CHANNELS',
                                overviewProvider.channelCount,
                                FontAwesomeIcons.peopleGroup),
                            card(
                                'TOTAL JOIN REQUESTS',
                                overviewProvider.requestCount,
                                FontAwesomeIcons.userPlus),
                            card(
                                'TOTAL SERVICES',
                                overviewProvider.servicesCount,
                                FontAwesomeIcons.briefcase),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
        ));
  }

  // card widget
  Widget card(String title, int number, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(30),
      margin: const EdgeInsets.only(bottom: 10),
      height: 180,
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[300]!,
            blurRadius: 10,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 5, bottom: 5),
            height: 2,
            width: 30,
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, size: 30, color: Colors.redAccent),
              const SizedBox(width: 20),
              Text(
                number.toString(),
                style: const TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
