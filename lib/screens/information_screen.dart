import 'package:flutter/material.dart';

import '../models/information.dart';
import '../services/api_service.dart';
import 'home_screen.dart';

class InformationScreen extends StatefulWidget {
  const InformationScreen({super.key});

  @override
  State<InformationScreen> createState() => _InformationScreenState();
}

class _InformationScreenState extends State<InformationScreen> {
  bool _loading = false;
  String? _expandedId;

  // Default fallback data matching database structure (info_id, info_name, info_description)
  static final List<InformationModel> _defaultInformation = [
    InformationModel(
      infoId: '1',
      infoName: 'What is Stress?',
      infoDescription:
          'Desakan atau tekanan yang dihadapi oleh individu berikutan peristiwa yang berlaku pada mereka. Apa jua keadaan atau situasi yang mengancam atau dianggap mengganggu keadaan diri seseorang. Stres menyebabkan individu memerlukan keupayaan dan cara untuk menghadapinya.\n\nBoleh berlaku dari segi emosi dan juga fizikal. Perkara yang sering berlaku kepada manusia yang normal. Merupakan cabaran emosi yang tidak dapat dipisahkan dari kehidupan manusia. Berlaku akibat perubahan luaran atau dalaman yang melebihi kemampuan individu.',
    ),
    InformationModel(
      infoId: '2',
      infoName: 'Signs of Stress?',
      infoDescription:
          'FIZIKAL\n• Kering mulut\n• Gementar\n• Sakit kepala\n• Masalah tidur\n• Cepat letih\n• Lenguh badan\n• Jantung berdebar-debar\n• Sakit perut\n• Cirit-birit\n\nPSIKOLOGI\n• Gelisah\n• Cepat marah\n• Lemah semangat\n• Bimbang\n• Kurang daya tumpuan\n• Mudah lupa\n• Takut gagal\n• Bosan',
    ),
    InformationModel(
      infoId: '3',
      infoName: 'Effect of Stress?',
      infoDescription:
          'Stres akan mengakibatkan gangguan emosi, masalah tingkah laku, perubahan personaliti. Keadaan ini menambahkan lagi risiko penyakit mental dan fizikal.\n\nStres boleh menyebabkan :\n• Penyakit jantung korona\n• Angin ahmar (strok)\n• Kegagalan jantung\n• Kemurungan',
    ),
  ];

  late List<InformationModel> _items;

  @override
  void initState() {
    super.initState();
    _items = List.from(_defaultInformation);
    _loadInformation();
  }

  Future<void> _loadInformation() async {
    // Try getInformation first, then getInfo
    var result = await ApiService.get('getInformation');
    if (result['success'] != true) {
      result = await ApiService.get('getInfo');
    }

    if (result['success'] == true) {
      final data = result['data'];
      List<dynamic> list = [];

      if (data is List) {
        list = data;
      } else if (data is Map<String, dynamic>) {
        list = data['information'] ??
            data['info'] ??
            data['infos'] ??
            data['data'] ??
            [];
      }

      if (list.isNotEmpty) {
        final fetched = list
            .map(
              (item) => InformationModel.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList();

        if (mounted) {
          setState(() {
            _items = fetched;
            _loading = false;
          });
          return;
        }
      }
    }

    if (!mounted) return;
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          color: Colors.red,
          onRefresh: _loadInformation,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 12),

                // Title: INFORMATION
                const Center(
                  child: Text(
                    'INFORMATION',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),

                const SizedBox(height: 36),

                if (_loading && _items.isEmpty)
                  const Center(
                    child: CircularProgressIndicator(color: Colors.red),
                  )
                else
                  ..._items.map((item) => _buildExpandableCard(item)),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: _buildCustomBottomBar(context),
      ),
    );
  }

  Widget _buildExpandableCard(InformationModel item) {
    final isExpanded = _expandedId == item.infoId;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1.2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            setState(() {
              if (isExpanded) {
                _expandedId = null;
              } else {
                _expandedId = item.infoId;
              }
            });
          },
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 20,
              vertical: isExpanded ? 24 : 22,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header: info_name
                Text(
                  item.infoName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                if (!isExpanded) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'See more',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 16),
                  // Content: info_description
                  Text(
                    item.infoDescription,
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      fontSize: 14.5,
                      color: Colors.black87,
                      height: 1.55,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Center(
                    child: Text(
                      'See less',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomBottomBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
      height: 54,
      decoration: BoxDecoration(
        color: const Color(0xFFFFCDD2), // Soft pink background
        borderRadius: BorderRadius.circular(27),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Home Tab (Active)
          _buildNavItem(
            context: context,
            icon: Icons.home,
            isSelected: true,
            onTap: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                Navigator.pushReplacementNamed(context, '/home');
              }
            },
          ),
          // 10B Tab
          _buildNavItem(
            context: context,
            icon: Icons.self_improvement,
            isSelected: false,
            onTap: () {
              Navigator.pushReplacementNamed(context, '/methods');
            },
          ),
          // Setting Tab
          _buildNavItem(
            context: context,
            icon: Icons.settings,
            isSelected: false,
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const HomeScreen(initialIndex: 2),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 54,
          decoration: BoxDecoration(
            color: isSelected ? Colors.red : Colors.transparent,
            borderRadius: BorderRadius.circular(27),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }
}