import 'dart:async';

import 'package:country_picker/country_picker.dart';
import 'package:dellenhauer_admin/pages/channels/channels_screen.dart';
import 'package:dellenhauer_admin/pages/settings/settings_provider.dart';
import 'package:dellenhauer_admin/utils/colors.dart';
import 'package:dellenhauer_admin/utils/utils.dart';
import 'package:dellenhauer_admin/utils/widgets/empty.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import 'package:provider/provider.dart';

import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/standalone.dart' as tz;

class BlockedNumbers extends StatefulWidget {
  const BlockedNumbers({super.key});

  @override
  State<BlockedNumbers> createState() => _BlockedNumbersState();
}

class _BlockedNumbersState extends State<BlockedNumbers> {
  Country selectedCountry = CountryParser.parseCountryCode('DE');
  final TextEditingController phoneController = TextEditingController();
  late SettingsProvider settingsProvider;
  final _debouncer = Debouncer(milliseconds: 100);
  late String orderBy;
  String? sortByText;
  late bool descending;

  bool checkPhoneNumber() {
    final frPhone0 = PhoneNumber.parse(
      '+${selectedCountry.phoneCode}${phoneController.text.trim()}',
    );
    bool isValid = frPhone0.isValid(type: PhoneNumberType.mobile);

    return isValid;
  }

  @override
  void initState() {
    super.initState();
    sortByText = 'Newest First';
    orderBy = 'createdAt';
    descending = true;
    Future.delayed(Duration.zero, () {
      settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
      settingsProvider.attachContext(context);
      settingsProvider.setLoading(true);
      settingsProvider.getUsersData(orderBy: orderBy, descending: descending);
    });
  }

