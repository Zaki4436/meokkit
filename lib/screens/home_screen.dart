import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'check_emotion_screen.dart';
import 'information_screen.dart';
import 'methods_screen.dart';
import 'setting_screen.dart';

class HomeScreen extends StatefulWidget {
  final int initialIndex;

  const HomeScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _currentIndex;
  late final PageController _pageController;

  static const String dassUrl =
      'https://e2pk.moe.gov.my/kframe.cfm?page_daftar#!';

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (_currentIndex == index) return;
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 320),
      curve: Curves.fastOutSlowIn,
    );
  }

  Future<void> _openDass() async {
    final uri = Uri.parse(dassUrl);
    final opened = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open the link.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildHomeBody(),
          const MethodsScreen(showAppBar: false),
          const SettingScreen(showAppBar: false),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: _buildCustomBottomBar(),
      ),
    );
  }

  Widget _buildHomeBody() {
    return Stack(
      children: [
        SafeArea(
          bottom: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(32, 20, 50, 100),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 30,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  Center(
                    child: Image.asset(
                      'assets/icon/full_logo_nobg.png',
                      height: 275,
                      fit: BoxFit.contain,
                    ),
                  ),

                  Transform.translate(
                    offset: const Offset(0, -20),
                    child: const Text(
                      textAlign: TextAlign.center,
                      'Unit Psikologi dan Kaunseling\nKolej Matrikulasi Johor',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 112, 112, 112),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Button 1: Information About Stress
                  _buildActionCard1(),

                  const SizedBox(height: 18),

                  // Button 2: Stress Check
                  _buildActionCard2(),

                  const SizedBox(height: 18),

                  // Button 3: DASS Test
                  _buildActionCard3(),
                ],
              ),
            ),
          );
        },
      ),
    ),
  ],
);
}

  // Button 1: Information About Stress
  Widget _buildActionCard1() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255), // Box 1 background color
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: const Color.fromARGB(255, 224, 224, 224), // Box 1 border color
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
                builder: (_) => const InformationScreen(),
              ),
            );
          },
          child: const Center(
            child: Text(
              'Information About Stress',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color.fromARGB(255, 0, 0, 0), // Box 1 text color
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Button 2: Stress Check
  Widget _buildActionCard2() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255), // Box 2 background color
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: const Color.fromARGB(255, 224, 224, 224), // Box 2 border color
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
                builder: (_) => const CheckEmotionScreen(),
              ),
            );
          },
          child: const Center(
            child: Text(
              'Stress Check',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color.fromARGB(255, 0, 0, 0), // Box 2 text color
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Button 3: DASS Test
  Widget _buildActionCard3() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255), // Box 3 background color
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: const Color.fromARGB(255, 224, 224, 224), // Box 3 border color
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: _openDass,
          child: const Center(
            child: Text(
              'DASS  Test',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color.fromARGB(255, 0, 0, 0), // Box 3 text color
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomBottomBar() {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
      height: 54,
      decoration: BoxDecoration(
        color: const Color(0xFFFFCDD2), // Soft pink background
        borderRadius: BorderRadius.circular(27),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabWidth = constraints.maxWidth / 3;

          return Stack(
            children: [
              // Smooth sliding indicator pill
              AnimatedPositioned(
                duration: const Duration(milliseconds: 320),
                curve: Curves.fastOutSlowIn,
                left: _currentIndex * tabWidth,
                top: 0,
                bottom: 0,
                width: tabWidth,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(27),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),

              // Interactive icons row
              Row(
                children: [
                  _buildNavItem(0, Icons.home),
                  _buildNavItem(1, Icons.self_improvement),
                  _buildNavItem(2, Icons.settings),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon) {
    final isSelected = _currentIndex == index;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _onTabTapped(index),
        child: SizedBox(
          height: 54,
          child: Center(
            child: AnimatedScale(
              scale: isSelected ? 1.15 : 1.0,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutBack,
              child: AnimatedOpacity(
                opacity: isSelected ? 1.0 : 0.65,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}