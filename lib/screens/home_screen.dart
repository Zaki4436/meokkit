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
      backgroundColor: const Color(0xFFFFF8F7),
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
        Positioned.fill(
          child: DecoratedBox(
            decoration: const BoxDecoration(
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
            child: Stack(
              children: [
                Positioned(
                  top: 28,
                  right: -70,
                  child: Container(
                    width: 210,
                    height: 210,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFF4A6A0).withOpacity(0.10),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 95,
                  left: -95,
                  child: Container(
                    width: 230,
                    height: 230,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFE98F9A).withOpacity(0.08),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
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
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFFFF9F8)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB64A52).withOpacity(0.10),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: const Color.fromARGB(255, 155, 102, 105),
          width: 2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
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
                color: Color(0xFF382C2C),
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
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFFFF9F8)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB64A52).withOpacity(0.10),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: const Color.fromARGB(255, 155, 102, 105),
          width: 2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
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
                color: Color(0xFF382C2C),
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
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFFFF9F8)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB64A52).withOpacity(0.10),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: const Color.fromARGB(255, 155, 102, 105),
          width: 2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _openDass,
          child: const Center(
            child: Text(
              'DASS Test',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF382C2C),
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
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFDFC), Color(0xFFFFE9E8)],
        ),
        borderRadius: BorderRadius.circular(27),
        border: Border.all(
          color: const Color(0xFFF1D4D2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9F3D48).withOpacity(0.16),
            blurRadius: 18,
            offset: const Offset(0, 7),
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
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFE65B63), Color(0xFFBD3546)],
                    ),
                    borderRadius: BorderRadius.circular(27),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFBD3546).withOpacity(0.32),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
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
                  color: isSelected ? Colors.white : const Color(0xFF9B6669),
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