import 'package:flutter/material.dart';

void showSnackbar(BuildContext context, String content) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(content),
  ));
}

showContentPreview(context, imageUrl) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Stack(
            children: [
              Container(
                height: 400,
                width: 500,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                  top: 10,
                  left: 10,
                  child: InkWell(
                    child: const CircleAvatar(
                      backgroundColor: Colors.redAccent,
                      child: Icon(Icons.close, color: Colors.white),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ))
            ],
          ),
        );
      });
}

void deletingUser(BuildContext context, String title, String content,
    ElevatedButton button1, ElevatedButton button2) {
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(20),
          elevation: 0,
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: Text(
            content,
            style: TextStyle(
              color: Colors.grey[900],
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          actions: [
            button1,
            button2,
          ],
        );
      });
}
