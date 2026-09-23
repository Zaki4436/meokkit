import 'package:flutter/material.dart';

import '../models/method.dart';
import '../services/api_service.dart';
import 'method_detail_screen.dart';

class MethodsScreen extends StatefulWidget {
  final bool showAppBar;

  const MethodsScreen({
    super.key,
    this.showAppBar = false,
  });

  @override
  State<MethodsScreen> createState() => _MethodsScreenState();
}

class _MethodsScreenState extends State<MethodsScreen> {
  bool loading = false;

  // Pre-populated default methods list for instant rendering and offline support
  static final List<Method> _defaultMethods = [
    Method(
      methodId: '1',
      methodName: 'Bertenang',
      description: 'Aktiviti untuk membantu menenangkan diri.',
    ),
    Method(
      methodId: '2',
      methodName: 'Bernafas Dengan Dalam',
      description: 'Latihan pernafasan untuk membantu mengurangkan tekanan.',
    ),
    Method(
      methodId: '3',
      methodName: 'Berkata "Relakslah"',
      description: 'Permainan santai untuk mengalihkan perhatian.',
    ),
    Method(
      methodId: '4',
      methodName: 'Beribadat',
      description: '',
    ),
    Method(
      methodId: '5',
      methodName: 'Bercakap Dengan Seseorang',
      description: '',
    ),
    Method(
      methodId: '6',
      methodName: 'Berurut',
      description: '',
    ),
    Method(
      methodId: '7',
      methodName: 'Berehat & Mendengar Muzik',
      description: '',
    ),
    Method(
      methodId: '8',
      methodName: 'Beriadah',
      description: '',
    ),
    Method(
      methodId: '9',
      methodName: 'Bersenam',
      description: '',
    ),
    Method(
      methodId: '10',
      methodName: 'Berfikiran Positif',
      description: '',
    ),
  ];

  late List<Method> methods;

  @override
  void initState() {
    super.initState();
    methods = List.from(_defaultMethods);
    _loadMethods();
  }

  Future<void> _loadMethods() async {
    final result = await ApiService.get('getMethods');

    if (result['success'] == true) {
      final data = result['data'];
      final List<dynamic> methodData = data['methods'] ?? [];

      if (methodData.isNotEmpty) {
        final fetched = methodData
            .map(
              (item) => Method.fromJson(item),
            )
            .toList();

        if (mounted) {
          setState(() {
            methods = fetched;
            loading = false;
          });
          return;
        }
      }
    }

    if (!mounted) return;
    setState(() {
      loading = false;
    });
  }

  Widget _buildMethodCard(Method method) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      height: 55,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MethodDetailScreen(
                  method: method,
                ),
              ),
            );
          },
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                method.methodName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF1E1E1E),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (loading && methods.isEmpty) {
      content = const Center(
        child: CircularProgressIndicator(
          color: Colors.red,
        ),
      );
    } else if (methods.isEmpty) {
      content = const Center(
        child: Text(
          'No methods available.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    } else {
      content = RefreshIndicator(
        color: Colors.red,
        onRefresh: _loadMethods,
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.only(
            left: 28,
            right: 28,
            top: widget.showAppBar ? 12 : 4,
            bottom: 24,
          ),
          itemCount: methods.length,
          itemBuilder: (context, index) {
            return _buildMethodCard(methods[index]);
          },
        ),
      );
    }

    if (widget.showAppBar) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.red),
          title: const Text(
            'KAEDAH 10B',
            style: TextStyle(
              color: Colors.red,
              fontSize: 26,
              fontWeight: FontWeight.w900,
              fontFamily: 'serif',
              letterSpacing: 0.5,
            ),
          ),
        ),
        body: content,
      );
    }

    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              'KAEDAH 10B',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                fontFamily: 'serif',
                color: Colors.red,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: content,
            ),
          ],
        ),
      ),
    );
  }
}