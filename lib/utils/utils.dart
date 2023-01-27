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
