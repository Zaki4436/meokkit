import 'package:flutter/material.dart';

import '../models/information.dart';
import '../services/api_service.dart';

class InformationScreen extends StatefulWidget {
  const InformationScreen({super.key});

  @override
  State<InformationScreen> createState() => _InformationScreenState();
}

class _InformationScreenState extends State<InformationScreen>
    with SingleTickerProviderStateMixin {
  static const Color _accent = Color(0xFFE65B63);
  static const Color _deepAccent = Color(0xFFBD3546);
  static const Color _ink = Color(0xFF382C2C);

  late final AnimationController _entranceController;
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
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _items = List.from(_defaultInformation);
    _loadInformation();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
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
      extendBody: true,
      backgroundColor: const Color(0xFFFFF8F7),
      body: Stack(
        children: [
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) => Stack(
                children: [
                  Positioned.fill(
                    child: SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Stack(
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
                                      child: _backgroundOrb(
                                        210,
                                        const Color(0xFFF4A6A0)
                                            .withOpacity(0.10),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 95,
                                      left: -95,
                                      child: _backgroundOrb(
                                        230,
                                        const Color(0xFFE98F9A)
                                            .withOpacity(0.08),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(32, 72, 50, 30),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  AnimatedBuilder(
                                    animation: _entranceController,
                                    builder: (context, child) {
                                      final progress =
                                          Curves.easeOutCubic.transform(
                                        (_entranceController.value / 0.65)
                                            .clamp(0.0, 1.0)
                                            .toDouble(),
                                      );
                                      return Opacity(
                                        opacity: progress,
                                        child: Transform.translate(
                                          offset:
                                              Offset(0, 20 * (1 - progress)),
                                          child: child,
                                        ),
                                      );
                                    },
                                    child: Row(
                                      children: [
                                        const Expanded(
                                          child: Text(
                                            'INFORMATION',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: _ink,
                                              fontSize: 23,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  if (_loading && _items.isEmpty)
                                    const Center(
                                      child: Padding(
                                        padding: EdgeInsets.only(top: 40),
                                        child: CircularProgressIndicator(
                                          color: _deepAccent,
                                        ),
                                      ),
                                    )
                                  else
                                    ..._items.asMap().entries.map(
                                          (entry) => _buildExpandableCard(
                                            entry.value,
                                            entry.key + 1,
                                          ),
                                        ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 12,
                    child: Material(
                      color: Colors.white.withOpacity(0.88),
                      shape: const CircleBorder(),
                      elevation: 3,
                      shadowColor: _deepAccent.withOpacity(0.16),
                      child: IconButton(
                        tooltip: 'Back',
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: _deepAccent,
                          size: 19,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _backgroundOrb(double size, Color color) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildExpandableCard(InformationModel item, int index) {
    final isExpanded = _expandedId == item.infoId;

    return AnimatedBuilder(
      animation: _entranceController,
      builder: (context, child) {
        final entranceStart = ((index - 1) * 0.12).clamp(0.0, 0.72).toDouble();
        final entranceProgress = Curves.easeOutCubic.transform(
          ((_entranceController.value - entranceStart) / (1 - entranceStart))
              .clamp(0.0, 1.0)
              .toDouble(),
        );
        return Opacity(
          opacity: entranceProgress,
          child: Transform.translate(
            offset: Offset(0, 18 * (1 - entranceProgress)),
            child: child,
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOutCubic,
        width: double.infinity,
        margin: EdgeInsets.only(bottom: index == _items.length ? 0 : 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Color(0xFFFFF9F8)],
          ),
          borderRadius: BorderRadius.circular(19),
          boxShadow: [
            BoxShadow(
              color: isExpanded
                  ? _deepAccent.withOpacity(0.15)
                  : const Color(0xFF9F3D48).withOpacity(0.08),
              blurRadius: isExpanded ? 20 : 14,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(
            color:
                isExpanded ? const Color(0xFF9B6669) : const Color(0xFFF1D4D2),
            width: isExpanded ? 2 : 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(19),
            onTap: () {
              setState(() {
                _expandedId = isExpanded ? null : item.infoId;
              });
            },
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 25, right: 25, top: 30, bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 30),
                      Expanded(
                        child: Text(
                          item.infoName,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: _ink,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 320),
                        curve: Curves.easeInOutCubic,
                        child: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: _deepAccent,
                          size: 26,
                        ),
                      ),
                    ],
                  ),
                  AnimatedCrossFade(
                    firstChild: Padding(
                      padding: const EdgeInsets.only(top: 12, left: 60),
                      child: Align(
                        alignment: Alignment.centerLeft,
                      ),
                    ),
                    secondChild: Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            height: 1,
                            color: const Color(0xFFF1D4D2),
                            margin: const EdgeInsets.only(bottom: 12),
                          ),
                          _buildFormattedDescription(item.infoDescription),
                        ],
                      ),
                    ),
                    crossFadeState: isExpanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 420),
                    sizeCurve: Curves.easeInOutCubic,
                    firstCurve: Curves.easeOutCubic,
                    secondCurve: Curves.easeInOutCubic,
                    alignment: Alignment.topCenter,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormattedDescription(String text) {
    final lines = text.split('\n');
    final List<Widget> widgets = [];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) {
        widgets.add(const SizedBox(height: 6));
        continue;
      }

      if (line.startsWith('•')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 7, right: 8),
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: _accent,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    line.replaceFirst('•', '').trim(),
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: Color(0xFF2C2C2C),
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else if (line == 'FIZIKAL' ||
          line == 'PSIKOLOGI' ||
          line.endsWith(':') ||
          (line.length < 25 &&
              line == line.toUpperCase() &&
              !line.contains('.'))) {
        widgets.add(
          Padding(
            padding: EdgeInsets.only(top: widgets.isEmpty ? 0 : 8, bottom: 4),
            child: Text(
              line,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: _deepAccent,
                letterSpacing: 0.6,
              ),
            ),
          ),
        );
      } else {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              line,
              style: const TextStyle(
                fontSize: 13.5,
                color: Color(0xFF2C2C2C),
                height: 1.55,
              ),
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: widgets,
    );
  }
}
