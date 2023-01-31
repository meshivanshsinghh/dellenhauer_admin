import 'package:flutter/material.dart';

InputDecoration inputDecoration(hint, label, TextEditingController controller) {
  return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black54),
      border: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.redAccent)),
      enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black54)),
      focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.redAccent)),
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black54),
      contentPadding: const EdgeInsets.only(right: 0, left: 10),
      suffixIcon: controller.text.trim().isNotEmpty
          ? Padding(
              padding: const EdgeInsets.all(8),
              child: CircleAvatar(
                radius: 15,
                backgroundColor: Colors.grey[300],
                child: IconButton(
                  icon: const Icon(
                    Icons.close,
                    size: 15,
                    color: Colors.redAccent,
                  ),
                  onPressed: () {
                    controller.clear();
                  },
                ),
              ))
          : null);
}
