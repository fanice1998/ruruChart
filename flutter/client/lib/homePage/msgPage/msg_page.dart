import 'package:flutter/material.dart';
import 'dart:convert';

class MsgPage extends StatelessWidget {
  final List<Map<String, dynamic>> testMessage = [
    {
      "title": "張三",
      "message": "That's message",
    },
    {
      "title": "李四",
      "message": "That's message",
    },
    {
      "title": "王武",
      "message": "That's message",
    },
    {
      "title": "六合",
      "message": "That's message",
    },
    {
      "title": "七喜",
      "message": "That's message",
    },
    {
      "title": "張三",
      "message": "That's message",
    },
    {
      "title": "八嘎",
      "message": "That's message",
    },
    {
      "title": "九黎",
      "message": "That's message",
    },
    {
      "title": "誠十",
      "message": "That's message",
    },
    {
      "title": "零蛋",
      "message": "That's message",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: testMessage.length,
      itemBuilder: (context, index) {
        String title = testMessage[index]["title"];
        String message = testMessage[index]["message"];

        return Card(
          margin: EdgeInsets.only(left: 5, right: 5, bottom: 10),
          // color: Colors.lightBlue.shade200,
          // shadowColor: Colors.grey,
          elevation: 10,
          child: ListTile(
            leading: const Icon(
              Icons.message_outlined,
              // color: Colors.white,
            ),
            title: Text("$title"),
            subtitle: Text("$message"),
          ),
        );
      },
    );
  }
}
