import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/link.dart';
import '../models/method.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class MethodDetailScreen extends StatefulWidget {
  final Method method;

  const MethodDetailScreen({
    super.key,
    required this.method,
  });

  @override
  State<MethodDetailScreen> createState() =>
      _MethodDetailScreenState();
}

class _MethodDetailScreenState
    extends State<MethodDetailScreen> {
  bool loading = true;

  List<MethodLink> links = [];

  @override
  void initState() {
    super.initState();

    _loadLinks();
    _saveActivity();
  }

  Future<void> _loadLinks() async {
    final result = await ApiService.get(
      'getLink',
      params: {
        'method_id': widget.method.methodId,
      },
    );

    if (result['success'] == true) {
      final data = result['data'];

      final List<dynamic> linkData =
          data['links'] ?? [];

      links = linkData
          .map(
            (item) => MethodLink.fromJson(item),
          )
          .where(
            (link) => link.linkUrl.isNotEmpty,
          )
          .toList();
    }

    if (!mounted) return;

    setState(() {
      loading = false;
    });
  }

  Future<void> _saveActivity() async {
    final user = await AuthService.getUser();

    if (user == null) return;

    await ApiService.post({
      'action': 'saveActivity',
      'user_id': user.userId,
      'method_id': widget.method.methodId,
      'method_name': widget.method.methodName,
    });
  }

  Future<void> _openLink(String url) async {
    final uri = Uri.tryParse(url);

    if (uri == null) {
      return;
    }

    final opened = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to open link.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.method.methodName,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              widget.method.methodName,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              widget.method.description.isEmpty
                  ? 'No description available.'
                  : widget.method.description,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              'Activities / Links',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            if (loading)
              const Center(
                child: CircularProgressIndicator(),
              )
            else if (links.isEmpty)
              const Text(
                'No links available.',
              )
            else
              ...links.map(
                (link) => Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.link,
                    ),
                    title: Text(
                      link.linkName.isEmpty
                          ? 'Open Activity'
                          : link.linkName,
                    ),
                    trailing: const Icon(
                      Icons.open_in_new,
                    ),
                    onTap: () {
                      _openLink(
                        link.linkUrl,
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}