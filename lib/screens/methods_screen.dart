import 'package:flutter/material.dart';

import '../models/method.dart';
import '../services/api_service.dart';
import 'method_detail_screen.dart';
import 'feedback_screen.dart';

class MethodsScreen extends StatefulWidget {
  final bool showAppBar;

  const MethodsScreen({
    super.key,
    this.showAppBar = false,
  });

  @override
  State<MethodsScreen> createState() => _MethodsScreenState();
}

class _MethodsScreenState extends State<MethodsScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

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
          });
          return;
        }
      }
    }
  }

  Widget _buildMethodCard(Method method, int index) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(method.methodId),
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 420 + ((index - 1) % 6) * 65),
      curve: Curves.easeOutCubic,
      builder: (context, progress, child) => Opacity(
        opacity: progress,
        child: Transform.translate(
          offset: Offset(0, 14 * (1 - progress)),
          child: child,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: const BoxConstraints(minHeight: 54),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Color(0xFFFFF9F8)],
          ),
          borderRadius: BorderRadius.circular(17),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF9F3D48).withOpacity(0.08),
              blurRadius: 13,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: const Color(0xFF9B6669),
            width: 2),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(17),
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      method.methodName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF382C2C),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMethodsHeader() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(18, 17, 18, 17),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'KAEDAH 10B',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF382C2C),
                fontSize: 30,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground({required Widget child}) {
    return Stack(
      children: [
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFFF5F2),
                  Color(0xFFFFFCFB),
                  Color(0xFFFFF1F3),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 28,
          right: -70,
          child: _backgroundOrb(
            210,
            const Color(0xFFF4A6A0).withOpacity(0.10),
          ),
        ),
        Positioned(
          bottom: 95,
          left: -95,
          child: _backgroundOrb(
            230,
            const Color(0xFFE98F9A).withOpacity(0.08),
          ),
        ),
        child,
      ],
    );
  }

  Widget _backgroundOrb(double size, Color color) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }

  Widget _buildFeedbackButton() {
    return Container(
      width: double.infinity,
      height: 52,
      margin: const EdgeInsets.only(top: 6, bottom: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF1F0), Color(0xFFFFE9E8)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9F3D48).withOpacity(0.10),
            blurRadius: 13,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFE9C1C0)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const FeedbackScreen(),
              ),
            );
          },
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.chat_bubble_outline_rounded,
                color: Color(0xFFBD3546),
                size: 19,
              ),
              SizedBox(width: 9),
              Text(
                'Feedback',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF382C2C),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    Widget content;

    if (methods.isEmpty) {
      content = const Center(
        child: Text(
          'No methods available.',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF887779),
          ),
        ),
      );
    } else {
      content = ListView.builder(
        physics: const ClampingScrollPhysics(),
        padding: EdgeInsets.only(
          left: 22,
          right: 22,
          top: widget.showAppBar ? 12 : 4,
          bottom: 24,
        ),
        itemCount: methods.length + 1,
        itemBuilder: (context, index) {
          if (index < methods.length) {
            return _buildMethodCard(methods[index], index + 1);
          }

          return _buildFeedbackButton();
        },
      );
    }

    if (widget.showAppBar) {
      return Scaffold(
        backgroundColor: const Color(0xFFFFF8F7),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Color(0xFFBD3546)),
          title: const Text(
            'KAEDAH 10B',
            style: TextStyle(
              color: Color(0xFFBD3546),
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ),
        body: _buildBackground(
          child: SafeArea(child: content),
        ),
      );
    }

    return _buildBackground(
      child: SafeArea(
        child: Column(
          children: [
            _buildMethodsHeader(),
            Expanded(child: content),
          ],
        ),
      ),
    );
  }
}