  refreshData() {
    settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    settingsProvider.setLastVisible(snapshot: null);
    settingsProvider.setLoading(true);
    settingsProvider.data.clear();
    settingsProvider.getUsersData(orderBy: orderBy, descending: descending);
    settingsProvider.notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
    _debouncer.dispose();
    phoneController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    settingsProvider = Provider.of<SettingsProvider>(context, listen: true);
    return Scaffold(
      appBar: AppBar(),
      body: Container(
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
            Row(
              children: [
                const Text(
                  'Blocked Numbers',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                sortingPopup(),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    refreshData();
                  },
                  child: Container(
                    margin: const EdgeInsets.only(left: 20),
                    child: const Icon(
                      FontAwesomeIcons.arrowsRotate,
                      color: kPrimaryColor,
                    ),
                  ),
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.only(top: 5, bottom: 15),
              height: 3,
              width: 50,
              decoration: BoxDecoration(
                color: kPrimaryColor,
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 10, top: 20),
              child: Row(
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      showCountryPicker(
                        countryListTheme: CountryListThemeData(
                          textStyle: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 15,
                          ),
                          inputDecoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  const BorderSide(color: Colors.black12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  const BorderSide(color: Colors.black12),
                            ),
                            prefixIcon: Icon(
                              FontAwesomeIcons.magnifyingGlass,
                              color: kPrimaryColor.withOpacity(0.5),
                              size: 15,
                            ),
                            hintText: 'Search',
                          ),
                          borderRadius: BorderRadius.circular(0),
                          bottomSheetHeight: 550,
                        ),
                        favorite: ['DE', 'AT', 'CH', 'ES', 'FR'],
                        showPhoneCode: true,
                        context: context,
                        onSelect: (value) {
                          setState(() {
                            selectedCountry = value;
                          });
                        },
                      );
                    },
                    child: Container(
                      alignment: Alignment.center,
                      width: 80,
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      child: Text(
                        '${selectedCountry.flagEmoji} ${selectedCountry.phoneCode}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontFamily: 'Poppins',
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      cursorColor: kPrimaryColor,
                      textAlign: TextAlign.start,
                      controller: phoneController,
                      maxLength: 12,
                      onChanged: (value) {
                        setState(() {});
                      },
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.only(left: 10),
                        hintText: "Enter phone number",
                        hintStyle: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.grey.shade600),
                        counterText: "",
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.black12,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.black12,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        suffixIcon: checkPhoneNumber()
                            ? const Icon(
                                FontAwesomeIcons.circleCheck,
                                color: Colors.green,
                                size: 32,
                              )
                            : null,
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.80,
              height: 50,
              child: ElevatedButton(
                onPressed: checkPhoneNumber() ? addPhoneNumber : null,
                style: ButtonStyle(
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                      if (states.contains(MaterialState.disabled)) {
                        return Colors.grey;
                      }
                      return kPrimaryColor;
                    },
                  ),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                  ),
                ),
                child: const Text(
                  'Add Number',
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(
              child: settingsProvider.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: kPrimaryColor))
                  : !settingsProvider.hasData
                      ? emptyPage(
                          FontAwesomeIcons.phone,
                          'No Blocked Phone Numbers!',
                        )
                      : NotificationListener<ScrollUpdateNotification>(
                          onNotification: (notification) {
                            return false;
                          },
                          child: ListView.builder(
                            shrinkWrap: true,
                            padding: const EdgeInsets.only(
                              top: 20,
                              left: 20,
                            ),
                            itemCount: settingsProvider.data.length + 1,
                            itemBuilder: (context, index) {
                              if (index < settingsProvider.data.length) {
                                String phone =
                                    settingsProvider.data[index]['phoneNumber'];
                                return ListTile(
                                  contentPadding:
                                      const EdgeInsets.only(bottom: 10),
                                  title: Container(
                                    margin: const EdgeInsets.only(bottom: 5),
                                    child: Text(
                                      phone,
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  subtitle: Text(
                                    getCreatedDate(
                                      timestamp: settingsProvider.data[index]
                                          ['createdAt'],
                                    ),
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(
                                      FontAwesomeIcons.trash,
                                      color: Colors.red.shade400,
                                    ),
                                    onPressed: () {
                                      deletingUser(
                                          context,
                                          'Delete?',
                                          'Want to remove this phone number from blocked-number list',
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: kPrimaryColor,
                                            ),
                                            onPressed: () {
                                              settingsProvider
                                                  .removeNumberFromDatabase(
                                                phone,
                                              )
                                                  .whenComplete(() {
                                                Navigator.of(context).pop();
                                                showSnackbar(
                                                  context,
                                                  'Removed successfully from database',
                                                );
                                                refreshData();
                                              });
                                            },
                                            child: const Text(
                                              'YES',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: kPrimaryColor,
                                            ),
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                            child: const Text(
                                              'NO',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ));
                                    },
                                  ),
                                );
                              }
                              return Center(
                                child: Opacity(
                                  opacity: settingsProvider.isLoadingMoreContent
                                      ? 1.0
                                      : 0.0,
                                  child: const SizedBox(
                                    width: 32,
                                    height: 32,
                                    child: CircularProgressIndicator(
                                      color: kPrimaryColor,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
            )
          ],
        ),
      ),
    );
  }

  void addPhoneNumber() async {
    await settingsProvider
        .addPhoneNumber(
      '+${selectedCountry.phoneCode}${phoneController.text.trim()}',
    )
        .then((value) {
      if (value) {
        showSnackbar(
          context,
          'Phone number has been added to blocked number list',
        );
        refreshData();
      } else {
        showSnackbar(
          context,
          'Phone number already present in blocked number  list',
        );
      }
    });
  }

  String getCreatedDate({
    required int timestamp,
  }) {
    tz.initializeTimeZones();
    final berlin = tz.getLocation('Europe/Berlin');

    final berlinTime =
        tz.TZDateTime.fromMillisecondsSinceEpoch(berlin, timestamp);
    final formatter = DateFormat('d.M.y H:m:s');
    final berlinFormatted = formatter.format(berlinTime);
    return 'Added at: $berlinFormatted';
  }

  Widget sortingPopup() {
    return PopupMenuButton(
      child: Container(
        height: 40,
        alignment: Alignment.center,
        padding: const EdgeInsets.only(left: 20, right: 20),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FontAwesomeIcons.arrowDown,
              size: 20,
              color: Colors.grey[800],
            ),
            const SizedBox(width: 10),
            Text(
              'Sort By - $sortByText',
              style: TextStyle(
                color: Colors.grey[900],
                fontWeight: FontWeight.w500,
              ),
            )
          ],
        ),
      ),
      itemBuilder: (context) {
        return const [
          PopupMenuItem(value: 'new', child: Text('Newest First')),
          PopupMenuItem(value: 'old', child: Text('Oldest First')),
        ];
      },
      onSelected: (dynamic value) {
        if (value == 'new') {
          setState(() {
            sortByText = 'Newest First';
            orderBy = 'createdAt';
            descending = true;
          });
        } else if (value == 'old') {
          setState(() {
            sortByText = 'Oldest First';
            orderBy = 'createdAt';
            descending = false;
          });
        }
        refreshData();
      },
    );
  }
}
