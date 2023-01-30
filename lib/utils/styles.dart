import 'package:flutter/material.dart';

InputDecoration inputDecoration(hint, label, controller) {
  return InputDecoration(
      hintText: hint,
      border: const OutlineInputBorder(),
      labelText: label,
      contentPadding: const EdgeInsets.only(right: 0, left: 10),
      suffixIcon: Padding(
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
          )));
}
