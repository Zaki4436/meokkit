import 'package:flutter/material.dart';

import '../models/method.dart';
import '../services/api_service.dart';
import 'method_detail_screen.dart';

class MethodsScreen extends StatefulWidget {
  final bool showAppBar;

  const MethodsScreen({
    super.key,
    this.showAppBar = true,
  });

  @override
  State<MethodsScreen> createState() =>
      _MethodsScreenState();
}

class _MethodsScreenState
    extends State<MethodsScreen> {
  bool loading = true;

  List<Method> methods = [];

  @override
  void initState() {
    super.initState();

    _loadMethods();
  }

  Future<void> _loadMethods() async {
    final result =
        await ApiService.get('getMethods');

    if (result['success'] == true) {
      final data = result['data'];

      final List<dynamic> methodData =
          data['methods'] ?? [];

      methods = methodData
          .map(
            (item) => Method.fromJson(item),
          )
          .toList();
    }

    if (!mounted) return;

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final body = loading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : methods.isEmpty
            ? const Center(
                child: Text(
                  'No methods available.',
                ),
              )
            : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: methods.length,
                  itemBuilder: (context, index) {
                    final method = methods[index];

                    return Card(
                      margin:
                          const EdgeInsets.only(
                        bottom: 12,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            method.methodId,
                          ),
                        ),
                        title: Text(
                          method.methodName,
                          style: const TextStyle(
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  MethodDetailScreen(
                                method: method,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );

    if (!widget.showAppBar) {
      return body;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('10B'),
      ),
      body: body,
    );
  }
}