import 'package:flutter/material.dart';

class InfoDetailScreen extends StatelessWidget {
  final String title;
  final String content;

  const InfoDetailScreen({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Text(
          content,
          style: const TextStyle(
            fontSize: 17,
            height: 1.6,
          ),
        ),
      ),
    );
  }
}