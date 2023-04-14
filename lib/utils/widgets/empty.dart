import 'package:dellenhauer_admin/utils/colors.dart';
import 'package:flutter/material.dart';

Widget emptyPage(icon, message) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(icon, size: 60, color: kPrimaryColor),
        const SizedBox(height: 10),
        Text(message,
            style: const TextStyle(
                fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w600))
      ],
    ),
  );
}
