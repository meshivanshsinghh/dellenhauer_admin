import 'package:dellenhauer_admin/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AnalyticsDatePickerWidget extends StatefulWidget {
  final Function(DateRange selectedDateRange) selectedDateRange;
  const AnalyticsDatePickerWidget({
    super.key,
    required this.selectedDateRange,
  });

  @override
  State<AnalyticsDatePickerWidget> createState() =>
      _AnalyticsDatePickerWidgetState();
}

class _AnalyticsDatePickerWidgetState extends State<AnalyticsDatePickerWidget> {
  DateRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _selectedDateRange = DateRange(
      DateTime.now().subtract(const Duration(days: 7)),
      DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        showPickerDialog();
      },
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
                FontAwesomeIcons.calendar,
                size: 18,
                color: Colors.grey[800],
              ),
              const SizedBox(width: 10),
              Text(
                _selectedDateRange.toString(),
                style: TextStyle(
                  color: Colors.grey[900],
                  fontWeight: FontWeight.w500,
                ),
              )
            ],
          )),
    );
  }

  void showPickerDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.selectedDateRange(
                  _selectedDateRange ??
                      DateRange(
                        DateTime.now().subtract(const Duration(days: 7)),
                        DateTime.now(),
                      ),
                );
              },
              child: const Text(
                'OK',
                style: TextStyle(
                  color: kPrimaryColor,
                ),
              ),
            )
          ],
          content: datePickerBuilder(context, (DateRange? range) {
            setState(() {
              _selectedDateRange = range;
            });
          }),
        );
      },
    );
  }

  Widget datePickerBuilder(
          BuildContext context, dynamic Function(DateRange?) onDateRangeChanged,
          [bool doubleMonth = true]) =>
      DateRangePickerWidget(
        height: 350,
        doubleMonth: doubleMonth,
        quickDateRanges: [
          QuickDateRange(dateRange: null, label: "Remove date range"),
          QuickDateRange(
            label: 'Last 3 days',
            dateRange: DateRange(
              DateTime.now().subtract(const Duration(days: 3)),
              DateTime.now(),
            ),
          ),
          QuickDateRange(
            label: 'Last 7 days',
            dateRange: DateRange(
              DateTime.now().subtract(const Duration(days: 7)),
              DateTime.now(),
            ),
          ),
          QuickDateRange(
            label: 'Last 30 days',
            dateRange: DateRange(
              DateTime.now().subtract(const Duration(days: 30)),
              DateTime.now(),
            ),
          ),
          QuickDateRange(
            label: 'Last 90 days',
            dateRange: DateRange(
              DateTime.now().subtract(const Duration(days: 90)),
              DateTime.now(),
            ),
          ),
          QuickDateRange(
            label: 'Last 180 days',
            dateRange: DateRange(
              DateTime.now().subtract(const Duration(days: 180)),
              DateTime.now(),
            ),
          ),
        ],
        minimumDateRangeLength: 2,
        initialDateRange: _selectedDateRange,
        disabledDates: [DateTime(2023, 11, 20)],
        initialDisplayedDate: _selectedDateRange != null
            ? _selectedDateRange!.start
            : DateTime(2023, 11, 20),
        onDateRangeChanged: onDateRangeChanged,
      );
}
