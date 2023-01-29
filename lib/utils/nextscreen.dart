import 'package:flutter/material.dart';

void nextScreenCloseOther(context, page) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => page));
}

void nextScreen(context, page) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => page));
}
