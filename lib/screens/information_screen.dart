import 'package:flutter/material.dart';

import 'info_detail_screen.dart';

class InformationScreen extends StatelessWidget {
  const InformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final information = [
      {
        'title': 'What is Stress?',
        'content':
            'Stress is the body response to pressure or challenging situations.',
      },
      {
        'title': 'Signs of Stress',
        'content':
            'Stress may affect emotions, thoughts, behaviour and physical wellbeing.',
      },
      {
        'title': 'Managing Stress',
        'content':
            'Healthy activities, relaxation, physical activity and social support may help manage stress.',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Information'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: information.length,
        itemBuilder: (context, index) {
          final item = information[index];

          return Card(
            child: ListTile(
              title: Text(
                item['title']!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        InfoDetailScreen(
                      title: item['title']!,
                      content: item['content']!,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}