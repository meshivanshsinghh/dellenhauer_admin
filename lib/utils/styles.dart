import 'package:dellenhauer_admin/utils/colors.dart';
import 'package:flutter/material.dart';

InputDecoration inputDecoration(hint, label, TextEditingController controller) {
  return InputDecoration(
    hintText: hint,
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
