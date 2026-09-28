import 'package:flutter/material.dart';

import '../models/information.dart';
import '../services/api_service.dart';

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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.red),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: Colors.red,
          onRefresh: _loadInformation,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Title: INFORMATION
                const Text(
                  'INFORMATION',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                    letterSpacing: 1.0,
                  ),
                ),

                const SizedBox(height: 28),

                if (_loading && _items.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: CircularProgressIndicator(color: Colors.red),
                    ),
                  )
                else
                  ..._items.asMap().entries.map(
                        (entry) => _buildExpandableCard(
                          entry.value,
                          entry.key + 1,
                        ),
                      ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpandableCard(InformationModel item, int index) {
    final isExpanded = _expandedId == item.infoId;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isExpanded
                ? Colors.red.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: isExpanded ? 14 : 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: isExpanded ? Colors.red.shade300 : const Color(0xFFE8E8E8),
          width: isExpanded ? 1.5 : 1.2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
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
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top badge row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: isExpanded
                            ? const Color(0xFFFFEBEE)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Title: info_name
                Text(
                  item.infoName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                  ),
                ),

                AnimatedCrossFade(
                  firstChild: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'See more',
                            style: TextStyle(
                              color: Colors.grey.shade800,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Subtle hairline divider
                        Container(
                          height: 1,
                          color: Colors.grey.shade100,
                          margin: const EdgeInsets.only(bottom: 12),
                        ),

                        // Formatted content
                        _buildFormattedDescription(item.infoDescription),

                        const SizedBox(height: 14),

                        // See less button
                        Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'See less',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  crossFadeState: isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 320),
                  sizeCurve: Curves.easeInOutCubic,
                  firstCurve: Curves.easeOut,
                  secondCurve: Curves.easeIn,
                  alignment: Alignment.topCenter,
                ),
              ],
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
                    color: Colors.red,
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
                color: Colors.red,
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