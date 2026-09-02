import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:filmcock_app/data/models/mbti_info.dart';
import 'package:filmcock_app/presentation/screens/onboarding/mbti_detail_screen.dart';

class MbtiCategory {
  final String title;
  final String subtitle;
  final Color themeColor;
  final List<String> mbtiIds;

  MbtiCategory({
    required this.title,
    required this.subtitle,
    required this.themeColor,
    required this.mbtiIds,
  });
}

class MbtiPanelScreen extends StatelessWidget {
  MbtiPanelScreen({super.key});

  final List<MbtiCategory> categories = [
    MbtiCategory(
      title: '관리자형 (Sentinels)',
      subtitle: '신뢰할 수 있는 실용주의자',
      themeColor: const Color(0xFF3B82F6),
      mbtiIds: ['ISTJ', 'ISFJ', 'ESTJ', 'ESFJ'],
    ),
    MbtiCategory(
      title: '외교관형 (Diplomats)',
      subtitle: '공감 능력이 뛰어난 이상주의자',
      themeColor: const Color(0xFFEF4444),
      mbtiIds: ['INFJ', 'INFP', 'ENFJ', 'ENFP'],
    ),
    MbtiCategory(
      title: '분석형 (Analysts)',
      subtitle: '합리적이고 독립적인 지식인',
      themeColor: const Color(0xFFA855F7),
      mbtiIds: ['INTJ', 'INTP', 'ENTJ', 'ENTP'],
    ),
    MbtiCategory(
      title: '탐험가형 (Explorers)',
      subtitle: '자유롭고 매력적인 예술가',
      themeColor: const Color(0xFFEAB308),
      mbtiIds: ['ISTP', 'ISFP', 'ESTP', 'ESFP'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        title: const Text(
          'MBTI 선택',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return _buildCategoryPanel(context, categories[index]);
        },
      ),
    );
  }

  Widget _buildCategoryPanel(BuildContext context, MbtiCategory category) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: category.themeColor.withOpacity(0.5), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            category.title,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: category.themeColor),
          ),
          const SizedBox(height: 6),
          Text(category.subtitle, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 20),
          ...category.mbtiIds.map((id) {
            final info = getMbtiInfoById(id);
            if (info == null) return const SizedBox.shrink();
            return _buildMbtiItem(context, info);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildMbtiItem(BuildContext context, MbtiInfo mbti) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C34),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            padding: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.0)),
            child: SvgPicture.asset(
              mbti.svgAsset,
              fit: BoxFit.contain,
              placeholderBuilder: (_) => const CircularProgressIndicator(),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(mbti.id, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 4),
                Text(mbti.title, style: const TextStyle(fontSize: 13, color: Colors.grey)),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => MbtiDetailScreen(mbtiInfo: mbti),
              ));
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF8B5CF6), width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            ),
            child: const Text('보기', style: TextStyle(color: Color(0xFF8B5CF6), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
