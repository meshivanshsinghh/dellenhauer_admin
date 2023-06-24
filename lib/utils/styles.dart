import 'package:dellenhauer_admin/utils/colors.dart';
import 'package:flutter/material.dart';

InputDecoration inputDecoration(hint, label, TextEditingController controller) {
  return InputDecoration(
    hintText: hint,
    counter: const Text(''),
    hintStyle: const TextStyle(color: Colors.black54),
    border:
        const OutlineInputBorder(borderSide: BorderSide(color: kPrimaryColor)),
    enabledBorder:
        const OutlineInputBorder(borderSide: BorderSide(color: Colors.black54)),
    focusedBorder:
        const OutlineInputBorder(borderSide: BorderSide(color: kPrimaryColor)),
    labelText: label,
    labelStyle: const TextStyle(color: Colors.black54),
    contentPadding: const EdgeInsets.only(right: 0, left: 10),
  );
}

InputDecoration inputDecorationPushNotification(
  hint,
  label,
  TextEditingController controller,
) {
  return InputDecoration(
    hintText: hint,
    counter: Container(margin: const EdgeInsets.only(bottom: 10)),
    hintStyle: const TextStyle(color: Color(0xff6B6B6B)),
    border: OutlineInputBorder(
      borderSide: const BorderSide(color: Color(0xffD9D9D9)),
      borderRadius: BorderRadius.circular(0),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Color(0xffD9D9D9)),
      borderRadius: BorderRadius.circular(0),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Color(0xffD9D9D9)),
      borderRadius: BorderRadius.circular(0),
    ),
    labelText: label,
    labelStyle: const TextStyle(color: Colors.black54),
    contentPadding: const EdgeInsets.only(right: 0, left: 10),
    filled: true,
    fillColor: const Color(0xffFCFCFC),
  );
}
